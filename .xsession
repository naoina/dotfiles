PATH="~/bin:$PATH"
IMAGE_PATH="$HOME/work/media/image"

WM=xmonad
# WM=compiz-fusion
# WM=awesome
# WM=i3
WALLPAPER_PICKER="$HOME/bin/rotate-wallpaper"

export LANG=ja_JP.UTF-8
export LC_CTYPE=$LANG
export LC_TIME=C
# export LC_ALL=$LANG

# export GTK_IM_MODULE=uim
# export QT_IM_MODULE=uim
# export XMODIFIERS=@im=uim
export GTK_IM_MODULE=scim-bridge
export QT_IM_MODULE=scim-bridge
export XMODIFIERS=@im=SCIM

xmodmap $HOME/.Xmodmap

# Default settings.
xset s noblank
xset r rate 250

# uim-xim &
scim -d

# By setting the window manager.
case "$WM" in
    compiz-fusion)
        emerald &
        WM="fusion-icon"
        ;;
    xmonad)
        $WALLPAPER_PICKER $IMAGE_PATH
        $HOME/.dzen2/status.sh &
        # xcompmgr &
        ;;
    i3)
        $WALLPAPER_PICKER $IMAGE_PATH
        ;;
    *)
        ;;
esac

# Start window manager.
exec $WM
