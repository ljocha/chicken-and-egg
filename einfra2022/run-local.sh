#!/bin/sh

#docker run -p 8888:8888 -u $(id -u) -ti -v /tmp:/work -v $PWD:/work/einfra2022 -v $PWD/1L2Y:/work/1L2Y ljocha/chicken-and-egg:latest jupyter notebook --ip 0.0.0.0
docker run -p 8888:8888 -u $(id -u) -ti -v /tmp:/work -v $PWD:/work/einfra2022 -v $PWD/1L2Y:/work/1L2Y ljocha/chicken-and-egg:latest bash
