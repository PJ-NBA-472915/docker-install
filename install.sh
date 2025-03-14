#!/bin/bash

# Update package lists
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Install docker-compose-plugin (if available in your distro's repos, will fail gracefully if it is not)
sudo apt-get install -y docker-compose-plugin 2>/dev/null || true

# Set DOCKER_CONFIG if not already set
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}

# Create cli-plugins directory
mkdir -p "$DOCKER_CONFIG/cli-plugins"

# Download Docker Compose
curl -SL https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64 -o "$DOCKER_CONFIG/cli-plugins/docker-compose"

# Make Docker Compose executable
chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

# Create plugin directory in /usr/local/lib/docker/
sudo mkdir -p /usr/local/lib/docker/cli-plugins/

# Move the docker compose binary into the plugins directory
sudo mv "$DOCKER_CONFIG/cli-plugins/docker-compose" /usr/local/lib/docker/cli-plugins/

# Make the docker compose binary executable in the plugins directory
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Create a symbolic link (not necessary after moving, but kept for completeness)
sudo ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose

# Verify installation (optional)
echo "Docker Compose installation complete."
docker compose ps
