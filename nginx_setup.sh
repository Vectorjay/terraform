#!/usr/bin/env bash
set -e

echo "🚀 Setting up Application Server with Docker and Nginx"

# Update package list
apt-get update -y

# Install Docker and Nginx
apt-get install -y docker.io nginx

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Start and enable Nginx
systemctl enable nginx
systemctl start nginx

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Set permissions on docker socket
chmod 666 /var/run/docker.sock

# Confirm Nginx is running
echo "🌐 Nginx status:"
systemctl status nginx --no-pager

echo "✅ Docker and Nginx installation complete!"