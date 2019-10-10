#!/bin/bash

image=ljocha/chicken-and-egg:latest

port=${1:-9000}

docker=docker
which nvidia-docker && docker=nvidia-docker

# $docker run -p 9000:9000 -v $PWD:/home/$USER/MOUNTED ljocha/chicken-and-egg:latest bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"

# https://github.com/ContinuumIO/anaconda-issues/issues/11294
KMP_INIT_AT_FORK=FALSE
export KMP_INIT_AT_FORK


id=$($docker run -e KMP_INIT_AT_FORK -e OMP_NUM_THREADS -u 0 -p $port:$port -d -v $PWD:/home/jupyter/MOUNTED $image bash -c "chown $(id -u) /home/jupyter; while true; do sleep 365d; done")

trap "$docker kill $id" EXIT


$docker exec -u 0 $id adduser --disabled-password --uid $(id -u) $(id -n -u)
$docker exec -u $(id -u) $id bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port $port"
