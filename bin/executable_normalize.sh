#!/usr/bin/env bash
#
# Normalize and convert an audio file for publishing.
#
# - Normalizes loudness to -16 LUFS
# - Removes long silences
# - Encodes to an MP3 by default
#
# Usage: normalize.sh <input file> [output file]
#
# Examples:
# Convert an audio file to mp3:
#     normalize.sh input.wav
#
# Convert an audio file to m4a:
#     normalize.sh input.wav output.m4a

input_file="$1"
output_file="${2:-${1%.*}.mp3}"

ffmpeg -i "$input_file" -af "loudnorm=I=-16:print_format=summary,silenceremove=stop_periods=-1:stop_duration=10:stop_threshold=-50dB" "$output_file"
