#!/bin/bash

pgrep -x sxhkd &> /dev/null
if [ $? -gt 0 ]; then
	sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &
else
	pkill -x sxhkd
	sxhkd -c ~/.config/i3/sxhkd/sxhkdrc &
fi
