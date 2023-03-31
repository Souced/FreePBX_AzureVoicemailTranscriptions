#!/usr/bin/env bash

log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") $@"
}

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

LOG_FILE="install.log"

exec > >(tee -ia "$LOG_FILE") 2>&1

# Check for necessary files
[[ -f Config/azure_config.conf || -f Config/azure_config.default.conf ]] || { log "Azure config files not found. Exiting."; exit 1; }
[[ -f Scripts/emailproc && -f Scripts/sttparse ]] || { log "Required script files not found. Exiting."; exit 1; }

# Install the GPG key
log "Checking GPG key..."
rpm -q gpg-pubkey-`echo $(basename $GPG_KEY) | cut -d '-' -f 4` >/dev/null || { log "Installing GPG key..."; rpm --import $GPG_KEY || { log "Failed to import GPG key."; } }

# Install repositories
for repo in "${REPOS[@]}"; do
  log "Checking repository: $repo"
  rpm -q --quiet $repo || { log "Installing repository: $repo"; sudo rpm -Uvh $repo || { log "Failed to install repository $repo."; } }
done

# Install packages and check for updates
for pkg in "${PACKAGES[@]}"; do
  log "Checking package: $pkg"
  rpm -q --quiet $pkg || { log "Installing package: $pkg"; sudo yum install -y $pkg || { log "Failed to install package $pkg."; } }
  log "Checking package updates for $pkg"
  sudo yum check-update $pkg -q && sudo yum update -y $pkg || { log "Failed to update package $pkg."; }
done

# Install pip packages
for pip_pkg in "${PIP_PACKAGES[@]}"; do
  log "Checking pip package: $pip_pkg"
  pip3 show $pip_pkg >/dev/null || { log "Installing pip package: $pip_pkg"; sudo pip3 install $pip_pkg || { log "Failed to install pip package $pip_pkg."; } }
done

# Install the azure_config file
if [[ -f Config/azure_config.conf ]]; then
  install -m 644 Config/azure_config.conf /usr/local/bin/azure_config.conf
else
  install -m 644 Config/azure_config.default.conf /usr/local/bin/azure_config.conf
  # Prompt the user for the API key and region, and save them to a configuration file
  read -p "Enter your Azure API key: " api_key
  read -p "Enter your Azure region: " region
  sed -i "s/your_api_key_here/$api_key/g" /usr/local/bin/azure_config.conf
  sed -i "s/your_region_here/$region/g" /usr/local/bin/azure_config.conf
fi

# Install the log config file & scripts
install -m 644 Config/sttparse_logrotate.conf /etc/logrotate.d/sttparse
install -m 755 Scripts/emailproc /usr/local/bin/emailproc
install -m 755 Scripts/sttparse /usr/local/bin/sttparse

# Set owner
chown asterisk:asterisk /usr/local/bin/emailproc /usr/local/bin/sttparse /etc/logrotate.d/sttparse /usr/local/etc/azure_config.conf

# Installation complete
log "Installation complete. emailproc and sttparse are now installed and configured."