#!/bin/bash

image=ljocha/chicken-and-egg:$(cat VERSION)

port=${1:-9000}

docker=docker
which nvidia-docker && docker=nvidia-docker

gid=$(stat -c %g /var/run/docker.sock)

gpu=''
if [ $($docker -v | sed 's/Docker version //; s/\..*$//;') -ge 19 ]; then
	gpu="--gpus all"
fi

if [ -n "$NOGPU" ]; then
	gpu=""
fi

KMP_INIT_AT_FORK=FALSE
export KMP_INIT_AT_FORK

$docker run -ti $gpu -e WORKDIR_OUTSIDE=$PWD -e KMP_INIT_AT_FORK -e OMP_NUM_THREADS -u $(id -u):$gid -p $port:$port -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/work $image jupyter notebook --ip 0.0.0.0 --port $port
