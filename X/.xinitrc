setxkbmap pt
xrdb -merge ~/.Xresources
eval $(ssh-agent)
VBoxClient-all &
#exec i3
sxhkd &
compton -i 0.9 --backend xrender &
feh --bg-fill -no-fehbg $XDG_CONFIG_HOME/bg.jpg &
exec bspwm
