#!/bin/sh

# compositor
killall picom
while pgrep -u $UID -x picom >/dev/null; do sleep 1; done
picom --config ~/.config/picom/picom.conf &
killall polybar
~/.config/polybar/launch.sh &

#bg
#nitrogen --restore &
#~/.fehbg &
#clipmenud &
#dunst &
#autotiling &
#pcloud & 
#unclutter &
#vorta & 

#setxkbmap -option ctrl:nocaps &
#setxkbmap -layout colemak &

#Music player deamon == mpd
#[ ! -s ~/.config/mpd/pid ] && mpd &


#/usr/libexec/polkit-gnome-authentication-agent-1 &
#/usr/lib/polkit-kde-authentication-agent-1 &

#sxhkd
pgrep -x sxhkd &> /dev/null
if [ $? -gt 0 ]; then
	sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &
else
	pkill -x sxhkd
	sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &
fi
# Start XDG autostart .desktop files using dex. See also
# https://wiki.archlinux.org/index.php/XDG_Autostart
#exec --no-startup-id dex --autostart --environment i3
