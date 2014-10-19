#!/bin/sh

exec >/dev/null 2>&1

SESSION=`tmux ls | fgrep -v attached | fgrep -m 1 -v "server not found" | cut -d ":" -f 1`

[ -n "$SESSION" ] && exec tmux -2 a -t $SESSION || exec tmux -2
