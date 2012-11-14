#!/bin/bash

usage() {
    cat << EOF
Usage: `basename $0` MONITOR_DEVICE ASPECT
EOF
    exit $1
}

if [ "$#" -ne 2 ]; then
    usage 1
fi

MONITOR="$1"
ASPECTX=`echo $2 | cut -d ":" -f 1`
ASPECTY=`echo $2 | cut -d ":" -f 2`

GEOMETRY="`xrandr | grep $MONITOR | cut -d " " -f 3 | cut -d "+" -f 1`"
MONITOR_WIDTH=`echo $GEOMETRY | cut -d "x" -f 1`
MONITOR_HEIGHT=`echo $GEOMETRY | cut -d "x" -f 2`

for t in {stylus,eraser,cursor}; do
    DEVICE="`xsetwacom list | grep "$t" | sed -r 's/.*\sid: ([0-9]+)\s.*/\1/'`"
    if [ "$DEVICE" = "" ]; then
        continue
    fi

    AREA="`xsetwacom get "$DEVICE" Area`"
    TOPX=`echo "$AREA" | cut -d " " -f 1`
    TOPY=`echo "$AREA" | cut -d " " -f 2`
    BOTTOMX=`echo "$AREA" | cut -d " " -f 3`
    BOTTOMY=`echo "$AREA" | cut -d " " -f 4`

    TABLET_ASPECT_ONE=$((BOTTOMY / ASPECTY))
    BOTTOMX=$((ASPECTX * TABLET_ASPECT_ONE))

    xsetwacom set "$DEVICE" MapToOutput $MONITOR
    xsetwacom set "$DEVICE" Area $TOPX $TOPY $BOTTOMX $BOTTOMY
    # xsetwacom set 14 Area 0 400 33834 27300  # for DTU-710
done
