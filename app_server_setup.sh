#!/usr/bin/env bash
set -e

echo "🚀 Setting up Application Server with Docker"

# Update and install Docker
apt-get update -y
apt-get install -y docker.io

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Set permissions on docker socket
chmod 666 /var/run/docker.sock

echo "✅ Docker installation complete!"