#!/bin/bash

workdir=$1

[ -n "$1" ] || { echo usage: $0 workdir [port]; exit 1; }

image=ljocha/chicken-and-egg:latest

# XXX
pdbid=$(basename $workdir)

port=${2:-9000}

echo pdbfile=\"${pdbid}.pdb\" >config.py

docker=docker
which nvidia-docker && docker=nvidia-docker

# $docker run -p 9000:9000 -v $PWD:/home/$USER/MOUNTED ljocha/chicken-and-egg:latest bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"

id=$($docker run -e OMP_NUM_THREADS -u 0 -p $port:$port -d -v $PWD:/home/jupyter/MOUNTED -v $workdir:/home/jupyter/MOUNTED/$pdbid $image bash -c "chown $(id -u) /home/jupyter; while true; do sleep 365d; done")

trap "$docker kill $id" EXIT

$docker exec -u $(id -u) $id bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port $port"
