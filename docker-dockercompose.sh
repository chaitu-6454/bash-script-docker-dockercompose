#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "=============================================="
echo "Starting Docker and Docker Compose installation..."
echo "=============================================="

# Update existing packages
echo "Updating packages..."
sudo apt update -y
sudo apt upgrade -y

# Uninstall old versions if any
echo "Removing old Docker versions..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install Docker Engine
echo "Installing Docker Engine..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker installation
echo "Docker version:"
docker --version

# Install standalone Docker Compose (latest)
echo "Installing Docker Compose..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Docker Compose version:"
docker-compose --version

# Add current user to Docker group
echo "Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

# Install Nginx
sudo apt-get install -y nginx

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Install Mysql client
sudo apt-get install mysql-client -y

# Install Certbot and python3-certbot-nginx for automatic Nginx SSL configuration
sudo apt-get install -y certbot python3-certbot-nginx

# Clean up unnecessary files and packages
sudo apt-get autoremove -y
sudo apt-get clean

echo "=============================================="
echo "Installation completed successfully!"
echo "Please log out and log back in to use Docker without sudo."
echo "=============================================="
