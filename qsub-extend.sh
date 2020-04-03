#!/bin/bash

ncpus=32
ntomp=4
ngpus=2

num=$1

name=$(basename $PWD)
basedir=$PWD

ntmpi=$(($ncpus / $ntomp))

grompp="/storage/brno3-cerit/home/ljocha/work/chicken-and-egg/gmx-docker -p -- grompp"
mdrun="/storage/brno3-cerit/home/ljocha/work/chicken-and-egg/gmx-docker -p -n $ntmpi -- mdrun"

prevjob=
for i in $(seq 2 $num); do
	n=$(printf '%02d' $i)
	dir=md2-$n

	i1=$(($i - 1))
	n1=$(printf '%02d' $i1)
	prevdir=md2-$n1

	script=$name-md2-$n.sh
	
	mkdir $dir
	cp md.mdp npt.gro topol.top reference.pdb $dir

	echo RESTART >$dir/plumed.dat
	cat plumed.dat >>$dir/plumed.dat

	cat - >$dir/$script <<EOF
#!/bin/bash

trap "cp COLVAR HILLS md2.* $basedir/$dir" EXIT

cd $basedir/$prevdir
cp md2.cpt COLVAR HILLS \$SCRATCHDIR
cd $basedir/$dir
cp md.mdp npt.gro topol.top plumed.dat reference.pdb \$SCRATCHDIR

cd \$SCRATCHDIR
unset OMP_NUM_THREADS

$grompp -f md.mdp -c npt.gro -t md2.cpt -p topol.top -o md2.tpr &&
$mdrun -ntomp $ntomp -pin on -deffnm md2 -plumed plumed.dat

EOF

	chmod +x $dir/$script

	if [ -n "$prevjob" ]; then dep="-W depend=afterany:$prevjob"; else dep=""; fi

#	prevjob="fake-$n"
	prevjob=$(qsub -q gpu -l walltime=24:0:0 -l select=1:ncpus=$ncpus:ngpus=$ngpus:mem=60GB:scratch_local=200GB $dep $dir/$script)
	echo $script: $prevjob
done
echo Good luck!


