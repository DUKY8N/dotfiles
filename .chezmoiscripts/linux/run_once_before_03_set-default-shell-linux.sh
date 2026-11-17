#!/usr/bin/env bash
set -euo pipefail

current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
[[ "$current_shell" == */zsh ]] && exit 0

chsh -s /bin/zsh
