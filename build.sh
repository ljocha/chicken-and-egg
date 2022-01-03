#!/bin/bash

source ./docker-image.sh
VERSION=:$(cat VERSION)

docker build -t $IMAGE$VERSION . &&
docker tag $IMAGE$VERSION $IMAGE:latest &&
docker push $IMAGE$VERSION &&
docker push $IMAGE:latest
