#!/bin/sh

CHRONY=/usr/bin/chronyc

[ -x $CHRONY ] || exit 0

$CHRONY -a online
