#!/usr/bin/env bash
set -e

# -----------------------------------
# Auto-switch to root (sudo su - effect)
# -----------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "🔐 Switching to root (sudo su -)"
  exec sudo -i bash "$0"
fi

echo "🚀 Setting up Jenkins with Docker, Node.js, and required tools"
echo "Running as user: $(whoami)"
echo "HOME=$HOME"

# -----------------------------
# Install Docker
# -----------------------------
echo "🐳 Installing Docker..."
apt-get update -y
apt-get install -y docker.io

systemctl enable docker
systemctl start docker
chmod 666 /var/run/docker.sock

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# -----------------------------
# Run Jenkins container
# -----------------------------
echo "📦 Starting Jenkins container..."

if docker ps -a --format '{{.Names}}' | grep -q '^jenkins$'; then
  echo "⚠️ Existing Jenkins container found. Removing..."
  docker rm -f jenkins
fi

docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins container to initialize..."
sleep 15

# -----------------------------
# Install tools inside Jenkins
# -----------------------------
echo "🔧 Installing Node.js, npm, curl, gettext inside Jenkins container..."

docker exec -u root jenkins bash -c "
  set -e
  apt-get update
  apt-get install -y curl gettext
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
  apt-get install -y nodejs
"

# -----------------------------
# Verification
# -----------------------------
echo "✅ Verifying installations inside Jenkins container..."

docker exec -u root jenkins bash -c "
  node --version
  npm --version
"

# -----------------------------
# Done
# -----------------------------
echo ""
echo "🎉 Jenkins setup complete!"
echo "👉 Access Jenkins at: http://<server-ip>:8080"
echo "👉 Initial admin password:"
echo "   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"