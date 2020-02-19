#!/bin/bash

dir=$(dirname $0)
if [ -n "$dir" ]; then
	gmx=$dir/gmx-docker
else
	gmx=gmx-docker
fi

fnm=md3

unset OMP_NUM_THREADS

echo RESTART plumed-restart.dat
cat plumed.dat >>plumed-restart.dat

mkdir $fnm-backup
cp COLVAR HILLS $fnm-backup

$gmx grompp -f md.mdp -c npt.gro -t md2.cpt -p topol.top -o $fnm.tpr &&
$gmx -n ${NTMPI:-6} mdrun -ntomp ${NTOMP:-2} -pin on -deffnm $fnm -plumed plumed-restart.dat
