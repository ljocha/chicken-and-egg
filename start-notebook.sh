#!/bin/sh

cd /opt/chicken-and-egg || exit 1

backup=/work/backup-$(date | tr ' ' -)
mkdir $backup || exit 1

for f in *; do
	mv /work/$f $backup
done

cp -r * /work || exit 1
cd /work
exec "$@"
