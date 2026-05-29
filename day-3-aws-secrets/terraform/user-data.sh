#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "Starting setup..."

apt-get update -y
apt-get install -y docker.io awscli jq

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

ACCOUNT_ID="${account_id}"
REGION="${region}"
SECRET_ID="${secret_id}"

IMAGE_URI="${account_id}.dkr.ecr.${region}.amazonaws.com/go-web-app:latest"

echo "Fetching secret from AWS Secrets Manager..."

APP_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id $SECRET_ID \
  --region $REGION \
  --query SecretString \
  --output text | jq -r '.APP_SECRET')

echo "Logging into ECR..."

aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin \
$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Pulling image..."

docker pull $IMAGE_URI

docker rm -f goapp || true

echo "Running container..."

docker run -d \
--name goapp \
-p 80:8080 \
-e APP_SECRET="$APP_SECRET" \
--restart always \
$IMAGE_URI

echo "Done"