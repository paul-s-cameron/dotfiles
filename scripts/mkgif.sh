#!/bin/bash

FILE=$1

ffmpeg -i "$FILE" -vf "fps=24,scale=-2:1080:flags=lanczos,palettegen=stats_mode=diff" -y palette.png
ffmpeg -i "$FILE" -i palette.png -lavfi "fps=24,scale=-2:1080:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" -y "${FILE}_converted.gif"
rm palette.png
