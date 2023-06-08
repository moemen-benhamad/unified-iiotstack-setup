#!/bin/bash

echo ""
echo "___________________________________________________________________________"
echo " "
echo "     ██╗██╗ ██████╗ ████████╗███████╗████████╗ █████╗  ██████╗██╗  ██╗"
echo "     ██║██║██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝"
echo "     ██║██║██║   ██║   ██║   ███████╗   ██║   ███████║██║     █████╔╝"
echo "     ██║██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██║██║     ██╔═██╗"
echo "     ██║██║╚██████╔╝   ██║   ███████║   ██║   ██║  ██║╚██████╗██║  ██╗"
echo "     ╚═╝╚═╝ ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
echo "___________________________________________________________________________"
echo ""                                                                  

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
if [ ! -d "./node-red" ] || [ ! -d "./influxdb/data" ] || [ ! -d "./grafana/data" ] || [ ! -d "./mosquitto" ] || [ ! -d "./portainer/data" ]; then
    # Create the necessary directories
    mkdir -p ./node-red ./influxdb/data ./grafana/data ./mosquitto/ ./portainer/data || {
        echo "Failed to create the necessary directories."
        if [ "$DESTINATION_DIR_CREATED" = true ]; then
            rm -rf "$DESTINATION_DIR"
            echo "Destination directory reverted."
        fi
        exit 1
    }
    DIRECTORIES_CREATED=true
fi

echo "/opt/iiotstack directory created successfully."

# Check and install Docker and Docker Compose
install_docker || {
    echo "Failed to install Docker and Docker Compose."
    if [ "$DIRECTORIES_CREATED" = true ]; then
        rm -rf "$DESTINATION_DIR"
        echo "Destination directory reverted."
    fi
    exit 1
}

# Check if the Docker socket exists
if [ ! -S "/var/run/docker.sock" ]; then
    echo "Error: Docker socket not found. Please make sure Docker is installed and running."
    exit 1
fi

# Add the current user to the docker group if not already a member
if ! groups | grep -q "\bdocker\b"; then
    sudo usermod -aG docker $USER
    echo "Added the current user to the 'docker' group."
    echo "Please log out and log back in to apply the changes."
    echo "Re-run the script again once logged in."
    exit 0
fi

# Download the docker-compose.yml file to the iiotstack directory
curl -LJO https://raw.githubusercontent.com/moemen-benhamad/unified-iiotstack-setup/main/docker-compose.yml || {
    echo "Failed to download the docker-compose.yml file."
    if [ "$DIRECTORIES_CREATED" = true ]; then
        rm -rf "$DESTINATION_DIR"
        echo "Destination directory reverted."
    fi
    exit 1
}

echo "docker-compose.yml file donwloaded successfully."

# Run the Docker Compose command with the correct path to docker-compose.yml
docker-compose -f "$DESTINATION_DIR/docker-compose.yml" up -d || {
    echo "Failed to run Docker Compose."
    if [ "$DIRECTORIES_CREATED" = true ]; then
        rm -rf "$DESTINATION_DIR"
        echo "Destination directory reverted."
    fi
    exit 1
}

echo ""
echo "___________________________________________________________________________"
echo ""
echo "CONGRATS! EVERYTHING IS SETUP ONCE AND FOR ALL! LET THE IIOT JOURNEY BEGIN!"
echo ""
echo "                                __/___            "
echo "                          _____/______|           "
echo "                  _______/_____\_______\_____     "
echo "                  \              < < <       |    "
echo "                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

echo "___________________________________________________________________________"
echo ""
exit



