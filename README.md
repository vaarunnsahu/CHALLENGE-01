🛡️ Container Monitoring Exercise
🔍 Real-Time Resource Monitoring + Load Simulation for Dockerized Apps
Take control of your containers with real-time monitoring, automated alerting, and live stress testing — all packed into one powerful, minimal setup. Perfect for DevOps engineers, performance testers, or curious developers eager to visualize how containers behave under pressure.

![image](https://github.com/user-attachments/assets/64e2acae-8434-4c1b-a742-78267f36a412)

🎯 What You’ll Master
📊 Monitor Docker containers (CPU, Memory) in real-time

💥 Simulate high CPU and memory usage with stress generators

🌐 View data in both terminal & web dashboards

⏱️ Automate monitoring with cron jobs

🛠️ Learn how to respond to resource spikes like a pro

⚙️ Setup: From Zero to Monitoring in 5 Minutes
1️⃣ Project Structure
bash
Copy
Edit
# Create base directory
mkdir container-monitoring && cd container-monitoring

# Organize components
mkdir app stress monitor logs
2️⃣ Add the Essentials
Place the following files in their respective directories:

File / Folder	Destination
docker-compose.yml	Root directory
monitor_container.sh	Root directory
app/index.html	app/
stress/ files	stress/
monitor/ files	monitor/

3️⃣ Permissions
bash
Copy
Edit
chmod +x monitor_container.sh
Make sure the monitor script is executable.

🚀 Launch the System
bash
Copy
Edit
docker-compose up --build
# OR
docker-compose up -d
Check running containers:

bash
Copy
Edit
docker ps
✅ You should see:

monitored-app (your test application)

live-monitor (the monitoring service)

🌐 Access Your Dashboard
Visit: http://localhost:8000

You’ll see:

✅ Real-time gauges for CPU & Memory

📈 Live-updating historical charts

⚠️ Alert logs when thresholds are breached

🔥 Generate Load Like a Chaos Engineer
🟡 Moderate Load (30–40% CPU)
bash
Copy
Edit
docker-compose run --rm -e STRESS_LEVEL=medium stress-generator
🟠 High Load (60–70% CPU)
bash
Copy
Edit
docker-compose run --rm -e STRESS_LEVEL=high stress-generator
🔴 Maximum Load (80%+ CPU & Memory)
Run multiple stress generators simultaneously:

bash
Copy
Edit
# Terminal 1
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator

# Terminal 2
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator
📡 Monitoring Options
1. 🖥️ Web Dashboard (Recommended)
Live charts, gauges, and alert logs auto-refresh every 2 seconds.

2. 🧪 Terminal View
bash
Copy
Edit
# Real-time logs
docker logs -f live-monitor

# Or use the native monitor script
./monitor_container.sh live
3. 📄 Log Files
bash
Copy
Edit
# Monitor logs
tail -f logs/container_monitor.log

# Alert logs
tail -f logs/container_alerts.log
4. 📊 Generate Performance Report
bash
Copy
Edit
./monitor_container.sh report
Saves a snapshot of system performance metrics.

🧠 Understand the Output
Dashboard Gauge Colors
🟢 Low: 0–60%

🟡 Moderate: 60–80%

🔴 High: 80–100%

Terminal Symbols
🟢 Container Active

🔴 Alert Triggered

📉 Usage displayed with dynamic bars

🛠️ Common Operations
bash
Copy
Edit
# View app resource usage
docker stats monitored-app

# Stop running stress test
docker ps | grep stress
docker stop <container-id>

# Stop all services
docker-compose down
⏰ Bonus: Automated Monitoring with Cron
Run the monitor every 10 minutes:

bash
Copy
Edit
(crontab -l 2>/dev/null; echo "*/10 * * * * $(pwd)/monitor_container.sh monitor >> $(pwd)/logs/cron_monitor.log 2>&1") | crontab -
📂 View logs:

bash
Copy
Edit
tail -f logs/cron_monitor.log
🧯 Troubleshooting Guide
Problem	Solution
❌ Dashboard not loading	docker ps | grep live-monitor + check logs
🔍 Container not starting	docker-compose logs monitored-app
📉 No spike on dashboard	Use extreme or run multiple stressors

🧾 Quick Command Cheatsheet
bash
Copy
Edit
# Start everything
docker-compose up -d

# View dashboard
open http://localhost:8000

# Apply stress
docker-compose run --rm -e STRESS_LEVEL=high stress-generator

# Monitor in terminal
docker logs -f live-monitor

# Create report
./monitor_container.sh report

# Stop everything
docker-compose down
🏁 Final Thoughts
You now have a lightweight but powerful container monitoring system at your fingertips. Use it to:

✅ Test before scaling

🔍 Investigate resource issues

💥 Simulate real-world scenarios

⚙️ Automate monitoring in CI/CD pipelines

