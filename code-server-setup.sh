#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install -y \
    curl \
    g++ \
    git \
    iputils-ping \
    jsonnet \
    libssl-dev \
    netcat \
    pkg-config \
    python3 \
    python3-pip \
    unzip \
    wget \
    zip \
    zlib1g-dev \
    jq \
    gh \
    locales \
    libatomic1 \
    nano \
    net-tools \
    dnsutils \
    apt-transport-https \
    software-properties-common \
    ca-certificates

# Terraform
wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_$(dpkg --print-architecture).zip -O terraform
unzip terraform -d /usr/local/bin

# Github CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list

# Kubectl
wget -q https://dl.k8s.io/release/v1.26.0/bin/linux/$(dpkg --print-architecture)/kubectl
install kubectl /usr/local/bin && rm kubectl

# Helm
wget -q https://get.helm.sh/helm-v3.11.2-linux-$(dpkg --print-architecture).tar.gz -O helm.tar.gz
tar xzf helm.tar.gz --strip-components 1 linux-$(dpkg --print-architecture)/helm && install helm /usr/local/bin && rm helm

# 1password
wget -q https://downloads.1password.com/linux/debian/$(dpkg --print-architecture)/stable/1password-cli-$(dpkg --print-architecture)-latest.deb -O 1password-cli-latest.deb
apt-get install -y ./1password-cli-latest.deb && rm ./1password-cli-latest.deb

# Keybase
wget -q https://prerelease.keybase.io/keybase_amd64.deb -O keybase.deb
apt-get install -y ./keybase.deb
run_keybase -g

# Powershell
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x ./dotnet-install.sh && ./dotnet-install.sh
wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell-7.4.0-linux-$(dpkg --print-architecture).tar.gz -O powershell.tar.gz
mkdir /config/microsoft/
mkdir /config/microsoft/powershell
mkdir /config/microsoft/powershell/7
tar zxf ./powershell.tar.gz -C /config/microsoft/powershell/7
chmod +x /config/microsoft/powershell/7/pwsh
ln -s /config/microsoft/powershell/7/pwsh /usr/bin/pwsh

/init
