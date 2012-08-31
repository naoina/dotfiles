PATH="~/bin:$PATH"
IMAGE_PATH="$HOME/media/image/wallpaper"

# WM=qtile
# WM=wmfs
# WM=xmonad
# WM=compiz-fusion
WM=awesome
#WM=fluxbox
# WM=i3
WALLPAPER_PICKER="$HOME/bin/rotate-wallpaper.py"

export LANG=ja_JP.UTF-8
export LC_CTYPE=$LANG
export LC_TIME=C
# export LC_ALL=$LANG

# export GTK_IM_MODULE=uim
# export QT_IM_MODULE=uim
# export XMODIFIERS=@im=uim
# export GTK_IM_MODULE=scim-bridge
# export QT_IM_MODULE=scim-bridge
# export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

xmodmap $HOME/.Xmodmap

# Default settings.
xset s noblank
xset r rate 250 50
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 8 1
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 8 2
xinput set-int-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 8 6 7 4 5

# uim-xim &
# scim -d
ibus-daemon --xim -d

if [ -x "`which devmon`" -a ! "`pgrep devmon`" ]; then
    AFTER_CMD="notify-send '%f mounted on %d'"
    devmon --exec-on-drive "$AFTER_CMD" &
fi


$WALLPAPER_PICKER $IMAGE_PATH

# By setting the window manager.
case "$WM" in
    compiz-fusion)
        emerald &
        WM="fusion-icon"
        ;;
    xmonad)
        $HOME/.dzen2/status.sh &
        # xcompmgr &
        ;;
    *)
        ;;
esac

# Start window manager.
exec $WM
