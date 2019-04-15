FROM ubuntu:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

RUN apt update 
RUN apt install -y singularity-container

WORKDIR /mnt
