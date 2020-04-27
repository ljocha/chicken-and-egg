#!/bin/bash

ncpus=40
ntomp=4
ngpus=2
prevjob=

eval set -- $(getopt -o +n:t:g:a:h -- "$@")

while [ $1 != -- ]; do case $1 in
	-n) ncpus=$2; shift; shift ;;
	-t) ntomp=$2; shift; shift ;;
	-g) ngpus=$2; shift; shift ;;
	-a) prevjob="$2"; shift; shift ;;
	*) cat >&2 <<EOF
usage: $0 [options] [first] last

	-n	total cores
	-t 	OMP threads per MPI process
	-g	GPUs
	-a	previous job to wait for
EOF
	exit 1;
esac; done

[ "$1" == -- ] && shift

if [ -z "$2" ]; then
	first=1
	last=$1
else
	first=$1
	last=$2
fi

mem=$(($ncpus * 4))
scratch=$(($ncpus * 10))

name=$(basename $PWD)
basedir=$PWD

# prefix=/storage/brno3-cerit/home/ljocha/work/chicken-and-egg/
dir=$(dirname $0)
prefix=$(cd ${dir:-.} && pwd)

ntmpi=$(($ncpus / $ntomp))

grompp="${prefix}/gmx-docker -p -- grompp"
mdrun="${prefix}/gmx-docker -p -n $ntmpi -- mdrun"

echo RESTART >plumed-restart.dat
cat plumed.dat >>plumed-restart.dat

for i in $(seq $first $last); do
	n=$(printf '%02d' $i)
	prev=$(printf '%02d' $(($i - 1)) )

	script=$name-md2-$n.sh
	
	cat - >$script <<EOF
#!/bin/bash

cleanup() {
	test -n "$SCRATCHDIR" || exit 1
	cd $SCRATCHDIR || exit 1
	cp COLVAR HILLS md2.* $basedir
	copied=$?
	
	id=$(podman --root $SCRATCHDIR ps | tail -1 | awk '{print $1}')
	podman --root $SCRATCHDIR kill $id

	if [ "$copied" = 0 ]; then
		cd /tmp && rm -rf $SCRATCHDIR
	fi
}

trap cleanup EXIT

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
	prevjob=$(qsub -q gpu -l walltime=24:0:0 -l select=1:cluster=glados:ncpus=$ncpus:ngpus=$ngpus:mem=${mem}GB:scratch_local=${scratch}GB $dep $script)
	echo $script: $prevjob
done
echo Good luck!


