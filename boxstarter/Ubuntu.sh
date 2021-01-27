#!/bin/bash

#--------------------------------------------------
# This script should be run as sudo
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

# Update packages
printf "${YELLOW}Get latest apt metadata${NOCOLOR}\n"
apt update
printf "${YELLOW}Update apt packages${NOCOLOR}\n"
apt upgrade -y

# Change the mount point from /mnt/c to /c
# https://gist.github.com/sgtoj/f82990bcd9e89db49b84e2d2e70b281d
# https://docs.microsoft.com/en-us/windows/wsl/wsl-config
printf "${YELLOW}Change mount point to /c${NOCOLOR}\n"
sudo echo ''                                           >> /etc/wsl.conf
sudo echo ''                                           >> /etc/wsl.conf
sudo echo '# Enable extra metadata options by default' >> /etc/wsl.conf
sudo echo '[automount]'                                >> /etc/wsl.conf
sudo echo 'enabled = true'                             >> /etc/wsl.conf
sudo echo 'root = /'                                   >> /etc/wsl.conf
sudo echo 'options = "metadata,umask=22,fmask=11"'     >> /etc/wsl.conf
sudo echo 'mountFsTab = false'                         >> /etc/wsl.conf
sudo echo ''                                           >> /etc/wsl.conf
sudo echo '# Enable DNS (just to be explicit)'         >> /etc/wsl.conf
sudo echo '[network]'                                  >> /etc/wsl.conf
sudo echo 'generateHosts = true'                       >> /etc/wsl.conf
sudo echo 'generateResolvConf = true'                  >> /etc/wsl.conf

# Install Homebrew for Linux
# https://docs.brew.sh/Homebrew-on-Linux
printf "${YELLOW}Install Homebrew for Linux${NOCOLOR}\n"
sh -c '$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)'

# Add Homebrew to path
printf "${YELLOW}Add Homebrew to path${NOCOLOR}\n"
test -d ~/.linuxbrew               && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile            && echo 'eval \$($(brew --prefix)/bin/brew shellenv)' >> ~/.bash_profile
                                      echo 'eval \$($(brew --prefix)/bin/brew shellenv)' >> ~/.profile

# Install basic utilities
printf "${YELLOW}Install apt-get utility packages${NOCOLOR}\n"
apt-get install 'build-essential'
apt-get install 'curl'
apt-get install 'file'
apt-get install 'git'
apt-get install 'sendmail'

# Install additional tools
# https://github.com/im-platform/azurerm
printf "${YELLOW}Install Homebrew recipies${NOCOLOR}\n"
brew install 'gcc'
brew install 'azure-cli'
brew install 'terraform'
brew install 'git'
brew install 'coreutils'
brew install 'mutt'
brew install 'jq'
brew install 'zip'

# Install pip & Slack CLI for Python
printf "${YELLOW}Install python tools${NOCOLOR}\n"
apt install 'python3-pip'
pip3 install 'slack-cli' --trusted-host='pypi.python.org'

# Set up git credential manager
# This is optional but it keeps you from having to enter git username/password each time
printf "${YELLOW}Configure Git credential manager${NOCOLOR}\n"
git config --global credential.helper '/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe'

# Install sqlcmd
# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017#ubuntu
printf "${YELLOW}Install sqlcmd${NOCOLOR}\n"
curl 'https://packages.microsoft.com/keys/microsoft.asc' | apt-key add -
curl 'https://packages.microsoft.com/config/ubuntu/20.04/prod.list' | tee /etc/apt/sources.list.d/msprod.list
apt-get update
apt-get install 'mssql-tools' unixodbc-dev
apt-get update
apt-get install 'mssql-tools'
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
