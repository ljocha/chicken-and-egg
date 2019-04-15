#!/bin/bash

IMAGE=${CI_REGISTRY_IMAGE:-ljocha}

docker build -t ljocha/singularity singularity &&
docker run -v $PWD/singularity:/mnt ljocha/singularity singularity build -w chicken-and-egg.img docker://$IMAGE/chicken-and-egg
