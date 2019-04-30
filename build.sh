#!/bin/bash

docker build --pull -t ljocha/chicken-and-egg:latest --build-arg NB_USER=$USER --build-arg NB_UID=$(id -u) .
