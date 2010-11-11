#!/bin/sh

BG='#000'   # dzen backgrounad
FG='#999'   # dzen foreground
GBG='#333'  # color of gauge background
GW=50       # width of the gauge
HALFGW=`expr $GW / 2`
GH=10       # height of the gauge
H=23        # dzen height
X=0         # x position
Y=-1        # y position
# FN='M+2VM+IPAG-circle'  # font

TIME_INT=1 # time intervall in seconds
SEP='|' # status separator
ICONDIR='/home/naoina/.dzen2/'

function battery() {
    STATEFILE='/proc/acpi/battery/BAT0/state' # battery's state file
    INFOFILE='/proc/acpi/battery/BAT0/info'   # battery's info file
    LOWBAT=25        # percentage of battery life marked as low
    GFG='#999'  # color of the gauge
    LOWCOL='#ff4747' # color when battery is low

    # look up battery's data
    BAT_FULL=`cat $INFOFILE|grep last|line|cut -d " " -f 9`;
    STATUS=`cat $STATEFILE|grep charging|cut -d " " -f 12`;
    RCAP=`cat $STATEFILE|grep remaining|cut -d " " -f 8`;

    # calculate remaining power
    RPERCT=`expr $RCAP \* 100`;
    RPERC=`expr $RPERCT / $BAT_FULL`;

    # Battery
    [ $RPERC -le $LOWBAT ] && GFG=$LOWCOL

    if [ $STATUS = 'discharging' ]; then
        ICON="^i($ICONDIR/battery.xbm)"
    else
        ICON="^i($ICONDIR/ac_adapter.xbm)"
    fi

    BAR=`echo $RPERC | gdbar -s o -h $GH -w $GW -fg $GFG -bg $GBG`

    echo -n " $ICON ${RPERC}% $BAR"
}

CPU_USER_OLD=100
CPU_NICE_OLD=100
CPU_SYS_OLD=100
CPU_IDLE_OLD=100
CPU_IOWAIT_OLD=100
CPU_IRQ_OLD=100
CPU_SOFT_IRQ_OLD=100
CPU_STEAL_OLD=100
TOTAL_TIME_OLD=100
TOTAL_PERIOD_OLD=100

