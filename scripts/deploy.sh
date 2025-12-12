#!/bin/bash
set -e
APP_NAME=blog
IMAGE=$1
CONTAINER_NAME=${APP_NAME}-container
# Pull the latest image
docker pull ${IMAGE}
# Stop existing container if running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}
fi
# Run new container
docker run -d --name ${CONTAINER_NAME} -p 80:5000 -v /opt/${APP_NAME}/data:/data --restart=always ${IMAGE}
