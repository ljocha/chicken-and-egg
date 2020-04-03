#!/bin/bash

name=$(basename $PWD)
basedir=$PWD

dir=md2-01
mkdir $dir
cp md.mdp npt.gro topol.top reference.pdb $dir
cp COLVAR HILLS md2.* $dir

