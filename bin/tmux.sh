#!/bin/sh

exec >/dev/null 2>&1

SESSION=`tmux ls | fgrep -v attached | line | fgrep -v "server not found" | cut -d ":" -f 1`

[ -n "$SESSION" ] && exec tmux -2 a -t $SESSION || exec tmux -2
