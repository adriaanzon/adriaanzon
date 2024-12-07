#!/usr/bin/env sh
#
# Notify if Stereo as Mono setting was left enabled

if [ "$(defaults read com.apple.universalaccess stereoAsMono)" -eq 1 ]
then
    osascript -e 'display notification "‘Play stereo audio as mono’ accessibility setting is enabled" with title "System Settings"'
fi
