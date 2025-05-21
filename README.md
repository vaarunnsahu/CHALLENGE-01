# Container Monitoring System

A comprehensive solution for monitoring Docker containers with real-time metrics visualization, alerts, and performance tracking.

## Overview

This project demonstrates a complete container monitoring solution that provides real-time insights into container health, performance metrics, and system status. The system consists of multiple components working together to collect, process, visualize, and alert on container metrics.

![image](https://github.com/user-attachments/assets/28416b30-2ba5-47e5-adda-1e165d06b21c)

## What This Project Demonstrates

- **Real-time Container Monitoring**: Track CPU, memory usage, and application response time
- **Visual Dashboard**: Interactive charts for performance visualization
- **Status Tracking**: Clear visualization of container uptime/downtime periods
- **Alert System**: Real-time alerts for performance issues and health check failures
- **Email Notifications**: Configurable email alerts for critical issues
- **Stress Testing**: Simulate different load scenarios to test monitoring effectiveness

## Architecture and Flow

The system consists of the following components:

1. **Web Application (flask-app)**
   - A Flask-based web application that serves as the monitored target
   - Includes endpoints that can generate CPU, memory, and database load
   - Provides a /health endpoint for status checking

2. **Monitoring Dashboard (app-monitor)**
   - Collects container metrics using Docker API
   - Processes and stores metrics data
   - Provides a real-time web dashboard for visualization
   - Detects threshold violations and generates alerts

3. **Alert Service**
   - Monitors alert logs for critical issues
   - Aggregates and filters alerts to prevent notification spam
   - Sends email notifications using AWS SES

4. **Stress Generator**
   - Creates configurable loads on the web application
   - Supports different stress profiles (CPU-intensive, memory-intensive, etc.)
   - Helps demonstrate monitoring and alert functionality

5. **Database (PostgreSQL)**
   - Stores application data and metrics
   - Used by the web application for database-intensive operations

## Data Flow

1. The monitoring service collects metrics from Docker at regular intervals
2. Metrics are processed and stored in CSV files and in-memory data structures
3. When thresholds are exceeded, alerts are written to the alert log
4. The dashboard visualizes current and historical metrics through charts
5. The alert service detects new alerts and sends email notifications
6. The stress generator creates load to demonstrate how the system responds

## Key Features

### Dashboard Features

- **Container Status**: Shows if the container is running or stopped
- **CPU Usage**: Real-time CPU percentage with visual gauge
- **Memory Usage**: Memory consumption with percentage and absolute values
- **Response Time**: Application response time in milliseconds
- **Uptime Tracking**: Binary up/down visualization showing exactly when the container was unavailable
- **Latency Chart**: Historical view of response times
- **Resource Metrics**: Combined view of CPU and memory usage trends
- **Alert Display**: Most recent alerts with timestamps

### Alert System Features

- **Threshold-Based Alerts**: Triggers on high CPU, memory, slow response, and health check failures
- **Email Notifications**: Configurable delivery to multiple recipients
- **Alert Aggregation**: Groups similar alerts to prevent notification spam
- **Alert Buffering**: Configurable delay to collect related alerts before sending
- **Rate Limiting**: Cooldown period to prevent excessive notifications
- **Prioritization**: Critical alerts (like container down) bypass aggregation delay

## Setup and Usage

### Prerequisites

- Docker and Docker Compose
- AWS account with SES access (for email alerts)

### Environment Setup

1. Create a `.env` file based on the provided `.env-sample`:

```
# AWS SES Configuration
AWS_ACCESS_KEY_ID=your_aws_access_key_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_key_here
AWS_REGION=ap-south-1

# Email Configuration
SENDER_EMAIL=monitoring@yourdomain.com
RECIPIENT_EMAILS=admin@yourdomain.com,devops@yourdomain.com

# Optional: Alert Configuration (uncomment to override defaults)
# CHECK_INTERVAL=30        # How often to check for new alerts (seconds)
# ALERT_COOLDOWN=300      # Minimum time between similar alerts (seconds)
# BUFFER_TIMEOUT=60       # Time to buffer alerts before sending (seconds)
```

### Starting the System

1. Clone the repository and navigate to the project directory
2. Start the entire stack:
   ```bash
   docker-compose up --build
   ```
   
   Alternatively, run in detached mode:
   ```bash
   docker-compose up -d
   ```

### Accessing the Services

- **Main Application**: http://localhost:8080
- **Monitoring Dashboard**: http://localhost:8001

### Testing Different Load Scenarios

You can generate different types of stress on the system to see how the monitoring responds:

```bash
# CPU-intensive stress
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator

# Memory-intensive stress
docker-compose run --rm -e STRESS_LEVEL=memory-intensive stress-generator

# Extreme stress (high load on everything)
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator
```

## Alert Configuration

The alert service can be configured through environment variables:

- `CHECK_INTERVAL`: How often to check for new alerts (seconds)
- `ALERT_COOLDOWN`: Minimum time between similar alerts (seconds)
- `BUFFER_TIMEOUT`: Time to buffer alerts before sending (seconds)

Threshold values can be configured in the docker-compose.yaml file:

```yaml
monitor:
  environment:
    - CPU_THRESHOLD="40"        # Alert when CPU exceeds this percentage
    - MEMORY_THRESHOLD="50"     # Alert when memory exceeds this percentage
    - RESPONSE_TIME_THRESHOLD=1000  # Alert when response time exceeds this (ms)
```
Start the System
1. Launch Everything
# Start application and monitoring

docker-compose up --build 
# or
docker-compose up -d


# Check if everything is running
docker ps
You should see:

monitored-app - The web application
live-monitor - The monitoring service
2. Access the Dashboard
Open your browser and go to:

http://localhost:8000
You'll see a real-time monitoring dashboard with:

CPU usage gauge
Memory usage gauge
Historical charts
Recent alerts
Generate High CPU/Memory Usage
Method 1: Simple Load Test
# Generate medium load (30-40% CPU)
docker-compose run --rm -e STRESS_LEVEL=medium stress-generator
Method 2: High Load (50%+ CPU)
# Generate high load (60-70% CPU)
docker-compose run --rm -e STRESS_LEVEL=high stress-generator
Method 3: Maximum Load (80%+ CPU)
# Open 2-3 terminals and run these simultaneously:

# Terminal 1
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator

# Terminal 2  
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator
Monitor in Different Ways
1. Web Dashboard (Recommended)
Go to http://localhost:8000
Watch CPU/Memory gauges change in real-time
See historical chart update every 2 seconds
2. Terminal Live Monitor
# Option A: View Docker container logs
docker logs -f live-monitor

# Option B: Run locally
./monitor_container.sh live
3. Check Logs
# View monitoring logs
tail -f logs/container_monitor.log

# View alerts
tail -f logs/container_alerts.log
4. Generate Report
./monitor_container.sh report
Understanding the Output
Dashboard Elements
Green Gauge: Low usage (0-60%)
Yellow Gauge: Medium usage (60-80%)
Red Gauge: High usage (80-100%)
Alerts: Show when thresholds are exceeded
Terminal Monitor
🟢 Running: Container is active
CPU Usage: Shows percentage with color bar
Memory Usage: Shows percentage with color bar
🔴 Alerts: High CPU/Memory warnings
Common Tasks
Check Container Resources
# See current usage
docker stats monitored-app
Stop Stress Test
# Press Ctrl+C in the terminal running stress test
# Or find and stop specific container
docker ps | grep stress
docker stop <container-id>
View All Running Containers
docker ps
Clean Up Everything
# Stop all containers
docker-compose down

# Remove orphan containers
docker-compose down --remove-orphans
Automated Monitoring (Optional)
Set Up Cron Job
# Add to crontab (runs every 10 minutes)
(crontab -l 2>/dev/null; echo "*/10 * * * * $(pwd)/monitor_container.sh monitor >> $(pwd)/logs/cron_monitor.log 2>&1") | crontab -
View Cron Logs
tail -f logs/cron_monitor.log
Troubleshooting
Container Not Starting
docker-compose logs monitored-app
docker-compose logs live-monitor
Dashboard Not Loading
# Check if monitor is running
docker ps | grep live-monitor

# Check monitor logs
docker logs live-monitor
High Resource Usage Not Showing
# Make sure to use high stress levels
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator

# Run multiple instances simultaneously
docker-compose run --rm -e STRESS_LEVEL=high stress-generator &
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator &
Key Points to Remember
The web dashboard auto-refreshes every 2 seconds
Use --rm flag with stress tests to auto-cleanup
Run multiple stress generators to achieve higher usage
Dashboard shows both real-time and historical data
Alerts appear when thresholds are exceeded (CPU: 40%, Memory: 80%)
Quick Commands Reference
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



## Production Considerations

For production deployment, consider the following:

- **Email Sandbox**: AWS SES starts in sandbox mode - verify recipient emails or request production access
- **Secrets Management**: Use Docker secrets or AWS Secrets Manager for credentials
- **Email Templates**: Consider using SES templates for better formatted emails
- **Monitoring**: Add health checks for the alert service itself
- **Persistence**: Mount volumes for logs and metrics to persist between restarts
- **Security**: Run containers with minimal permissions
- **Scaling**: Deploy multiple monitoring instances for high availability

## Troubleshooting

If you encounter issues:

1. Check container logs:
   ```bash
   docker-compose logs monitor
   docker-compose logs alert-service
   ```

2. Verify that the monitored container is running:
   ```bash
   docker ps | grep flask-app
   ```

3. Test the application health endpoint directly:
   ```bash
   curl http://localhost:8080/health
   ```

4. Check alert logs:
   ```bash
   cat logs/container_alerts.log
   ```
![image](https://github.com/user-attachments/assets/b9297087-5576-44ed-9318-b8264e6db5de)
![image](https://github.com/user-attachments/assets/20889259-83b2-43d8-bbe0-582c2fba8c27)


## Customization

The system can be customized by:

1. Modifying alert thresholds in docker-compose.yaml
2. Adjusting the dashboard UI in dashboard.py
3. Adding new metrics collection in monitor_container.sh
4. Creating custom stress patterns in stress_app.py

## License

[MIT License](LICENSE)
