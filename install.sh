#!/bin/bash

# Variables
GPG_KEY="http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro"

REPOS=(
  "https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm"
  "http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm"
)

PACKAGES=(
  "epel-release"
  "python3"
  "python3-pip"
  "lame"
  "compat-openssl10"
)

PIP_PACKAGES=(
  "azure-cognitiveservices-speech"
)

# Check for necessary files
[[ -f Config/azure_config.conf || -f Config/azure_config.default.conf ]] || { echo "Azure config files not found. Exiting."; exit 1; }
[[ -f Scripts/emailproc && -f Scripts/sttparse ]] || { echo "Required script files not found. Exiting."; exit 1; }

# Install the GPG key
echo "Checking GPG key..."
rpm -q gpg-pubkey-`echo $(basename $GPG_KEY) | cut -d '-' -f 4` >/dev/null || { echo "Installing GPG key..."; rpm --import $GPG_KEY || { echo "Failed to import GPG key. Exiting."; exit 1; } }

# Install repositories
for repo in "${REPOS[@]}"; do
  echo "Checking repository: $repo"
  rpm -q --quiet $repo || { echo "Installing repository: $repo"; sudo rpm -Uvh $repo || { echo "Failed to install repository $repo. Exiting."; exit 1; } }
done

# Install packages and check for updates
for pkg in "${PACKAGES[@]}"; do
  echo "Checking package: $pkg"
  rpm -q --quiet $pkg || { echo "Installing package: $pkg"; sudo yum install -y $pkg || { echo "Failed to install package $pkg. Exiting."; exit 1; } }
  echo "Checking package updates for $pkg"
  sudo yum check-update $pkg -q && sudo yum update -y $pkg || true
done

# Install pip packages
for pip_pkg in "${PIP_PACKAGES[@]}"; do
  echo "Checking pip package: $pip_pkg"
  pip3 show $pip_pkg >/dev/null || { echo "Installing pip package: $pip_pkg"; sudo pip3 install $pip_pkg || { echo "Failed to install pip package $pip_pkg. Exiting."; exit 1; } }
done

# Copy the azure_config file
if [[ -f Config/azure_config.conf ]]; then
  cp Config/azure_config.conf /usr/local/etc/azure_config.conf
else
  cp Config/azure_config.default.conf /usr/local/etc/azure_config.conf
  # Prompt the user for the API key and region, and save them to a configuration file
  read -p "Enter your Azure API key: " api_key
  read -p "Enter your Azure region: " region
  sed -i "s/your_api_key_here/$api_key/g" /etc/asterisk/azure_config.conf
  sed -i "s/your_region_here/$region/g" /etc/asterisk/azure_config.conf
fi

# Set permissions for the azure_config file
chmod 644 /usr/local/etc/azure_config.conf

# Install the scripts
cp Scripts/emailproc /usr/local/sbin
cp Scripts/sttparse /usr/local/sbin
chmod +x /usr/local/sbin/emailproc
chmod +x /usr/local/sbin/sttparse
chown asterisk:asterisk /usr/local/sbin/emailproc /usr/local/sbin/sttparse

# Installation complete
echo "Installation complete. emailproc and sttparse are now installed and configured."