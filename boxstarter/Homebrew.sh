#!/bin/sh
# This script MUST NOT be run as sudo

#--------------------------------------------------
# Definitions
#--------------------------------------------------

# Color constants (ANSI escape codes)
NOCOLOR='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

header () {
    text=$1
    line=$(printf '%.s-' $(seq ${#text}))

    printf "\n"
    printf "${ORANGE}+-${line}-+${NOCOLOR}\n"
    printf "${ORANGE}| ${text} |${NOCOLOR}\n"
    printf "${ORANGE}+-${line}-+${NOCOLOR}\n"
    printf "\n"
}

#--------------------------------------------------
# Install Homebrew for Linux
#--------------------------------------------------

# https://docs.brew.sh/Homebrew-on-Linux
header "Install Homebrew for Linux"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#--------------------------------------------------
# Add Homebrew to path
#--------------------------------------------------

header "Add Homebrew to path"
test -d ~/.linuxbrew               && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile            && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.bash_profile
                                      echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.profile

#--------------------------------------------------
# Install Homebrew recipes
#--------------------------------------------------

header "Install 'gcc' recipe"
brew install 'gcc'

header "Install 'azure-cli' recipe"
brew install 'azure-cli'

header "Install 'terraform' recipe"
brew install 'terraform'

header "Install 'git' recipe"
brew install 'git'

header "Install 'coreutils' recipe"
brew install 'coreutils'

header "Install 'mutt' recipe"
brew install 'mutt'

header "Install 'jq' recipe"
brew install 'jq'

header "Install 'zip' recipe"
brew install 'zip'
