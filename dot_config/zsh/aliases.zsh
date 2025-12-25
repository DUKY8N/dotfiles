#!/bin/zsh

# eza
alias ls='LS_COLORS= eza --group-directories-first --icons'
alias l='ls --long --git --color-scale=all --time-style=relative'
alias la='l --all'
alias ll='l --octal-permissions --group --header --time-style=long-iso'
alias lla='ll --all'
alias lt='ls --tree --level=2'

# parent directory shortcuts
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias ......=../../../../..

# tldr alias
alias tldr='LANG=ko tldr'

# fix nfd to ndc alias
alias fxkr="convmv -r -f utf8 -t utf8 --nfc --notest"

# nvim
alias vim="nvim"

# zoxide
alias cd='z'

# package management alias
alias pkgi="pkgman i"
alias pkge="pkgman e"
