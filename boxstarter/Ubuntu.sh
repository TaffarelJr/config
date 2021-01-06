#!/bin/bash

# This script should be run as sudo

# Update packages
apt update
apt upgrade

# Install Homebrew for Linux
sh -c '$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)'
