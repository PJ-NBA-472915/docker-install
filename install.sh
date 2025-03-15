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
wget -qO "$DOCKER_CONFIG/cli-plugins/docker-compose" https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64

# Make Docker Compose executable
chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

# Create plugin directory in /usr/local/lib/docker/
sudo mkdir -p /usr/local/lib/docker/cli-plugins/

# Move the docker compose binary into the plugins directory
sudo mv "$DOCKER_CONFIG/cli-plugins/docker-compose" /usr/local/lib/docker/cli-plugins/

# Make the docker compose binary executable in the plugins directory
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add user to the docker group so that you can run docker without sudo
sudo usermod -aG docker $USER
sudo chown $USER:docker /var/run/docker.sock 

# Create a symbolic link (not necessary after moving, but kept for completeness)
sudo ln -sf /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose

# Verify installation (optional)
echo "Docker Compose installation complete."
docker compose ps

# Ask user if they want to install NVIDIA drivers
read -p "Do you want to install NVIDIA drivers? (y/n): " install_nvidia

if [[ "$install_nvidia" == "y" ]]; then

    # Install nvidia-detect and linux headers
    sudo apt install -y nvidia-detect linux-headers-$(uname -r)

    # Detect the recommended NVIDIA driver
    recommended_driver=$(nvidia-detect -q)

    # Add Debian Sid repository for latest NVIDIA drivers
    sudo sh -c 'echo "deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware" >> /etc/apt/sources.list'

    # Update package lists again after adding the new repository
    sudo apt-get update

    # Install NVIDIA driver and firmware
    sudo apt install -y nvidia-driver firmware-misc-nonfree

    # Install nvidia-kernel-dkms
    sudo apt install -y nvidia-kernel-dkms

    # Install NVIDIA Container Toolkit
    wget -qO - https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
    wget -qO - https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    # Restart Docker to apply NVIDIA Container Toolkit changes
    sudo systemctl restart docker

    # Verify NVIDIA driver and Container Toolkit installations
    echo "NVIDIA Driver and Container Toolkit Verification:"
    nvidia-smi
    docker info | grep Runtime

fi

# Ask user if they want to reboot
read -p "Do you want to reboot now to load the NVIDIA drivers? (y/n): " reboot_now

if [[ "$reboot_now" == "y" ]]; then
    sudo reboot
fi

echo "Script execution complete."
