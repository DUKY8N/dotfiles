#!/bin/zsh

autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME}/zsh"
compinit -u -d "${XDG_CACHE_HOME}/zsh/zcompdump"
