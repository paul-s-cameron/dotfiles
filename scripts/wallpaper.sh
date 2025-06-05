#!/bin/bash

# Define a file to store the current playlist path
playlist_env_file="$HOME/.wallpaper_playlist"

send_command() {
  local my_command=$1
  echo "$my_command" | socat - /tmp/mpv-socket
}

# Function to set a wallpaper
set_wallpaper() {
  local wallpaper_path=$1
  echo "Setting wallpaper: $wallpaper_path"
  send_command "loadfile '$wallpaper_path'"
}

# Function to add wallpaper to the playlist
add_wallpaper() {
  local wallpaper_path=$1
  local save=$2

  if [ "$save" == "save" ]; then
    if [ -f "$playlist_env_file" ]; then
      playlist_path=$(cat "$playlist_env_file")
      # Append the full path to the playlist file
      echo -e "$wallpaper_path" >> $playlist_path
      echo "Wallpaper added to playlist: $wallpaper_path"
    else
      echo "No playlist set. Use 'wallpaper playlist /path' to set a playlist first."
    fi
  fi

  # Append the file to the mpv playlist
  send_command "loadfile '$wallpaper_path' append"
  echo "Wallpaper added to mpv playlist: $wallpaper_path"
}

# Function to reload the wallpaper playlist
reload_wallpaper() {
  # Read the current playlist path from the environment file
  if [ -f "$playlist_env_file" ]; then
    playlist_path=$(cat "$playlist_env_file")
  else
    echo "No playlist set. Use 'wallpaper playlist /path' to set a playlist first."
    exit 1
  fi

  pkill -9 mpvpaper
  mpvpaper -p -f -o "--input-ipc-server=/tmp/mpv-socket --loop --loop-playlist --no-audio --panscan=1.0 --playlist=$playlist_path" '*'
  echo "Wallpaper playlist reloaded from: $playlist_path"
}

# Function to set the playlist path
set_playlist() {
  local new_playlist_path=$1

  if [ -z "$new_playlist_path" ]; then
    echo "Please provide a path to set the playlist."
    exit 1
  fi

  # Save the playlist path in the environment file
  echo "$new_playlist_path" > "$playlist_env_file"
  send_command "loadlist '$new_playlist_path'"
  echo "Playlist set to: $new_playlist_path"
}

set_rotation() {
  local rotation=$1

  send_command "set video-rotate $rotation"
}

spawn_interval() {
  local interval=$1
  local command=$2

  # Spawn a background process that runs the command at the specified interval
  (
    while true; do
      wallpaper.sh send $command
      sleep "$interval"
    done
  ) > /dev/null 2>&1 &
  echo "Spawned interval command: '$command' every $interval seconds"
  echo $! > /tmp/wallpaper_interval.pid
}

# Parse the command
case "$1" in
  set)
    # Expects a path to mpv compatible file
    
    if [ -z "$2" ]; then
      echo "Please provide a path to set the wallpaper."
      exit 1
    fi

    ABS_PATH=$(realpath "$2")

    set_wallpaper "$ABS_PATH"
    ;;
  add)
    # Expects a path to mpv compatible file (optional 'save' parameter)
    
    if [ -z "$2" ]; then
      echo "Please provide a path to add the wallpaper."
      exit 1
    fi

    if [ "$3" == "save" ]; then
      add_wallpaper "$2" "save"
    else
      add_wallpaper "$2"
    fi
    ;;
  reload)
    reload_wallpaper
    ;;
  playlist)
    # Expects a path to playlist file
    set_playlist "$2"
    ;;
  send)
    send_command "$2"
    ;;
  flip)
    if [ "$2" == "v" ]; then
      send_command "vf toggle vflip"
    elif [ "$2" == "h" ]; then
      send_command "vf toggle hflip"
    else
      echo "Please specify a direction (v/h)"
    fi
    ;;
  rotate)
    set_rotation "$2"
    ;;
  interval)
    case "$2" in
      stop)
        # Stop the interval command

        if [ -f /tmp/wallpaper_interval.pid ]; then
          kill $(cat /tmp/wallpaper_interval.pid) 2>/dev/null
          rm -f /tmp/wallpaper_interval.pid
          echo "Stopped interval command."
        else
          echo "No interval command is running."
        fi
        exit 0
        ;;
      *)
        # Expects an interval in seconds and a command to run
        if [ -z "$2" ] || [ -z "$3" ]; then
          echo "Usage: $0 interval <seconds> <command>"
          exit 1
        fi

        spawn_interval "$2" "$3"
        ;;
    esac
    ;;
  *)
    echo "Usage: $0 {set|add|reload|playlist|send} [path:file/playlist] [save]"
    exit 1
    ;;
esac
