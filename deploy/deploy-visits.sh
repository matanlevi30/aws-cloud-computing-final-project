#!/usr/bin/env bash
set -euo pipefail
REGION=us-east-1
REGISTRY=174429081191.dkr.ecr.$REGION.amazonaws.com
IMAGE=$REGISTRY/final-project-visits-service:latest

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
docker pull $IMAGE
docker rm -f visits-service 2>/dev/null || true

DB_PASSWORD=$(aws ssm get-parameter --region $REGION --name /final-project/db-password --with-decryption --query Parameter.Value --output text)

docker run -d --name visits-service --restart unless-stopped -p 8080:8080 \
  -e DB_HOST=__DB_HOST__ -e DB_NAME=visitsdb -e DB_USER=dbadmin \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e PGSSLMODE=require \
  -e ALLOWED_ORIGIN=__ORIGIN__ \
  $IMAGE
sleep 5
docker ps --filter name=visits-service --format '{{.Names}} {{.Status}}'
