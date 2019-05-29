#!/bin/bash

INTELPYTHON=l_pythoni3_p_2019.4.088.tar.gz

if [ ! -f "$INTELPYTHON" ]; then
	echo Intel Python distribution is required, download from https://software.intel.com/en-us/distribution-for-python first and copy the tarball here. >&2
	echo Change the filename \($INTELPYTHON\) in this script eventually. >&2
	exit 1
fi

docker build --pull -t ljocha/chicken-and-egg:latest --build-arg NB_USER=$USER --build-arg NB_UID=$(id -u) --build-arg INTELPYTHON=${INTELPYTHON} .
