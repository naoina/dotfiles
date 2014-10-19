#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

usage() {
    cat << EOF
Usage: `basename $0`
EOF
    exit $1
}

xinput list | grep -q 'Tablet pointer' || xinput create-master 'Tablet'

for t in {stylus,eraser,cursor}; do
    DEVICE="`xsetwacom list | grep "$t" | sed -r 's/.*\sid: ([0-9]+)\s.*/\1/'`"
    if [ "$DEVICE" = "" ]; then
        continue
    fi

    xinput reattach $DEVICE 'Tablet pointer'
done
