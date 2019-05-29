#!/bin/bash

docker=docker
which nvidia-docker && docker=nvidia-docker

$docker run -p 9000:9000 -v $PWD:/home/$USER/MOUNTED ljocha/chicken-and-egg:latest bash -c "source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"
