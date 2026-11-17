#!/usr/bin/env bash
set -euo pipefail

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  printf "\nHomebrew not found. Installing Homebrew...\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  printf "\nHomebrew found. Continuing...\n"
fi
