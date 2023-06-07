#!/bin/bash

# Check if Docker and Docker-compose are is installed and install them if not.

# Define the destination directory
DESTINATION_DIR="/opt/iiotstack"

# Check if the destination directory already exists
if [ ! -d "$DESTINATION_DIR" ]; then
    # Create the destination directory
    mkdir -p "$DESTINATION_DIR"
fi

# Navigate to the destination directory
cd "$DESTINATION_DIR" || exit

# Check if the directories already exist
if [ ! -d "nodered" ] || [ ! -d "influxdb" ] || [ ! -d "grafana" ] || [ ! -d "mosquitto/config" ] || [ ! -d "mosquitto/data" ] || [ ! -d "mosquitto/log" ]; then
    # Create the necessary directories
    mkdir -p nodered influxdb grafana mosquitto/{config,data,log}
fi

# Run the Docker Compose command
docker-compose -f docker-compose.yml up
