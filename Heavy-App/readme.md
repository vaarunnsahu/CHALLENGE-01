🚀 Project Setup and Usage
This project includes a main application, monitoring tools, and a stress generator to test application behavior under various system loads. Follow the steps below to get started and simulate stress scenarios.
 🛠️ Build and Start the Application

```bash
docker-compose build
docker-compose up -d
```

This will:

* Build all the necessary Docker images.
* Launch the main application and monitoring services in detached mode.

🌐 Access the Application

Main Application: [http://localhost:8080](http://localhost:8080)
Monitoring Dashboard: [http://localhost:8000](http://localhost:8000)

Use the monitoring dashboard to visualize container metrics in real-time.

💣 Simulate System Load
Use the built-in **stress-generator** to apply various system loads. This is useful for testing your app’s resilience and behavior under pressure.
🔁 CPU-Intensive Stress Test

```bash
docker-compose run --rm -e STRESS_LEVEL=cpu-intensive stress-generator
```

This simulates a high CPU usage scenario, mimicking scenarios like complex computations or unoptimized loops.

🧠 Memory-Intensive Stress Test

```bash
docker-compose run --rm -e STRESS_LEVEL=memory-intensive stress-generator
```

This triggers heavy memory allocation to observe how the system handles memory pressure.

---

 🚨 Extreme Stress Test (CPU + Memory + IO)

```bash
docker-compose run --rm -e STRESS_LEVEL=extreme stress-generator
```

This applies simultaneous stress on **CPU**, **Memory**, and **I/O**, simulating extreme real-world load.


🧹 Cleanup

To stop and remove containers:

```bash
docker-compose down
```

 📦 Requirements

* Docker
* Docker Compose

 📈 Why Use This?

* Test application performance under various system constraints.
* Validate system monitoring and alerting setups.
* Improve system resilience and autoscaling strategies.

---

Feel free to customize and expand this setup to suit your infrastructure testing needs.


