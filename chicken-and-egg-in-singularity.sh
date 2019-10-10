#!/bin/bash


## CUSTOMIZE !!!

WORKDIR=
PDBIN=

[ -d "$WORKDIR" -a -f "$WORKDIR/$PDBIN" ] || { echo WORKDIR must be set, $PDBIN must exist >&2; exit 1; }


cd $SCRATCHDIR || { exit 1; }

mkdir tmp local work

SINGULARITY_TMPDIR=$SCRATCHDIR/tmp 
SINGULARITY_CACHEDIR=$SCRATCHDIR 
SINGULARITY_DOCKER_USERNAME=chicken-and-egg 

# FILL IN 
SINGULARITY_DOCKER_PASSWORD=

DOCKER_IMAGE=registry.gitlab.ics.muni.cz:443/3086/chicken-and-egg:latest

export SINGULARITY_TMPDIR SINGULARITY_CACHEDIR SINGULARITY_DOCKER_USERNAME SINGULARITY_DOCKER_PASSWORD

[ -z "$DONTPULL" ] && singularity pull docker://$DOCKER_IMAGE

NTMPI=1	# good for small molecules

cat - >work/config.py <<EOF
pdbfile = "$PDBIN"
mdsteps = 25000000	# 50 ns is enough
ntmpi = $NTMPI
ntomp = $(($PBS_NUM_PPN	/ $NTMPI))	# XXX: should be divisible
EOF


cp $WORKDIR/$PDBIN work

SINGULARITYENV_OMP_NUM_THREADS=$PBS_NUM_PPN
export SINGULARITYENV_OMP_NUM_THREADS 

# https://github.com/ContinuumIO/anaconda-issues/issues/11294
SINGULARITYENV_KMP_INIT_AT_FORK=FALSE
export SINGULARITYENV_KMP_INIT_AT_FORK

for var in $(env | grep '^PBS_' | sed 's/=.*$//'); do
	unset $var
done

singularity exec --nv \
	-B $SCRATCHDIR/work:/work \
	-B $SCRATCHDIR/local:/home/jupyter/.local \
	chicken-and-egg-latest.simg \
	bash -c 'source /opt/intelpython3/bin/activate && cd /work && cp /home/jupyter/* . && jupyter nbconvert --ExecutePreprocessor.timeout=None --to notebook --execute chicken-and-egg.ipynb' 

#	bash -c 'source /opt/intelpython3/bin/activate && cd /work && cp /home/jupyter/* . && jupyter notebook --ip 0.0.0.0 --port 9000'


cd work && tar cf - *ipynb $(basename $PDBIN .pdb) | (cd $WORKDIR && tar xf -)
