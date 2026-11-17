#!/usr/bin/env bash

apps=(
  "flow"
  "adguard"
  "keepingyouawake"
  "hammerspoon"
  "cleanshot x"
  "betterdisplay"
  "klack"
)

shopt -s nocasematch
existing="$(/usr/bin/osascript -e 'tell application "System Events" to get the name of every login item')"

for app in "${apps[@]}"; do
  if [[ ! -d "/Applications/${app}.app" ]]; then
    echo "⚠️  $app not found"
    continue
  fi

  # already registered
  [[ ", ${existing}, " == *", ${app}, "* ]] && continue

  open -a "$app"
  /usr/bin/osascript <<OSA
tell application "System Events"
  make login item at end with properties { \
    name:"${app}", \
    path:"/Applications/${app}.app", \
    hidden:false}
end tell
OSA
done
