# Unified IIoT Stack Setup

This repository contains the setup script and configuration files for the Unified IIoT Stack.

## Usage

To set up the Unified IIoT Stack, follow these steps:

1. Ensure that Docker and Docker Compose are installed on your system.
2. Open the terminal (CTRL+ALT+T).
3. Run the following command to run the setup script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/moemen-benhamad/unified-iiotstack-setup/main/setup.sh)"
```

4. Wait for the setup process to complete. Once done, you can access the different components of the Unified IIoT Stack as follows:
* Node-RED: http://localhost:1880
* InfluxDB: http://localhost:8086
* Grafana: http://localhost:3000
* Mosquitto MQTT Broker: http://localhost:1883

Feel free to explore and customize the setup according to your needs!
