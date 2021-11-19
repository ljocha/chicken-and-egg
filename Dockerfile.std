FROM ubuntu:18.04

USER root

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Europe/Prague

ARG PEPTIDEBUILDER=https://github.com/mtien/PeptideBuilder.git

RUN apt update && apt install -y libxrender1 libxext6 git 

ENV USE_DAAL4PY_SKLEARN YES

RUN apt install -y python3-pip
RUN pip3 install tensorflow keras
RUN pip3 install jupyter  jupyter-packaging
RUN pip3 install cython
RUN apt install -y zlib1g-dev
RUN pip3 install pydoe mdtraj nglview 
RUN pip3 install biopython 

RUN jupyter nbextension enable nglview --py --sys-prefix

ARG ipy=/usr/local

RUN mkdir  -p ${ipy}/share/jupyter/nbextensions && cd ${ipy}/share/jupyter/nbextensions && git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && ${ipy}/bin/jupyter nbextension enable vim_binding/vim_binding --sys-prefix
 
WORKDIR /tmp

RUN git clone ${PEPTIDEBUILDER} && cd PeptideBuilder && git checkout bef233ac973700d72c40cce8417c2ada6fa40856  && tar cf - PeptideBuilder | (cd ${ipy}/lib/python3.6/ && tar xf -)

RUN git clone https://github.com/spiwokv/anncolvar.git && cd anncolvar && git checkout 1cdb4f8866f3f39880415abaa095423cebc2fa03 && iconv -f utf-8 -t ascii//TRANSLIT README.rst >README.$$ && mv README.$$ README.rst
RUN cd anncolvar && python3 setup.py install

ARG distribution=ubuntu18.04
RUN apt install -y curl gnupg

RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN bash -c "echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list"
RUN apt update && apt install -y kubectl
RUN apt clean


WORKDIR /work
ENV HOME /work
RUN mkdir -p /work
RUN chown 1001:1001 /work

RUN mkdir /opt/chicken-and-egg/
COPY chicken-and-egg.ipynb ions.mdp md.mdp.template minim-sol.mdp minim.mdp.template minim.sh ncores.sh npt.mdp nvt.mdp xvg.py config.py start-notebook.sh gmx-k8s minim-k8s /opt/chicken-and-egg/
ENV PATH ${ipy}/bin:/opt/chicken-and-egg:${PATH}

# RUN apt update && apt install -y strace
