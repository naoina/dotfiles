#!/bin/sh

#mlclient "$@" 2>/dev/null || mlterm -j genuine "$@"
mlclient "$@" 2>&1 | fgrep -q "dead" && mlterm -j blend "$@"
