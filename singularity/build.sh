#!/bin/bash

SINGULARITY_DOCKER_USERNAME="$CI_REGISTRY_USER"
SINGULARITY_DOCKER_PASSWORD="$CI_REGISTRY_PASSWORD"

export SINGULARITY_DOCKER_USERNAME SINGULARITY_DOCKER_PASSWORD

echo u=$SINGULARITY_DOCKER_USERNAME
echo p=$SINGULARITY_DOCKER_PASSWORD

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}

docker build -t ljocha/singularity singularity &&
docker run -v $PWD/singularity:/mnt ljocha/singularity singularity build -w chicken-and-egg.img docker://$IMAGE/chicken-and-egg
