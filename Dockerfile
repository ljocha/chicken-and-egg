FROM ljocha/gromacs:2019.10.1-1 

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

ARG INTELPYTHON=l_pythoni3_p_2019.5.098.tar.gz
ARG PEPTIDEBUILDER=https://github.com/mtien/PeptideBuilder.git

RUN apt update && apt install -y libxrender1 libxext6 git && apt clean

COPY ${INTELPYTHON} /tmp
RUN cd /opt && tar xzf /tmp/${INTELPYTHON} && cd intelpython3 && ./setup_intel_python.sh && echo source /opt/intelpython3/bin/activate  >>/etc/bash.bashrc && rm /tmp/${INTELPYTHON}

RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c intel tensorflow=1.14.0 keras=2.2.4"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y notebook=notebook=5.2.2 pandas=0.24.2"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c conda-forge pydoe=0.3.8 mdtraj=1.9.3 nglview=2.7.1"
RUN bash -c "source /opt/intelpython3/bin/activate && jupyter-nbextension enable nglview --py --sys-prefix"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c spiwokv anncolvar=0.6"
RUN bash -c "source /opt/intelpython3/bin/activate && conda install -y -c intel biopython=1.74"

COPY PeptideBuilder.patch /tmp
RUN bash -c "cd /tmp && git clone ${PEPTIDEBUILDER} && cd PeptideBuilder && patch -p1 <../PeptideBuilder.patch && tar cf - PeptideBuilder | (cd /opt/intelpython3/lib/python3.6/ && tar xf -)"

ARG NB_USER=jupyter
ARG NB_UID=1001

ENV HOME /home/$NB_USER
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

COPY *.ipynb *.template minim.sh ncores.sh xvg.py *.mdp ${HOME}/
RUN chown -R ${NB_UID} ${HOME}

USER $NB_USER
WORKDIR $HOME

CMD bash -c "sleep 2 && source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"
