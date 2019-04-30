#!/bin/bash

np=$1

if [ -z "$np" ]; then
	set -- $(grep '^processor' /proc/cpuinfo | tail -1)
	np=$(($3 + 1))
	set -- $(grep '^flags' /proc/cpuinfo | head -1)
	while [ -n "$1" -a "$1" != ht ]; do shift; done
	if [ "$1" = ht ]; then np=$(($np / 2)); fi
fi



minone() {
	in=$1
	
	base=$(basename $in .pdb)
	
#	echo Prepare topology
	gmx pdb2gmx -f $base.pdb -o $base.gro -p $base -i $base -water spce -ff amber99 -ignh &&
#	echo Add box
	gmx editconf -f $base.gro -o $base-box.gro -d 1.0 -bt cubic &&
	# not solvating
	# no ions
#	echo Minimize
	gmx grompp -f minim.mdp -c $base-box.gro -p $base.top -o $base-min.tpr -po $base-min.mdp -maxwarn 1 &&
	gmx mdrun -v -deffnm $base-min -ntmpi 1 -ntomp 1 || exit 1
}

nfil=$(ls conf*.pdb | wc -l)

echo Starting $np parallel processes 
for p in $(seq 1 $np); do
	(
		i=$p
		while [ $i -le $nfil ]; do
			minone conf$i.pdb
			i=$(($i + $np))
		done
	) >minim-$p.log 2>&1 &
done

echo Waiting for workers to finish 
wait

echo Done, last 200 lines of their logs
echo

for p in $(seq 1 $np); do
	echo ----- $p -----
	tail -200 minim-$p.log
done
