#!/bin/bash

base=/storage/brno3-cerit/home/ljocha/work/chicken-and-egg

workdir=${PBS_O_WORKDIR:-$PWD}

trap 'cp -R md3* $workdir' EXIT

NTMPI=$(($PBS_NUM_PPN / 2))
export NTMPI

cd $workdir &&
cp md.mdp npt.gro md2.cpt topol.top plumed.dat reference.pdb COLVAR HILLS $SCRATCHDIR &&
cd $SCRATCHDIR &&
$base/rerun-md2.sh

