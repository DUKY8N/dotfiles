#!/bin/zsh

# history behaviour
setopt histverify histignoredups histexpiredupsfirst histignorespace sharehistory extendedhistory

# completion/prompt handling
setopt completeinword combiningchars promptsubst

# directory movement tweaks
setopt autocd autopushd pushdignoredups pushdminus

# job control and misc niceties
setopt alwaystoend longlistjobs monitor noflowcontrol interactivecomments zle
