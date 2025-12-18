#!/bin/zsh

typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=''
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=''
typeset -g HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_TIMEOUT=0

source "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
source "$XDG_DATA_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$XDG_DATA_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$XDG_DATA_HOME/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