function cpu() {
    STATEFILE='/proc/stat'
    HIGH_LOAD=70 # percentage
    GFG='#999'  # color of the gauge
    HIGH_LOAD_COL='#FF0000'

    CPU_STATE=`cat /proc/stat | grep -m 1 cpu`
    CPU_USER=`echo "$CPU_STATE" | cut -d " " -f 3`
    CPU_NICE=`echo "$CPU_STATE" | cut -d " " -f 4`
    CPU_SYS=`echo "$CPU_STATE" | cut -d " " -f 5`
    CPU_IDLE=`echo "$CPU_STATE" | cut -d " " -f 6`
    CPU_IOWAIT=`echo "$CPU_STATE" | cut -d " " -f 7`
    CPU_IRQ=`echo "$CPU_STATE" | cut -d " " -f 8`
    CPU_SOFT_IRQ=`echo "$CPU_STATE" | cut -d " " -f 9`
    CPU_STEAL=`echo "$CPU_STATE" | cut -d " " -f 10`

    CPU_USER_PERIOD=`expr $CPU_USER - $CPU_USER_OLD`
    CPU_NICE_PERIOD=`expr $CPU_NICE - $CPU_NICE_OLD`
    CPU_SYS_PERIOD=`expr $CPU_SYS - $CPU_SYS_OLD`
    CPU_IDLE_PERIOD=`expr $CPU_IDLE - $CPU_IDLE_OLD`
    CPU_IOWAIT_PERIOD=`expr $CPU_IOWAIT - $CPU_IOWAIT_OLD`
    CPU_IRQ_PERIOD=`expr $CPU_IRQ - $CPU_IRQ_OLD`
    CPU_SOFT_IRQ_PERIOD=`expr $CPU_SOFT_IRQ - $CPU_SOFT_IRQ_OLD`
    CPU_STEAL_PERIOD=`expr $CPU_STEAL - $CPU_STEAL_OLD`

    IDLE_TIME=`expr $CPU_IDLE + $CPU_IOWAIT`
    SYSALL_TIME=`expr $CPU_SYS + $CPU_IRQ + $CPU_SOFT_IRQ + $CPU_STEAL`
    TOTAL_TIME=`expr $CPU_USER + $CPU_NICE + $SYSALL_TIME + $IDLE_TIME`
    TOTAL_PERIOD=`expr $TOTAL_TIME - $TOTAL_TIME_OLD`

    V=`echo "($CPU_USER_PERIOD + $CPU_NICE_PERIOD + $CPU_SYS_PERIOD + $CPU_IRQ_PERIOD + $CPU_SOFT_IRQ_PERIOD) * 100 / $TOTAL_PERIOD" | bc -l`

    CPU_TOTAL=`echo "scale=1; $V / 1" | bc` # floor

    if [ `echo "$CPU_TOTAL > 100" | bc -l` -eq 1 ]; then
        CPU_TOTAL="100.0"
    elif [ `echo "$CPU_TOTAL < 0" | bc -l` -eq 1 ]; then
        CPU_TOTAL="0.0"
    fi

    CPU_USER_OLD=$CPU_USER
    CPU_NICE_OLD=$CPU_NICE
    CPU_SYS_OLD=$CPU_SYS
    CPU_IDLE_OLD=$CPU_IDLE
    CPU_IOWAIT_OLD=$CPU_IOWAIT
    CPU_IRQ_OLD=$CPU_IRQ
    CPU_SOFT_IRQ_OLD=$CPU_SOFT_IRQ
    CPU_STEAL_OLD=$CPU_STEAL

    TOTAL_PERIOD_OLD=$TOTAL_PERIOD
    TOTAL_TIME_OLD=$TOTAL_TIME

    [ `echo "$CPU_TOTAL >= $HIGH_LOAD" | bc -l` -eq 1 ] && GFG=$HIGH_LOAD_COL

    ICON="^i($ICONDIR/cpu.xbm)"

    BAR=`echo $CPU_TOTAL | gdbar -s o -h $GH -w $HALFGW -fg $GFG -bg $GBG`

    TEMP=`cat /proc/acpi/thermal_zone/THM0/temperature | cut -d " " -f 14`

    echo -n " CPU `printf '%5s' $CPU_TOTAL`% $BAR ${TEMP}C $SEP"
}

function memory() {
    MEMINFO='/proc/meminfo'
    GFG='#999'  # color of the gauge

    AWKS='
        /MemTotal/ {mtotal=$2};
        /MemFree/  {mfree=$2};
        /Buffers/  {mbuffers=$2};
        /^Cached/  {mcached=$2};
        /SwapTotal/ {stotal=$2};
        /SwapFree/  {sfree=$2};
        /SwapCached/ {scached=$2};
        END {
            print int(mtotal/1024);
            print int((mtotal-mfree-mbuffers-mcached)/1024) " " (mtotal-mfree-mbuffers-mcached)/mtotal*100;
            print int(stotal/1024);
            print int((stotal-sfree-sbuffers)/1024) " " (stotal-sfree-sbuffers-scached)/stotal*100;
        }
    '

    MEM=(`awk "$AWKS" $MEMINFO`)
    MEM[2]=`echo "${MEM[2]} / 1" | bc`
    MEM[4]=`echo "${MEM[4]} / 1" | bc`

    MEM_BAR=`echo ${MEM[2]} | gdbar -s o -h $GH -w $HALFGW -fg $GFG -bg $GBG`
    SWAP_BAR=`echo ${MEM[5]} | gdbar -s o -h $GH -w $HALFGW -fg $GFG -bg $GBG`

    echo -n " Mem ${MEM[1]}/${MEM[0]}MB $MEM_BAR Swap ${MEM[4]}/${MEM[3]}MB $SWAP_BAR $SEP"
}

while true; do
    # draw the bar and pipe everything into dzen

    echo -n `date` $SEP # local datetime

    # cpu # cpu status

    # memory # memory status

    # battery # battery status

    echo " $SEP `date -u` " # UTC datetime

    sleep $TIME_INT;
done | dzen2 -expand left -h $H -ta c -y $Y -x $X -fg $FG -bg $BG #-fn "$FN"
