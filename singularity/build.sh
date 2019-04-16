#!/bin/bash

DOCKER_USERNAME="$CI_REGISTRY_USER"
DOCKER_PASSWORD="$CI_REGISTRY_PASSWORD"

export DOCKER_USERNAME DOCKER_PASSWORD

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}

docker build -t ljocha/singularity singularity &&
docker run -v $PWD/singularity:/mnt ljocha/singularity singularity build -w chicken-and-egg.img docker://$IMAGE/chicken-and-egg
