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

#--------------------------------------------------
# Install Homebrew for Linux
#--------------------------------------------------

# https://docs.brew.sh/Homebrew-on-Linux
printf "${YELLOW}Install Homebrew for Linux${NOCOLOR}\n"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#--------------------------------------------------
# Add Homebrew to path
#--------------------------------------------------

printf "${YELLOW}Add Homebrew to path${NOCOLOR}\n"
test -d ~/.linuxbrew               && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile            && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.bash_profile
                                      echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.profile

#--------------------------------------------------
# Install Homebrew recipes
#--------------------------------------------------

printf "${YELLOW}Install 'gcc' recipe${NOCOLOR}\n"
brew install 'gcc'

printf "${YELLOW}Install 'azure-cli' recipe${NOCOLOR}\n"
brew install 'azure-cli'

printf "${YELLOW}Install 'terraform' recipe${NOCOLOR}\n"
brew install 'terraform'

printf "${YELLOW}Install 'git' recipe${NOCOLOR}\n"
brew install 'git'

printf "${YELLOW}Install 'coreutils' recipe${NOCOLOR}\n"
brew install 'coreutils'

printf "${YELLOW}Install 'mutt' recipe${NOCOLOR}\n"
brew install 'mutt'

printf "${YELLOW}Install 'jq' recipe${NOCOLOR}\n"
brew install 'jq'

printf "${YELLOW}Install 'zip' recipe${NOCOLOR}\n"
brew install 'zip'
