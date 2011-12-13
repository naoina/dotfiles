#!/bin/sh

BG='#000'   # dzen backgrounad
FG='#999'   # dzen foreground
GBG='#333'  # color of gauge background
GW=50       # width of the gauge
HALFGW=`expr $GW / 2`
GH=10       # height of the gauge
H=23        # dzen height
W=1400
X=0         # x position
Y=-1        # y position
# FN='Migu 1M'  # font

TIME_INT=1 # time intervall in seconds
SEP='|' # status separator
DZEN_DIR='/home/naoina/.dzen2/'

function battery() {
    LOWBAT=25        # percentage of battery life marked as low
    NOTIFYBAT=10     # percentage of battery life for notification
    GFG=$FG          # color of the gauge
    LOWCOL='#ff4747' # color when battery is low
    STATUSDIR="/sys/class/power_supply"
    BATDIR="$STATUSDIR/BAT0"

    # look up battery's data
    BAT_FULL=`cat $BATDIR/charge_full 2>/dev/null || cat $BATDIR/energy_full`
    STATUS=`cat $STATUSDIR/AC/online`
    RCAP=`cat $BATDIR/charge_now 2>/dev/null || cat $BATDIR/energy_now`

    # calculate remaining power
    RPERCT=`expr $RCAP \* 100`;
    RPERC=`expr $RPERCT / $BAT_FULL`;

    # Battery
    [ $RPERC -le $LOWBAT ] && GFG=$LOWCOL

    if [ $RPERC -le $NOTIFYBAT -a ! -f "$DZEN_DIR/.bat_notify" ]; then
        /usr/bin/notify-send -u critical "Low battery notification" "A current battery remaining is $NOTIFYBAT%.\nIncidentally, lower than 5% will immediatelly go into Hibernate mode."
        touch "$DZEN_DIR/.bat_notify"
    elif [ $RPERC -gt $NOTIFYBAT ]; then
        rm -f "$DZEN_DIR/.bat_notify"
    fi

    if [ $STATUS -eq 0 ]; then
        ICON="^i($DZEN_DIR/battery.xbm)"
    else
        ICON="^i($DZEN_DIR/ac_adapter.xbm)"
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

    ICON="^i($DZEN_DIR/cpu.xbm)"

    BAR=`echo $CPU_TOTAL | gdbar -s o -h $GH -w $HALFGW -fg $GFG -bg $GBG`

    TEMP=`cat /proc/acpi/ibm/thermal | cut -d "	" -f 2 | cut -d " " -f 1`

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

    echo -n " Mem ${MEM[1]}/${MEM[0]}MB $MEM_BAR Swap ${MEM[4]}/${MEM[3]}MB $SEP"
}

while true; do
    # draw the bar and pipe everything into dzen

    echo -n " `date` $SEP" # local datetime

    cpu # cpu status

    memory # memory status

    battery # battery status

    echo " $SEP `date -u` " # UTC datetime

    sleep $TIME_INT;
done | dzen2 -expand left -h $H -ta r -y $Y -x $X -fg $FG -bg $BG -dock
