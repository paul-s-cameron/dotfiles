#!/bin/bash

# Cursor restore
trap "tput cnorm; exit" INT TERM EXIT

if [ $# -lt 2 ]; then
	echo "Usage: $0 <interval_in_seconds> <command_to_run>"
	exit 1
fi

INTERVAL=$1
shift
COMMAND="$@"

# Hide the cursor
tput civis

clear

# Run the command at specified intervals
while true; do
	tput cup 0 0
	eval "$COMMAND" 2>/dev/null
	sleep "$INTERVAL"
done
