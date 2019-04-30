FROM ljocha/gromacs:2019.4.30-1

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

RUN apt update 
RUN apt install -y python3-pip  
# RUN apt install -y pymol 
RUN apt install -y pkg-config libopenbabel-dev openbabel swig
RUN apt install libz-dev
RUN apt clean

RUN pip3 install --no-cache-dir notebook==5.*

RUN pip3 install numpy scipy sklearn matplotlib 

RUN pip3 install openbabel
RUN pip3 install pypdb 
RUN pip3 install pyDOE 
RUN pip3 install nglview 
RUN pip3 install cython 
RUN pip3 install mdtraj 
RUN pip3 install pandas 

# set externally to match the running env
# ENV USER xxx
# ENV UID xxx

ARG NB_USER=jupyter
ARG NB_UID=1001

ENV HOME /home/$NB_USER
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}

USER $NB_USER
WORKDIR $HOME
