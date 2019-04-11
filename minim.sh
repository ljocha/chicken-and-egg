
minone() {
	in=$1
	
	base=$(basename $in .pdb)
	
#	echo Prepare topology
	gmx pdb2gmx -f $base.pdb -o $base.gro -p $base -i $base -water spce -ff amber99 -ignh
	
#	echo Add box
	gmx editconf -f $base.gro -o $base-box.gro -d 1.0 -bt cubic
	
	# not solvating
	
	# no ions
	
#	echo Minimize
	gmx grompp -f minim.mdp -c $base-box.gro -p $base.top -o $base-min.tpr -po $base-min.mdp
	gmx mdrun -v -deffnm $base-min
}

nproc=4

nfil=$(ls conf*.pdb | wc -l)

for p in $(seq 1 $nproc); do
	(
		i=$p
		while [ $i -le $nfil ]; do
			minone conf$i.pdb
			i=$(($i + $nproc))
		done
	) &
done


wait
