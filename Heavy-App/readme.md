⚙️ System Stress Testing Stack
Welcome to your one-stop solution for resilience testing — a fully Dockerized setup with:

🚀 A production-like main application

📊 A real-time monitoring dashboard

💣 A modular stress generator for CPU, memory, and extreme load tests

Ideal for developers, SREs, and DevOps engineers who want to test system behavior under pressure and validate observability pipelines.

🔧 Setup & Launch
Spin up the complete stack in seconds:

bash
Copy
Edit
docker-compose build
docker-compose up -d
This will:

🔨 Build all service containers

🧬 Launch the app + monitoring tools in detached mode

✅ Make everything ready for stress tests & observability

🌍 Access the Interfaces
Service	URL
🖥️ Main Application	http://localhost:8080
📈 Monitoring Dashboard	http://localhost:8000

🔥 Stress Testing: Simulate Real-World Chaos
Test how your system responds to various stress levels using our built-in stress-generator. Perfect for benchmarking and chaos engineering.

🔁 CPU-Intensive Load
bash
Copy
Edit
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator
Simulates high CPU utilization. Ideal for testing throttling, scaling triggers, and compute bottlenecks.

🧠 Memory-Intensive Load
bash
Copy
Edit
docker-compose run --rm -e STRESS_LEVEL=memory-intensive stress-generator
Floods memory to uncover memory leaks, GC pressure, and out-of-memory behavior.

💥 Extreme Load (CPU + Memory + I/O)
bash
Copy
Edit
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator
Push your system to its limits. This test hits everything at once: CPU, memory, and disk I/O. Chaos approved.

🧹 Clean Up
When you’re done experimenting:

bash
Copy
Edit
docker-compose down
This will gracefully stop and remove all containers.

🧰 What’s Inside?
Dockerized App: A mock or real app to test

Grafana + Prometheus: Preconfigured for instant visibility

Stress Generator: Trigger stress profiles with one command

✅ Why This Matters
Run pre-deployment stress tests on staging

Validate autoscaling & alerting rules

Benchmark application resilience under chaos

Practice failure scenarios before they happen in production

📎 Prerequisites
Docker (v20+)

Docker Compose (v2.0+)

Unix-based OS recommended for stress-ng compatibility

🙌 Contribute
Found a bug? Have an idea? Open an issue or submit a PR — we welcome contributions from fellow chaos engineers 💥
