#!/bin/bash

ncpus=40
ntomp=4
ngpus=2

num=$1

name=$(basename $PWD)
basedir=$PWD

prefix=/storage/brno3-cerit/home/ljocha/work/chicken-and-egg/

ntmpi=$(($ncpus / $ntomp))

grompp="${prefix}/gmx-docker -p -- grompp"
mdrun="${prefix}/gmx-docker -p -n $ntmpi -- mdrun"

echo RESTART >plumed-restart.dat
cat plumed.dat >>plumed-restart.dat

prevjob=
for i in $(seq 1 $num); do
	n=$(printf '%02d' $i)
	prev=$(printf '%02d' $(($i - 1)) )

	script=$name-md2-$n.sh
	
	cat - >$script <<EOF
#!/bin/bash

trap "cp COLVAR HILLS md2.* $basedir" EXIT

cd $basedir
mkdir md2-$prev
cp reference.pdb plumed-restart.dat md2.* COLVAR HILLS \$SCRATCHDIR

mv COLVAR HILLS md2.* md2-$prev

cd \$SCRATCHDIR
unset OMP_NUM_THREADS

$mdrun -ntomp $ntomp -pin on -deffnm md2 -cpi md2.cpt -plumed plumed-restart.dat

EOF

	chmod +x $script

	if [ -n "$prevjob" ]; then dep="-W depend=afterany:$prevjob"; else dep=""; fi

#	prevjob="fake-$n"
	prevjob=$(qsub -q gpu -l walltime=24:0:0 -l select=1:cluster=glados:ncpus=$ncpus:ngpus=$ngpus:mem=60GB:scratch_local=200GB $dep $script)
	echo $script: $prevjob
done
echo Good luck!


