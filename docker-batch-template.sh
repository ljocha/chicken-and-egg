#!/bin/bash


## CUSTOMIZE !!!

BASEDIR=
WORKDIR=
PDBIN=__FILENAME__

NTMPI=4	# good for small molecules

[ -d "$WORKDIR" -a -f "$WORKDIR/$PDBIN" ] || { echo WORKDIR must be set, $PDBIN must exist >&2; exit 1; }
[ -d "$SCRATCHDIR" ] || { echo SCRATCHDIR must exist; exit 1; }

cd $BASEDIR && 
	cp chicken-and-egg.ipynb  ions.mdp	 minim-sol.mdp	     minim.sh	npt.mdp  xvg.py gmx-docker	md.mdp.template  minim.mdp.template  ncores.sh	nvt.mdp  $SCRATCHDIR || { exit 1; }

#image=registry.gitlab.ics.muni.cz:443/3086/chicken-and-egg:$(cat VERSION)
image=ljocha/chicken-and-egg:$(cat VERSION)

cd $SCRATCHDIR || { exit 1; }
cp $WORKDIR/$PDBIN .


copyback() {
	tar --exclude '#*' --exclude 'conf*' -cf - $(basename $PDBIN .pdb) | (cd $WORKDIR && tar xf -)
}

trap copyback EXIT


cat - >config.py <<EOF
pdbfile = "$PDBIN"
mdsteps = 100000000	# 200 ns
ntmpi = $NTMPI
ntomp = $(($PBS_NUM_PPN	/ $NTMPI))	# XXX: should be divisible
EOF

OMP_NUM_THREADS=$PBS_NUM_PPN
export OMP_NUM_THREADS 

# https://github.com/ContinuumIO/anaconda-issues/issues/11294
KMP_INIT_AT_FORK=FALSE
export KMP_INIT_AT_FORK

for var in $(env | grep '^PBS_' | sed 's/=.*$//'); do
	unset $var
done

docker=docker
which nvidia-docker && docker=nvidia-docker

gid=$(stat -c %g /var/run/docker.sock)

# XXX: works on whole node only
gpu=''
if [ $($docker -v | sed 's/Docker version //; s/\..*$//;') -ge 19 ]; then
	gpu="--gpus all"
fi

$docker run -ti $gpu -e WORKDIR_OUTSIDE=$PWD -e KMP_INIT_AT_FORK -e OMP_NUM_THREADS -u $(id -u):$gid -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/work $image jupyter nbconvert --ExecutePreprocessor.timeout=None --to notebook --execute chicken-and-egg.ipynb

