#!/bin/bash

INTELPYTHON=l_pythoni3_p_2019.4.088.tar.gz
IMAGE=ljocha/chicken-and-egg
VERSION=:$(cat VERSION)

if [ ! -f "$INTELPYTHON" ]; then
	echo Intel Python distribution is required, download from https://software.intel.com/en-us/distribution-for-python first and copy the tarball here. >&2
	echo Change the filename \($INTELPYTHON\) in this script eventually. >&2
	exit 1
fi

docker build --pull -t $IMAGE$VERSION --build-arg INTELPYTHON=${INTELPYTHON} .
docker tag $IMAGE$VERSION $IMAGE:latest
docker push $IMAGE$VERSION
docker push $IMAGE:latest
