FROM ljocha/gromacs:2019.4.30-1

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

ARG INTELPYTHON=l_pythoni3_p_2019.4.088.tar.gz

#RUN apt update  && apt upgrade -y && apt install -y pkg-config libopenbabel-dev openbabel swig && apt clean
# RUN apt update  && apt upgrade -y && apt clean

COPY ${INTELPYTHON} /tmp
RUN cd /opt && tar xzf /tmp/${INTELPYTHON} && cd intelpython3 && ./setup_intel_python.sh && echo source /opt/intelpython3/bin/activate  >>/etc/bash.bashrc && rm /tmp/${INTELPYTHON}

# RUN bash -c "source /opt/intelpython3/bin/activate && conda update -y --all && conda install -y -c openbabel openbabel && conda install -y --freeze-installed -c conda-forge pypdb pydoe mdtraj nglview && conda install -y notebook pandas"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y notebook pandas"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c openbabel openbabel"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y --freeze-installed -c conda-forge pypdb pydoe mdtraj nglview"


RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c intel tensorflow keras"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y --freeze-installed -c spiwokv anncolvar"

# set externally to match the running env
# ENV USER xxx
# ENV UID xxx

RUN apt update && apt install -y libxrender1 libxext6 && apt clean
RUN bash -c "source /opt/intelpython3/bin/activate && jupyter-nbextension enable nglview --py --sys-prefix"

ARG NB_USER=jupyter
ARG NB_UID=1001

ENV HOME /home/$NB_USER
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

COPY *.ipynb *.template minim.sh ${HOME}/
RUN chown -R ${NB_UID} ${HOME}

USER $NB_USER
WORKDIR $HOME

CMD bash -c "sleep 2 && source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"
