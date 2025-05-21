#!/bin/bash
#
# Container Monitoring Script
# Monitors Docker container resources and application health
#

# Configuration
CONTAINER_NAME="${CONTAINER_NAME:-monitored-app}"
LOG_FILE="/var/log/container_monitor.log"
ALERT_LOG="/var/log/container_alerts.log"
METRICS_FILE="/var/log/container_metrics.csv"

# Thresholds
CPU_THRESHOLD="$CPU_THRESHOLD"     # 40% of allocated CPU
MEMORY_THRESHOLD="$MEMORY_THRESHOLD"  # 80% of allocated memory
RESPONSE_TIME_THRESHOLD="$RESPONSE_TIME_THRESHOLD"  # 1 second in milliseconds

# Initialize log files
initialize_logs() {
    touch "$LOG_FILE" "$ALERT_LOG" "$METRICS_FILE"
    if [ ! -s "$METRICS_FILE" ]; then
        echo "timestamp,cpu_percent,memory_usage_mb,memory_percent,response_time_ms,status" > "$METRICS_FILE"
    fi
}

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Alert function
send_alert() {
    local alert_type="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ALERT: $alert_type - $message" | tee -a "$ALERT_LOG"
}

# Check if container is running
check_container_status() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "running"
    else
        echo "stopped"
    fi
}

# Get container statistics
get_container_stats() {
    local stats=$(docker stats --no-stream --format "{{json .}}" "$CONTAINER_NAME" 2>/dev/null)
    
    if [ -z "$stats" ]; then
        echo "0,0,0"
        return
    fi
    
    # Parse CPU percentage (remove % sign)
    local cpu=$(echo "$stats" | grep -o '"CPUPerc":"[^"]*"' | cut -d'"' -f4 | tr -d '%')
    
    # Parse memory usage
    local mem_usage=$(echo "$stats" | grep -o '"MemUsage":"[^"]*"' | cut -d'"' -f4 | cut -d'/' -f1)
    local mem_limit=$(echo "$stats" | grep -o '"MemUsage":"[^"]*"' | cut -d'"' -f4 | cut -d'/' -f2)
    
    # Convert memory to MB
    local mem_usage_mb=$(echo "$mem_usage" | sed 's/MiB//' | sed 's/GiB/*1024/' | bc 2>/dev/null || echo "0")
    local mem_limit_mb=$(echo "$mem_limit" | sed 's/MiB//' | sed 's/GiB/*1024/' | bc 2>/dev/null || echo "256")
    
    # Calculate memory percentage
    local mem_percent=0
    if [ "$mem_limit_mb" -gt 0 ]; then
        mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_usage_mb / $mem_limit_mb) * 100}")
    fi
    
    echo "$cpu,$mem_usage_mb,$mem_percent"
}

# Check application health
check_app_health() {
    local start_time=$(date +%s%3N)
    
    # Use the container name to check health
    # Fix: Use the actual container name from the docker network
    local response=$(curl -s -w "\n%{http_code}" http://${CONTAINER_NAME}:80/health 2>/dev/null)
    
    local end_time=$(date +%s%3N)
    
    local http_code=$(echo "$response" | tail -n1)
    local response_time=$((end_time - start_time))
    
    if [ "$http_code" = "200" ]; then
        echo "$response_time,healthy"
    else
        echo "$response_time,unhealthy"
    fi
}

# Main monitoring function
monitor_container() {
    log_message "INFO" "Starting container monitoring for $CONTAINER_NAME"
    
    # Check if container exists
    if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_message "ERROR" "Container $CONTAINER_NAME not found"
        return 1
    fi
    
    # Check container status
    local status=$(check_container_status)
    if [ "$status" != "running" ]; then
        send_alert "Container Down" "Container $CONTAINER_NAME is not running"
        return 1
    fi
    
    # Get container stats
    IFS=',' read -r cpu mem_usage_mb mem_percent <<< "$(get_container_stats)"
    
    # Get application health
    IFS=',' read -r response_time app_status <<< "$(check_app_health)"
    
    # Log metrics
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp,$cpu,$mem_usage_mb,$mem_percent,$response_time,$app_status" >> "$METRICS_FILE"
    
    log_message "INFO" "CPU: ${cpu}%, Memory: ${mem_usage_mb}MB (${mem_percent}%), Response Time: ${response_time}ms, Status: $app_status"
    
    # Check thresholds and send alerts
    if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l 2>/dev/null) )); then
        send_alert "High CPU" "CPU usage is ${cpu}% (threshold: ${CPU_THRESHOLD}%)"
    fi
    
    if (( $(echo "$mem_percent > $MEMORY_THRESHOLD" | bc -l 2>/dev/null) )); then
        send_alert "High Memory" "Memory usage is ${mem_percent}% (threshold: ${MEMORY_THRESHOLD}%)"
    fi
    
    if [ "$response_time" -gt "$RESPONSE_TIME_THRESHOLD" ]; then
        send_alert "Slow Response" "Response time is ${response_time}ms (threshold: ${RESPONSE_TIME_THRESHOLD}ms)"
    fi
    
    if [ "$app_status" != "healthy" ]; then
        send_alert "Application Unhealthy" "Application health check failed"
    fi
}

