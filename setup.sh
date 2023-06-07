#!/bin/bash

# Check if Docker and Docker-compose are is installed and install them if not.

# Function to check and install Docker and Docker Compose
install_docker() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker not found. Installing Docker..."
        # Install Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh || {
            echo "Failed to install Docker."
            rm get-docker.sh
            exit 1
        }
        sudo usermod -aG docker $USER || {
            echo "Failed to add user to the docker group."
            rm get-docker.sh
            exit 1
        }
        rm get-docker.sh
        echo "Docker installed successfully."
    else
        echo "Docker is already installed."
    fi

    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose not found. Installing Docker Compose..."
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || {
            echo "Failed to install Docker Compose."
            exit 1
        }
        sudo chmod +x /usr/local/bin/docker-compose || {
            echo "Failed to set execute permission on Docker Compose."
            exit 1
        }
        echo "Docker Compose installed successfully."
    else
        echo "Docker Compose is already installed."
    fi
}

# Define the destination directory
DESTINATION_DIR="/opt/iiotstack"

# Check if the destination directory already exists
if [ ! -d "$DESTINATION_DIR" ]; then
    # Create the destination directory
    mkdir -p "$DESTINATION_DIR" || {
        echo "Failed to create the destination directory."
        exit 1
    }
    DESTINATION_DIR_CREATED=true
fi

# Navigate to the destination directory
cd "$DESTINATION_DIR" || {
    echo "Failed to navigate to the destination directory."
    exit 1
}

# Check if the directories already exist
if [ ! -d "nodered" ] || [ ! -d "influxdb" ] || [ ! -d "grafana" ] || [ ! -d "mosquitto/config" ] || [ ! -d "mosquitto/data" ] || [ ! -d "mosquitto/log" ]; then
    # Create the necessary directories
    mkdir -p nodered influxdb grafana mosquitto/{config,data,log} || {
        echo "Failed to create the necessary directories."
        if [ "$DESTINATION_DIR_CREATED" = true ]; then
            rm -rf "$DESTINATION_DIR"
            echo "Destination directory reverted."
        fi
        exit 1
    }
    DIRECTORIES_CREATED=true
fi

# Check and install Docker and Docker Compose
install_docker || {
    echo "Failed to install Docker and Docker Compose."
    if [ "$DIRECTORIES_CREATED" = true ]; then
        rm -rf "$DESTINATION_DIR"
        echo "Destination directory reverted."
    fi
    exit 1
}

# Run the Docker Compose command
docker-compose -f docker-compose.yml up || {
    echo "Failed to run Docker Compose."
    if [ "$DIRECTORIES_CREATED" = true ]; then
        rm -rf "$DESTINATION_DIR"
        echo "Destination directory reverted."
    fi
    exit 1
}
