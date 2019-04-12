# Chicken and egg in molecular metadynamics

This repo contains a sequence of Jupyter notebooks to generate random landmarks of a protein strucure, derive appropriate collective variables, and run metadynamics simulation of the protein unfolding-folding.

The notebooks must be run in a Docker container with all the Python dependencies and prebuilt Gromacs + Plumed. Dockerfile defining such container is provided (based on publicly available ljocha/gromacs).

There are several options to run:
* Build the container yourself with the provided *build.sh* script and run it with *run.sh* (eventually modifying the container name and port to listen).

  If [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) is available, it is used and GPU acceleration works. The current version works with Cuda 10.x only. 
  
  The Jupyter working directory is in the container, and the content of the repo (i.e. notebooks, script, input file tempates etc.) are copied ther on build. The *run.sh* also attemts to mount the checked-out repository on `MOUNTED/` subdir in the container. Run the notebooks from there if you want to modify.
* Build the container in the same way, convert to [Singularity](https://singularity.lbl.gov), and run it in your favourite paranoid computing centre which does not allow Docker otherwise
* Run on suitable [Binder](https://binderhub.readthedocs.io) instance where reasonable resources are available (this is not the case with publicly available [mybinder.org](http://mybinder.org)). Just provide link to this repo, the container is build and started by the service.

In either case, go to *index.ipynb* and enjoy!
