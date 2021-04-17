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

RUN git clone ${PEPTIDEBUILDER} && cd PeptideBuilder && git checkout bef233ac973700d72c40cce8417c2ada6fa40856  && tar cf - PeptideBuilder | (cd ${ipy}/lib/python3.7/ && tar xf -)

RUN git clone https://github.com/spiwokv/anncolvar.git && cd anncolvar && git checkout 1cdb4f8866f3f39880415abaa095423cebc2fa03 && iconv -f utf-8 -t ascii//TRANSLIT README.rst >README.$$ && mv README.$$ README.rst
RUN cd anncolvar && ${ipy}/bin/python3 setup.py install

ARG distribution=ubuntu18.04
RUN apt install -y curl gnupg

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" >>/etc/apt/sources.list

RUN curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
RUN curl -s -L -o /etc/apt/sources.list.d/nvidia-docker.list https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list 

RUN apt update && apt install -y docker-ce-cli nvidia-container-toolkit
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN bash -c "echo 'deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list"
RUN apt update && apt install -y kubectl
RUN apt clean


WORKDIR /work
ENV HOME /work
RUN mkdir -p /work
RUN chown 1001:1001 /work

RUN mkdir /opt/chicken-and-egg/
COPY chicken-and-egg.ipynb ions.mdp md.mdp.template minim-sol.mdp minim.mdp.template minim.sh ncores.sh npt.mdp nvt.mdp xvg.py config.py start-notebook.sh gmx-k8s /opt/chicken-and-egg/
ENV PATH ${ipy}/bin:/opt/chicken-and-egg:${PATH}
