setxkbmap pt
xrdb -merge ~/.Xresources
eval $(ssh-agent)
VBoxClient-all &
exec i3
