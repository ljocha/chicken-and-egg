# Chicken and egg in molecular metadynamics

This repo contains a Jupyter notebook to generate random landmarks of a protein strucure, derive appropriate collective variables, and run metadynamics simulation of the protein unfolding-folding.

The notebooks must be run in a Docker container with all the Python dependencies and a prebuilt Gromacs + Plumed separate image downloaded from Dockerhub. Dockerfile defining such container is provided.

Build the container yourself with the provided *build.sh* script and run it with *run.sh* (eventually modifying the container name and port to listen).

If [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) is available, it is used and GPU acceleration works. The current version works with Cuda 10.x only. 
  
The working directory is mounted into the container, as well as */var/run/docker.sock*, so that a sibling container (running gromacs) can be invoked from inside. The notebook creates a subdirectory derived from the PDB input file name, and puts all results there.

In either case, go to *index.ipynb* and enjoy!

## How to cite

A. Křenek, J. Hozzová, J. Olha, D. Trapl, V. Spiwok, 
Exploring Protein Folding Space with Neural Network Guided Simulations,
submitted to ESM 2020.
