#!/bin/bash

WATCH_DIR="$1"

if [ -z "$WATCH_DIR" ]; then
    echo "Usage: $0 <directory_to_watch>"
    exit 1
fi

if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotify-tools is not installed. Install it with 'sudo apt install inotify-tools' (Debian/Ubuntu) or equivalent for your OS."
    exit 1
fi

echo "Watching directory: $WATCH_DIR"

inotifywait -m -e moved_to --format "%w%f" "$WATCH_DIR" | while read NEW_FILE; do
    if [[ "$NEW_FILE" == *.png ]]; then
        echo "New PNG file detected: $NEW_FILE"
        wallpaper.sh set "$NEW_FILE"
    fi
done

