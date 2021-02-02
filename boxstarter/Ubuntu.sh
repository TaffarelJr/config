#!/bin/sh
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
# Update Linux
#--------------------------------------------------

header "Get latest apt metadata"
apt update

header "Update apt packages"
apt upgrade -y

#--------------------------------------------------
# Change the mount point from /mnt/c to /c
#--------------------------------------------------

# https://gist.github.com/sgtoj/f82990bcd9e89db49b84e2d2e70b281d
# https://docs.microsoft.com/en-us/windows/wsl/wsl-config
header "Change mount point to /c"
sudo echo '# Enable extra metadata options by default' >  /etc/wsl.conf
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

header "Install 'build-essential' package"
apt-get install -y 'build-essential'

header "Install 'curl' package"
apt-get install -y 'curl'

header "Install 'file' package"
apt-get install -y 'file'

header "Install 'git' package"
apt-get install -y 'git'

header "Install 'sendmail' package"
apt-get install -y 'sendmail'

#--------------------------------------------------
# Install apt tools
#--------------------------------------------------

header "Install 'pip' for python"
apt install -y 'python3-pip'

#--------------------------------------------------
# Set up git credential manager
#--------------------------------------------------

# This is optional but it keeps you from having to enter git username/password each time
header "Configure Git credential manager"
git config --global credential.helper '/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe'

#--------------------------------------------------
# Install sqlcmd
#--------------------------------------------------

# https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017#ubuntu
header "Download sqlcmd info"
curl 'https://packages.microsoft.com/keys/microsoft.asc' | apt-key add -
curl 'https://packages.microsoft.com/config/ubuntu/20.04/prod.list' | tee /etc/apt/sources.list.d/msprod.list

header "Get latest apt-get metadata"
apt-get update

header "Install mssql-tools (Unix ODBC)"
apt-get install -y 'mssql-tools' unixodbc-dev

header "Update apt-get packages"
apt-get update

header "Install mssql-tools"
apt-get install -y 'mssql-tools'

header "Configure profile"
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
. ~/.bashrc
