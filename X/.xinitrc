setxkbmap pt
xrdb -merge ~/.Xresources
eval $(ssh-agent)
#exec i3
sxhkd &
compton --config $XDG_CONFIG_HOME/compton/compton.conf --backend xrender &
VBoxClient-all &
exec bspwm
