#!/bin/bash
set -euxo pipefail

apt-get update
apt-get install -y docker.io curl
systemctl enable --now docker

docker run -d --name recovery-web --restart unless-stopped -p 80:80 nginx:alpine

echo "EC2 recovery lab initialization complete"