# Generate monitoring report
generate_report() {
    local report_file="/var/log/container_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "Container Monitoring Report"
        echo "=========================="
        echo "Generated: $(date)"
        echo "Container: $CONTAINER_NAME"
        echo ""
        echo "Summary Statistics:"
        echo "-------------------"
        
        if [ -f "$METRICS_FILE" ]; then
            # Calculate averages
            local avg_cpu=$(awk -F',' 'NR>1 {sum+=$2; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}' "$METRICS_FILE")
            local avg_mem=$(awk -F',' 'NR>1 {sum+=$4; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}' "$METRICS_FILE")
            local avg_response=$(awk -F',' 'NR>1 {sum+=$5; count++} END {if(count>0) printf "%.0f", sum/count; else print "0"}' "$METRICS_FILE")
            
            echo "Average CPU Usage: ${avg_cpu}%"
            echo "Average Memory Usage: ${avg_mem}%"
            echo "Average Response Time: ${avg_response}ms"
            echo ""
            echo "Recent Alerts:"
            echo "--------------"
            tail -10 "$ALERT_LOG" 2>/dev/null || echo "No recent alerts"
        fi
    } > "$report_file"
    
    log_message "INFO" "Report generated: $report_file"
    echo "$report_file"
}

# Function to draw a progress bar
draw_bar() {
    local value=$1
    local width=$2
    local filled=$(printf "%.0f" $(echo "$value * $width / 100" | bc -l 2>/dev/null || echo "0"))
    local empty=$((width - filled))
    
    # Color codes based on value
    local color="\e[32m"  # Green
    if (( $(echo "$value > 80" | bc -l 2>/dev/null || echo "0") )); then
        color="\e[31m"    # Red
    elif (( $(echo "$value > 60" | bc -l 2>/dev/null || echo "0") )); then
        color="\e[33m"    # Yellow
    fi
    
    echo -en "${color}"
    printf '▓%.0s' $(seq 1 $filled)
    echo -en "\e[0m"
    printf '░%.0s' $(seq 1 $empty)
    echo ""
}

# Live monitoring with visual display
live_monitor() {
    initialize_logs
    log_message "INFO" "Starting live monitoring mode"
    
    # Clear screen
    clear
    
    # Trap CTRL+C to exit cleanly
    trap 'echo -e "\n\nExiting live monitor..."; exit 0' SIGINT
    
    while true; do
        # Move cursor to top
        tput cup 0 0
        
        # Print header
        echo "╔════════════════════════════════════════════════════════════════════╗"
        echo "║              Container Live Monitor - $(date '+%Y-%m-%d %H:%M:%S')              ║"
        echo "╚════════════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Check container status
        local status=$(check_container_status)
        if [ "$status" != "running" ]; then
            echo "🔴 Container Status: STOPPED"
            echo ""
            echo "Waiting for container to start..."
            sleep 2
            continue
        fi
        
        # Get container stats
        IFS=',' read -r cpu mem_usage_mb mem_percent <<< "$(get_container_stats)"
        
        # Get application health
        IFS=',' read -r response_time app_status <<< "$(check_app_health)"
        
        # Display status
        echo "🟢 Container Status: RUNNING"
        echo ""
        echo "📊 Resource Usage:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # CPU gauge
        echo -n "CPU Usage:     "
        printf "%5.1f%% " "$cpu"
        draw_bar "$cpu" 50
        
        # Memory gauge
        echo -n "Memory Usage:  "
        printf "%5.1f%% " "$mem_percent"
        draw_bar "$mem_percent" 50
        
        echo ""
        echo "📈 Performance Metrics:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Memory Used:     ${mem_usage_mb} MB"
        echo "Response Time:   ${response_time} ms"
        echo "App Health:      ${app_status^^}"
        
        # Check thresholds and display alerts
        echo ""
        echo "⚠️  Alerts:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        local alerts=0
        if (( $(echo "$cpu > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
            echo "🔴 HIGH CPU: ${cpu}% (threshold: ${CPU_THRESHOLD}%)"
            ((alerts++))
        fi
        
        if (( $(echo "$mem_percent > $MEMORY_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
            echo "🔴 HIGH MEMORY: ${mem_percent}% (threshold: ${MEMORY_THRESHOLD}%)"
            ((alerts++))
        fi
        
        if [ "$response_time" -gt "$RESPONSE_TIME_THRESHOLD" ]; then
            echo "🔴 SLOW RESPONSE: ${response_time}ms (threshold: ${RESPONSE_TIME_THRESHOLD}ms)"
            ((alerts++))
        fi
        
        if [ "$app_status" != "healthy" ]; then
            echo "🔴 APPLICATION UNHEALTHY"
            ((alerts++))
        fi
        
        if [ "$alerts" -eq 0 ]; then
            echo "✅ All systems normal"
        fi
        
        # Display recent log entries
        echo ""
        echo "📋 Recent Activity:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        tail -3 "$LOG_FILE" 2>/dev/null | sed 's/^/  /'
        
        # Instructions
        echo ""
        echo "Press Ctrl+C to exit"
        
        # Log metrics for monitoring
        monitor_container
        
        # Sleep for refresh interval
        sleep 2
    done
}

# Main execution
main() {
    case "${1:-monitor}" in
        monitor)
            initialize_logs
            monitor_container
            ;;
        report)
            generate_report
            ;;
        continuous)
            initialize_logs
            log_message "INFO" "Starting continuous monitoring (Ctrl+C to stop)"
            while true; do
                monitor_container
                sleep 60  # Check every minute
            done
            ;;
        live)
            live_monitor
            ;;
        *)
            echo "Usage: $0 [monitor|report|continuous|live]"
            exit 1
            ;;
    esac
}

main "$@"
