#!/bin/bash
# This script MUST be run as sudo

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
# Update Linux
#--------------------------------------------------

printf "${YELLOW}Get latest apt metadata${NOCOLOR}\n"
apt update

printf "${YELLOW}Update apt packages${NOCOLOR}\n"
apt upgrade -y

#--------------------------------------------------
# Change the mount point from /mnt/c to /c
#--------------------------------------------------

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

#--------------------------------------------------
# Install apt-get tools
#--------------------------------------------------

printf "${YELLOW}Install 'build-essential' package${NOCOLOR}\n"
apt-get install -y 'build-essential'

printf "${YELLOW}Install 'curl' package${NOCOLOR}\n"
apt-get install -y 'curl'

printf "${YELLOW}Install 'file' package${NOCOLOR}\n"
apt-get install -y 'file'

printf "${YELLOW}Install 'git' package${NOCOLOR}\n"
apt-get install -y 'git'

printf "${YELLOW}Install 'sendmail' package${NOCOLOR}\n"
apt-get install -y 'sendmail'

#--------------------------------------------------
# Install python tools
#--------------------------------------------------

printf "${YELLOW}Install 'pip' for python${NOCOLOR}\n"
apt  install -y 'python3-pip'

printf "${YELLOW}Install 'slack-cli' for python${NOCOLOR}\n"
pip3 install 'slack-cli' --trusted-host='pypi.python.org'

#--------------------------------------------------
# Set up git credential manager
#--------------------------------------------------

# This is optional but it keeps you from having to enter git username/password each time
printf "${YELLOW}Configure Git credential manager${NOCOLOR}\n"
git config --global credential.helper '/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe'

#--------------------------------------------------
# Install sqlcmd
#--------------------------------------------------

# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017#ubuntu
printf "${YELLOW}Download sqlcmd info${NOCOLOR}\n"
curl 'https://packages.microsoft.com/keys/microsoft.asc' | apt-key add -
curl 'https://packages.microsoft.com/config/ubuntu/20.04/prod.list' | tee /etc/apt/sources.list.d/msprod.list

printf "${YELLOW}Get latest apt-get metadata${NOCOLOR}\n"
apt-get update

printf "${YELLOW}Install mssql-tools (Unix ODBC)${NOCOLOR}\n"
apt-get install -y 'mssql-tools' unixodbc-dev

printf "${YELLOW}Update apt-get packages${NOCOLOR}\n"
apt-get update

printf "${YELLOW}Install mssql-tools${NOCOLOR}\n"
apt-get install -y 'mssql-tools'

printf "${YELLOW}Configure profile${NOCOLOR}\n"
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
