
#!/bin/bash
# Update and install docker on Ubuntu
apt-get update -y
apt-get install -y docker.io
sudo chmod 666 /var/run/docker.sock

# Start and enable docker
systemctl start docker
systemctl enable docker

# Run nginx with correct port mapping
docker run -d \
-p 8080:80 \
--name nginx \
--restart unless-stopped \
nginx:latest