#!/usr/bin/env bash
set -euo pipefail
REGION=us-east-1
REGISTRY=174429081191.dkr.ecr.$REGION.amazonaws.com
IMAGE=$REGISTRY/final-project-stats-service:latest

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY
docker pull $IMAGE
docker rm -f stats-service 2>/dev/null || true

docker run -d --name stats-service --restart unless-stopped -p 8081:8081 \
  -e VISITS_SERVICE_URL=http://__VISITS_IP__:8080 \
  -e ALLOWED_ORIGIN=__ORIGIN__ \
  $IMAGE
sleep 5
docker ps --filter name=stats-service --format '{{.Names}} {{.Status}}'
