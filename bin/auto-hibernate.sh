#!/bin/sh

usage() {
    cat << EOF
Usage: `basename $0`
EOF
    exit $1
}

[ "$UID" -ne 0 ] && usage

if [ `acpi -b | cut -d " " -f 4 | tr -d "%,"` -le 5 -a `acpi -a | cut -d " " -f 3` = "off-line" ]; then
    if [ ! -f "/var/lock/auto-hibernate" ]; then
        /usr/bin/touch /var/lock/auto-hibernate && /usr/bin/systemctl hibernate
    fi
else
    /bin/rm -f /var/lock/auto-hibernate
fi
