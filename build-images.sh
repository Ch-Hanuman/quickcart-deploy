#!/bin/bash

set -e

DOCKERHUB_USERNAME="hanumanchinthapalli"
TAG="latest"

echo "======================================"
echo " Building QuickCart Images: ${TAG}"
echo "======================================"

# Login to Docker Hub
docker login

# Build API Gateway
echo ""
echo "Building API Gateway..."
docker build -t "${DOCKERHUB_USERNAME}/quickcart-api-gateway:${TAG}" ../api-gateway

# Build Inventory Service
echo ""
echo "Building Inventory Service..."
docker build -t "${DOCKERHUB_USERNAME}/quickcart-inventory-service:${TAG}" ../inventory-service

# Build Order Service
echo ""
echo "Building Order Service..."
docker build -t "${DOCKERHUB_USERNAME}/quickcart-order-service:${TAG}" ../order-service

echo ""
echo "======================================"
echo " All Images Built Successfully!"
echo "======================================"

# Push images
echo ""
echo "Pushing images to Docker Hub..."

docker push "${DOCKERHUB_USERNAME}/quickcart-api-gateway:${TAG}"
docker push "${DOCKERHUB_USERNAME}/quickcart-inventory-service:${TAG}"
docker push "${DOCKERHUB_USERNAME}/quickcart-order-service:${TAG}"

echo ""
echo "======================================"
echo " All Images Pushed Successfully!"
echo "======================================"

echo ""
echo "Available QuickCart Images:"
docker images | grep quickcart
