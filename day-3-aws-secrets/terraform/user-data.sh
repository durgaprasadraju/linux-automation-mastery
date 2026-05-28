#!/bin/bash

# Update packages
apt-get update -y

# Install Docker and AWS CLI
apt-get install -y docker.io awscli

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Login to AWS ECR
aws ecr get-login-password --region ${region} \
| docker login --username AWS --password-stdin \
${account_id}.dkr.ecr.${region}.amazonaws.com

# Pull Docker image from ECR
docker pull \
${account_id}.dkr.ecr.${region}.amazonaws.com/go-web-app:latest

# Fetch secret from AWS Secrets Manager
APP_SECRET=$(aws secretsmanager get-secret-value \
--secret-id prod/ecommerce/api_key \
--query SecretString \
--output text)

# Run Docker container
docker run -d \
-p 80:8080 \
-e APP_SECRET="$APP_SECRET" \
--name goapp \
${account_id}.dkr.ecr.${region}.amazonaws.com/go-web-app:latest
