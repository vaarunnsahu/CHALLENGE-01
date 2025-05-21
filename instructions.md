# Container Monitoring Exercise - Quick Start Guide

This exercise teaches you how to monitor Docker containers and create load to see high CPU/memory usage.

## What You'll Learn
- Monitor Docker container resources (CPU, Memory)
- Create stress tests to push resources beyond 50%
- View monitoring data in terminal and web dashboard
- Set up automated monitoring with cron

## Setup (5 minutes)

### 1. Create Project Structure
```bash
# Create project directory
mkdir container-monitoring
cd container-monitoring

# Create subdirectories
mkdir app stress monitor logs
```

### 2. Download Required Files
Copy all provided files into their respective directories:
- `docker-compose.yml` - Main configuration
- `monitor_container.sh` - Monitoring script
- `app/index.html` - Web application
- `stress/` - Stress testing files
- `monitor/` - Monitor container files

### 3. Make Scripts Executable
```bash
chmod +x monitor_container.sh
```

## Start the System

### 1. Launch Everything
```bash
# Start application and monitoring

docker-compose up --build 
# or
docker-compose up -d


# Check if everything is running
docker ps
```

You should see:
- `monitored-app` - The web application
- `live-monitor` - The monitoring service

### 2. Access the Dashboard
Open your browser and go to:
```
http://localhost:8000
```

You'll see a real-time monitoring dashboard with:
- CPU usage gauge
- Memory usage gauge  
- Historical charts
- Recent alerts

## Generate High CPU/Memory Usage

### Method 1: Simple Load Test
```bash
# Generate medium load (30-40% CPU)
docker-compose run --rm -e STRESS_LEVEL=medium stress-generator
```

### Method 2: High Load (50%+ CPU)
```bash
# Generate high load (60-70% CPU)
docker-compose run --rm -e STRESS_LEVEL=high stress-generator
```

### Method 3: Maximum Load (80%+ CPU)
```bash
# Open 2-3 terminals and run these simultaneously:

# Terminal 1
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator

# Terminal 2  
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator
```

## Monitor in Different Ways

### 1. Web Dashboard (Recommended)
- Go to http://localhost:8000
- Watch CPU/Memory gauges change in real-time
- See historical chart update every 2 seconds

### 2. Terminal Live Monitor
```bash
# Option A: View Docker container logs
docker logs -f live-monitor

# Option B: Run locally
./monitor_container.sh live
```

### 3. Check Logs
```bash
# View monitoring logs
tail -f logs/container_monitor.log

# View alerts
tail -f logs/container_alerts.log
```

### 4. Generate Report
```bash
./monitor_container.sh report
```

## Understanding the Output

### Dashboard Elements
- **Green Gauge**: Low usage (0-60%)
- **Yellow Gauge**: Medium usage (60-80%)
- **Red Gauge**: High usage (80-100%)
- **Alerts**: Show when thresholds are exceeded

### Terminal Monitor
- **🟢 Running**: Container is active
- **CPU Usage**: Shows percentage with color bar
- **Memory Usage**: Shows percentage with color bar
- **🔴 Alerts**: High CPU/Memory warnings

## Common Tasks

### Check Container Resources
```bash
# See current usage
docker stats monitored-app
```

### Stop Stress Test
```bash
# Press Ctrl+C in the terminal running stress test
# Or find and stop specific container
docker ps | grep stress
docker stop <container-id>
```

### View All Running Containers
```bash
docker ps
```

### Clean Up Everything
```bash
# Stop all containers
docker-compose down

# Remove orphan containers
docker-compose down --remove-orphans
```

## Automated Monitoring (Optional)

### Set Up Cron Job
```bash
# Add to crontab (runs every 10 minutes)
(crontab -l 2>/dev/null; echo "*/10 * * * * $(pwd)/monitor_container.sh monitor >> $(pwd)/logs/cron_monitor.log 2>&1") | crontab -
```

### View Cron Logs
```bash
tail -f logs/cron_monitor.log
```

## Troubleshooting

### Container Not Starting
```bash
docker-compose logs monitored-app
docker-compose logs live-monitor
```

### Dashboard Not Loading
```bash
# Check if monitor is running
docker ps | grep live-monitor

# Check monitor logs
docker logs live-monitor
```

### High Resource Usage Not Showing
```bash
# Make sure to use high stress levels
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator

# Run multiple instances simultaneously
docker-compose run --rm -e STRESS_LEVEL=high stress-generator &
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator &
```

## Key Points to Remember

1. The web dashboard auto-refreshes every 2 seconds
2. Use `--rm` flag with stress tests to auto-cleanup
3. Run multiple stress generators to achieve higher usage
4. Dashboard shows both real-time and historical data
5. Alerts appear when thresholds are exceeded (CPU: 40%, Memory: 80%)

## Quick Commands Reference

```bash
# Start everything
docker-compose up -d

# View dashboard
open http://localhost:8000

# Generate load
docker-compose run --rm -e STRESS_LEVEL=high stress-generator

# View live monitor
docker logs -f live-monitor

# Generate report
./monitor_container.sh report

# Stop everything
docker-compose down
```

That's it! You now have a complete container monitoring system with visual feedback.
