#! /bin/bash

cd "$(tmux run "echo #{pane_current_path}")" || exit
url=$(git remote get-url origin)

if [[ $url == *github.com* ]]; then
  if [[ $url == git@* ]]; then
    url="${url#git@}"
    url="${url/:/\/}"
    url="https://$url"
  fi
  if command -v open >/dev/null; then
    open "$url"
  else
    xdg-open "$url"
  fi
else
  echo "This repository is not hosted on GitHub"
fi
