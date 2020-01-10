FROM ubuntu:18.04

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

ARG INTELPYTHON=l_pythoni3_p_2020.0.014.tar.gz
ARG PEPTIDEBUILDER=https://github.com/mtien/PeptideBuilder.git

RUN apt update && apt install -y libxrender1 libxext6 git && apt clean

COPY ${INTELPYTHON} /tmp
RUN cd /opt && tar xzf /tmp/${INTELPYTHON} && cd intelpython3 && ./setup_intel_python.sh && echo source /opt/intelpython3/bin/activate  >>/etc/bash.bashrc && rm /tmp/${INTELPYTHON}

ENV USE_DAAL4PY_SKLEARN YES

ARG conda=/opt/intelpython3/bin/conda 
RUN ${conda} install -y -c intel tensorflow=1.14.0 keras=2.2.4
RUN ${conda} install -y notebook=6.0.2
RUN ${conda} install -y -c conda-forge pydoe=0.3.8 mdtraj=1.9.3 nglview=2.7.1
RUN ${conda} install -y -c intel biopython=1.74

ARG ipy=/opt/intelpython3
RUN ${ipy}/bin/jupyter nbextension enable nglview --py --sys-prefix

RUN mkdir  -p ${ipy}/share/jupyter/nbextensions && cd ${ipy}/share/jupyter/nbextensions && git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && ${ipy}/bin/jupyter nbextension enable vim_binding/vim_binding --sys-prefix
 
WORKDIR /tmp
RUN git clone ${PEPTIDEBUILDER} && cd PeptideBuilder && git checkout bef233ac973700d72c40cce8417c2ada6fa40856  && cd .. && tar cf - PeptideBuilder | (cd ${ipy}/lib/python3.7/ && tar xf -)

RUN git clone https://github.com/spiwokv/anncolvar.git && cd anncolvar && git checkout 1cdb4f8866f3f39880415abaa095423cebc2fa03 && iconv -f utf-8 -t ascii//TRANSLIT README.rst >README.$$ && mv README.$$ README.rst
RUN cd anncolvar && ${ipy}/bin/python3 setup.py install

#ARG NB_USER=jupyter
#ARG NB_UID=1001
#
#ENV HOME /home/$NB_USER
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US.UTF-8
#
#RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
#
#COPY *.ipynb *.template minim.sh ncores.sh xvg.py *.mdp ${HOME}/
#RUN chown -R ${NB_UID} ${HOME}

#USER $NB_USER
WORKDIR /work
ENTRYPOINT [ ${ipy}/bin/jupyter ]

#CMD bash -c "sleep 2 && source /opt/intelpython3/bin/activate && jupyter notebook --ip 0.0.0.0 --port 9000"
