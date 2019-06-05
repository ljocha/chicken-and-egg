#!/bin/bash

set -- $(grep '^processor' /proc/cpuinfo | tail -1)
np=$(($3 + 1))
set -- $(grep '^flags' /proc/cpuinfo | head -1)
while [ -n "$1" -a "$1" != ht ]; do shift; done
if [ "$1" = ht ]; then np=$(($np / 2)); fi

echo $np
