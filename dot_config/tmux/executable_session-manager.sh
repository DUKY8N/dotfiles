#!/usr/bin/env bash

s=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
[[ $s ]] || echo "No tmux sessions (Ctrl-N to create)" >&2

echo "$s" | fzf \
  --ansi \
  --height=100% \
  --border=none \
  --margin=0 \
  --header "Open: ↵ | New: C-n | Rename: C-r | Delete: C-d" \
  \
  --bind "enter:execute(
    tmux attach -t {} 2>/dev/null || tmux switch-client -t {}
  )+abort" \
  \
  --bind "ctrl-d:execute-silent(
    tmux kill-session -t {} && echo Deleted: {} >&2
  )+reload(tmux list-sessions -F '#{session_name}')" \
  \
  --bind "ctrl-r:execute(
    echo -n 'Rename {} to: ' > /dev/tty
    read n < /dev/tty
    [[ \$n ]] && tmux rename-session -t {} \$n
  )+reload(tmux list-sessions -F '#{session_name}')" \
  \
  --bind "ctrl-n:execute(
    echo -n 'New session: ' > /dev/tty
    read n < /dev/tty
    [[ \$n ]] && tmux new-session -d -s \$n -c \$HOME &&
      (tmux attach -t \$n 2>/dev/null || tmux switch-client -t \$n)
  )+abort"
