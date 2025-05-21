#!/bin/bash
#
# Final setup script for container monitoring with dashboard
#

echo "Setting up container monitoring with web dashboard..."

# Create directory structure
mkdir -p app stress monitor logs

# Copy monitoring script to monitor directory
cp monitor_container.sh monitor/

# Make scripts executable
chmod +x monitor_container.sh cleanup.sh demo_high_usage.sh

# Clean up any orphan containers
echo "Cleaning up orphan containers..."
docker-compose down --remove-orphans

echo ""
echo "Container Monitoring Setup Complete!"
echo "=================================="
echo ""
echo "1. Start the application with monitoring dashboard:"
echo "   docker-compose up -d"
echo ""
echo "2. Access the monitoring dashboard:"
echo "   http://localhost:8000"
echo ""
echo "3. View live terminal monitoring:"
echo "   docker logs -f live-monitor"
echo ""
echo "4. Generate high CPU/memory usage:"
echo "   # In another terminal, run stress tests:"
echo "   docker-compose run --rm -e STRESS_LEVEL=high stress-generator"
echo "   docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator"
echo "   docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator"
echo ""
echo "5. Run multiple stress generators simultaneously:"
echo "   # Terminal 1"
echo "   docker-compose run --rm -e STRESS_LEVEL=high stress-generator"
echo "   "
echo "   # Terminal 2"
echo "   docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator"
echo ""
echo "6. Clean up orphan containers:"
echo "   ./cleanup.sh"
echo ""
echo "7. View logs:"
echo "   # Monitoring logs"
echo "   tail -f logs/container_monitor.log"
echo "   "
echo "   # Alert logs"
echo "   tail -f logs/container_alerts.log"
echo ""
echo "8. Stop everything:"
echo "   docker-compose down"
echo ""
echo "Tips:"
echo "- Dashboard auto-refreshes every 2 seconds"
echo "- Charts show historical CPU and memory usage"
echo "- Alerts are displayed in real-time"
echo "- Use --rm flag with stress tests to auto-cleanup"
echo ""
