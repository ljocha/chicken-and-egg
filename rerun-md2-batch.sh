#!/bin/bash

base=/storage/brno3-cerit/home/ljocha/work/chicken-and-egg

workdir=$PWD

trap "cp md3.* $workdir" EXIT

NTMPI=$(($PBS_NUM_PPN / 2))
export NTMPI

cd $PBS_O_WORKDIR &&
cp md.mdp npt.gro md2.cpt topol.top plumed.dat reference.pdb COLVAR HILLS $SCRATCHDIR &&
cd $SCRATCHDIR &&
$base/rerun-md2.sh

