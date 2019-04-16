#!/bin/bash

SINGULARITY_DOCKER_USERNAME="$CI_REGISTRY_USER"
SINGULARITY_DOCKER_PASSWORD="$CI_JOB_TOKEN"

export SINGULARITY_DOCKER_USERNAME SINGULARITY_DOCKER_PASSWORD

echo u=$CI_REGISTRY_USER
echo p=$CI_REGISTRY_PASSWORD
echo t=$CI_JOB_TOKEN

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}

docker build --pull -t ljocha/singularity singularity &&
docker run --privileged -v $PWD/singularity:/mnt ljocha/singularity /mnt/build-inside.sh "$CI_REGISTRY" "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY_IMAGE"
