#!/bin/bash

# Stop script if any command fails
set -e

# Save logs
exec > /var/log/user-data.log 2>&1

echo "====================================="
echo "Starting EC2 User Data Script"
echo "====================================="

# Update Ubuntu packages
apt-get update -y

# Install Docker and AWS CLI
apt-get install -y docker.io awscli

echo "Docker and AWS CLI installed"

# Start Docker service
systemctl start docker
systemctl enable docker

echo "Docker service started"

# Variables
ACCOUNT_ID="${account_id}"
REGION="${region}"
APP_SECRET="${app_secret}"

IMAGE_URI="${account_id}.dkr.ecr.${region}.amazonaws.com/go-web-app:latest"

echo "ACCOUNT_ID=$ACCOUNT_ID"
echo "REGION=$REGION"
echo "IMAGE_URI=$IMAGE_URI"

# Login to ECR
echo "Logging into ECR..."

aws ecr get-login-password --region $REGION \
| docker login \
--username AWS \
--password-stdin \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "ECR login successful"

# Pull Docker image
echo "Pulling Docker image..."

docker pull $IMAGE_URI

echo "Docker image pulled successfully"

# Remove old container if exists
docker rm -f goapp || true

# Run Docker container
echo "Starting Docker container..."

docker run -d \
--name goapp \
-p 80:8080 \
-e APP_SECRET="$APP_SECRET" \
$IMAGE_URI

echo "Docker container started successfully"

echo "====================================="
echo "User Data Script Completed"
echo "====================================="
