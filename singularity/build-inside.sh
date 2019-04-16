#!/bin/sh

set +x

DOCKER_REGISTRY=$1
DOCKER_USER=$2
DOCKER_PASSWORD=$3
IMAGE=$4

dockerd&

docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD" "$DOCKER_REGISTRY"
docker pull $IMAGE/chicken-and-egg

singularity --debug build -w chicken-and-egg.img docker://$IMAGE/chicken-and-egg

