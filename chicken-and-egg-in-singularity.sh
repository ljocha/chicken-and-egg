#!/bin/bash


## CUSTOMIZE !!!

WORKDIR=$HOME/tmp/test-chicken
PDBIN=secret.pdb

[ -d "$WORKDIR" -a -f "$WORKDIR/$PDBIN" ] || { echo WORKDIR must be set, $PDBIN must exist >&2; exit 1; }


cd $SCRATCHDIR || { exit 1; }

mkdir tmp local work

SINGULARITY_TMPDIR=$SCRATCHDIR/tmp 
SINGULARITY_CACHEDIR=$SCRATCHDIR 
SINGULARITY_DOCKER_USERNAME=chicken-and-egg 
SINGULARITY_DOCKER_PASSWORD=2VAqRJQhXh5pwF_4f_oC

DOCKER_IMAGE=registry.gitlab.ics.muni.cz:443/3086/chicken-and-egg:latest

export SINGULARITY_TMPDIR SINGULARITY_CACHEDIR SINGULARITY_DOCKER_USERNAME SINGULARITY_DOCKER_PASSWORD

[ -z "$DONTPULL" ] && singularity pull docker://$DOCKER_IMAGE

echo pdbfile = \"$PDBIN\" >work/config.py
cp $WORKDIR/$PDBIN work

SINGULARITYENV_OMP_NUM_THREADS=$PBS_NUM_PPN
export SINGULARITYENV_OMP_NUM_THREADS 

singularity exec \
	-B $SCRATCHDIR:/scratch \
	-B $SCRATCHDIR/local:/home/jupyter/.local \
	chicken-and-egg-latest.simg \
	bash -c 'source /opt/intelpython3/bin/activate && cd /scratch/work && cp /home/jupyter/* . && jupyter nbconvert --ExecutePreprocessor.timeout=None --to notebook --execute chicken-and-egg.ipynb' 

#	bash -c 'source /opt/intelpython3/bin/activate && cd /scratch/work && cp /home/jupyter/* . && jupyter notebook --ip 0.0.0.0 --port 9000'


cd work && tar cf - *ipynb $(basename $PDBIN) | (cd $WORKDIR && tar xf -)
