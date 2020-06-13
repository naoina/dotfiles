PATH="~/bin:$PATH"
IMAGE_PATH="$HOME/media/image/wallpaper"

# WM=qtile
# WM=wmfs
# WM=xmonad
# WM=compiz-fusion
WM=awesome
# WM=fluxbox
# WM=i3
# WM=wmii
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
# export GTK_IM_MODULE=ibus
# export QT_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0

if [ -x "`which chromium`" ]; then
    export BROWSER="chromium"
elif [ -x "`which google-chrome`" ]; then
    export BROWSER="google-chrome"
elif [ -x "`which firefox`" ]; then
    export BROWSER="firefox"
fi

# xmodmap $HOME/.Xmodmap

# Default settings.
xset s off
xset r rate 250 50
xset b off
xset -dpms
xss-lock -- i3lock -n -u &
#xrandr --dpi 96
#xinput -set-prop "$(xinput list | perl -ne 'print $1 if /Touchpad\s+id=(\d+)/')" --type=float 'libinput Accel Speed' 1
syndaemon -i 0.5 -t -k &

# uim-xim &
# scim -d
# ibus-daemon --xim -d
fcitx-autostart
start-pulseaudio-x11
blueman-applet &
# touchegg >/dev/null 2>&1 &

if [ -x "`which devmon`" -a ! "`pgrep devmon`" ]; then
    AFTER_CMD="notify-send -t 0 \"%f mounted on %d\""
    devmon --exec-on-drive "$AFTER_CMD" &
fi

libinput-gestures-setup start

# [ -x "/opt/dropbox/dropbox" ] && /opt/dropbox/dropbox &


#$WALLPAPER_PICKER $IMAGE_PATH

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
