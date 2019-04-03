FROM ljocha/gromacs:2018.6-plumed2.5

USER root
RUN apt-get update && apt-get install -y python-pip  && apt clean
RUN pip install --no-cache-dir notebook==5.*

ARG NB_USER=ljocha
ARG NB_UID=1000

COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}

USER $NB_USER
