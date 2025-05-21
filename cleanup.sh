#!/bin/bash
#
# Cleanup script to remove orphan containers
#

echo "Cleaning up environment..."

# Stop all running containers
echo "Stopping containers..."
docker-compose down

# Remove orphan containers
echo "Removing orphan containers..."
docker-compose down --remove-orphans

# Clean up stress generator containers
echo "Cleaning up stress generator containers..."
docker ps -a | grep "stress-generator" | awk '{print $1}' | xargs -r docker rm -f

# Clean up stopped containers
echo "Removing stopped containers..."
docker container prune -f

echo "Cleanup complete!"
