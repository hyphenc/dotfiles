#!/bin/bash
#keymap
setxkbmap de
#top bar
while :; do
    #vars
    BAT=$(cat /sys/class/power_supply/BAT1/capacity)
    BRIGHTNESS=$(xbacklight -get| sed "s/\..*//")
    NETSIGNAL=$(cat /proc/net/wireless | grep -oP  "..\." | head -n 1 | sed 's/\.//' | sed 's/\..*//')
    SINK=$(pacmd list-sinks|awk '/\* index:/{ print $3 }')
    STATUS=$(cat /sys/class/power_supply/BAT1/status)
    VOLUME=$(pacmd list-sinks | grep -A 7 "index: $SINK" | grep -oP "\/.*?[0-9]{1,3}%.*?\/" | head -n 1 | grep -oP "[0-9]{1,3}%")
    BATIND=""
    BATLABEL="bat:"
    VOLLABEL="vol:"
    if [ "$STATUS" == "Charging" ]; then
      BATIND="*"
    elif [ "$STATUS" == "Discharging" ]; then
      BATIND="%"
    fi
    if [ "$BAT" == "100" ]; then
      BATLABEL=""
      BATIND=""
      BAT="charged"
    elif [ "$BAT" -le "14" -a "$STATUS" == "Discharging" ]; then
      BATLABEL=""
      BATIND=""
      BAT="charge!"
      notify-send --urgency=critical -t 20000 "your laptop is about to die"
    fi
    if [ "$(pacmd list-sinks | grep -A 11 "index: $SINK" | grep 'muted:.*' | sed 's/\s//gi')" == "muted:yes" ]; then
      VOLLABEL=""
      VOLUME="muted"
    fi
    if [ "$BRIGHTNESS" -lt "1" ]; then
      xbacklight -set "1.1"
    fi
    xsetroot -name " $(date +%H:%M) | $(date +%a | tr '[A-Z]' '[a-z]') $(date +%d/%m/%Y) | net:$NETSIGNAL% $VOLLABEL$VOLUME $BATLABEL$BAT$BATIND "
    sleep 5
done &
#autostart
clipmenud &
ssh-agent &
redshift -l "$(curl -ks https://iplocation.com --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36" | grep -oP '(?<=<td class="l..">).*?(?=<\/td>)' | tr '\n' ':' | sed 's/:$//')" || true &
xautolock -time 2 -corners ---- -cornersize 40 -locker "/usr/bin/pactl set-sink-mute 0 toggle; systemctl suspend" -detectsleep -notify 15 -notifier "notify-send --urgency=critical 'suspending in 15s'" &
start-pulseaudio-x11 &
dunst &
/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 & # polkit agent
#enable touch to click & natural scrolling & enable touchpad while typing
TOUCHPADID=$(xinput list | grep -oP "Touchpad.*id=[0-9]*\S" | sed "s/.*id=//")
TOUCH_TO_CLICK_PROP=$(xinput list-props $TOUCHPADID | grep -oP "Tapping Enabled \(.*?\)" | sed "s/.*Tapping Enabled (//" | sed "s/)//")
NAT_SCROLLING_PROP=$(xinput list-props $TOUCHPADID | grep -oP "Natural Scrolling Enabled \(.*?\)" | sed "s/.*Natural Scrolling Enabled (//" | sed "s/)//") # mouse id
DISABLE_WHILE_TYPING_PROP=$(xinput list-props $TOUCHPADID | grep -oP "Disable While Typing Enabled \(.*?\)" | sed "s/.*Disable While Typing Enabled (//" | sed "s/)//")
xinput set-prop "$TOUCHPADID" "$TOUCH_TO_CLICK_PROP" 1 &
xinput set-prop 9 "$NAT_SCROLLING_PROP" 0 &
xinput set-prop "$TOUCHPADID" "$NAT_SCROLLING_PROP" 1 &
xinput set-prop "$TOUCHPADID" "$DISABLE_WHILE_TYPING_PROP" 0 &
#wallpaper
~/.scripts/fehbg
#finally
exec ~/.scripts/startdwm
