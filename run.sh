#!/bin/bash

image=ljocha/chicken-and-egg:latest

docker=docker
which nvidia-docker && docker=nvidia-docker

# $docker run -p 9000:9000 -v $PWD:/home/$USER/MOUNTED ljocha/chicken-and-egg:latest bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"

id=$($docker run -e OMP_NUM_THREADS -u 0 -p 9000:9000 -d -v $PWD:/home/jupyter/MOUNTED $image bash -c "chown $(id -u) /home/jupyter; while true; do sleep 365d; done")

trap "$docker kill $id" EXIT

$docker exec -u $(id -u) $id bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"
