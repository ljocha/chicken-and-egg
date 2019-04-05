FROM ljocha/gromacs:2019.4.4-1

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

RUN apt update 
RUN apt install -y python3-pip  
RUN apt install -y pymol 
RUN apt install -y pkg-config libopenbabel-dev swig
RUN apt clean
RUN pip3 install --no-cache-dir notebook==5.*

RUN pip3 install openbabel
RUN pip3 install pypdb 
RUN pip3 install pyDOE 
RUN pip3 install numpy scipy sklearn matplotlib 

ARG NB_USER=ljocha
ARG NB_UID=1000

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}

USER $NB_USER
WORKDIR $HOME
