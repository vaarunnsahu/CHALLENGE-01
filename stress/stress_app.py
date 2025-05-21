#!/usr/bin/env python3
import os
import time
import random
import requests
import threading
from concurrent.futures import ThreadPoolExecutor

TARGET_URL = os.getenv('TARGET_URL', 'http://web-app')
STRESS_LEVEL = os.getenv('STRESS_LEVEL', 'low')

# Stress level configurations
STRESS_CONFIGS = {
    'low': {'threads': 5, 'requests_per_thread': 10, 'delay': 0.5},
    'medium': {'threads': 20, 'requests_per_thread': 100, 'delay': 0.1},
    'high': {'threads': 50, 'requests_per_thread': 200, 'delay': 0.05},
    'extreme': {'threads': 100, 'requests_per_thread': 5000, 'delay': 0.001},
    'cpu-intensive': {'threads': 200, 'requests_per_thread': 1000, 'delay': 0.001}
}

def generate_load(thread_id, config):
    """Generate load on the target application"""
    for i in range(config['requests_per_thread']):
        try:
            # Random endpoints to vary the load
            endpoints = ['/', '/index.html', '/health', '/non-existent']
            endpoint = random.choice(endpoints)
            
            response = requests.get(f"{TARGET_URL}{endpoint}", timeout=5)
            print(f"Thread {thread_id}: Request {i+1} to {endpoint} - Status: {response.status_code}")
            
            time.sleep(config['delay'])
        except Exception as e:
            print(f"Thread {thread_id}: Error - {str(e)}")

def main():
    config = STRESS_CONFIGS.get(STRESS_LEVEL, STRESS_CONFIGS['low'])
    print(f"Starting stress test - Level: {STRESS_LEVEL}")
    print(f"Configuration: {config}")
    
    while True:
        with ThreadPoolExecutor(max_workers=config['threads']) as executor:
            futures = []
            for i in range(config['threads']):
                future = executor.submit(generate_load, i, config)
                futures.append(future)
            
            # Wait for all threads to complete
            for future in futures:
                future.result()
        
        print(f"Completed cycle. Waiting 10 seconds before next cycle...")
        time.sleep(10)

if __name__ == "__main__":
    main()
