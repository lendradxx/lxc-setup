#!/usr/bin/env bash

USERNAME="admin"
PASSWORD="admin123"

echo "[LOG]: Creating backup for local repo..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
fi

echo -e "deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse" >/etc/apt/sources.list
echo "[LOG]: Creating ssh user..."
groupadd wheel
useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
echo "[LOG]: Updating system..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh

# Setup Docker
read -p "Do you want to setup docker? (y/n): " ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "yes" ]]; then
    echo "[LOG]: setup docker..."
    echo "[LOG]: Enabling https support for apt..."
    apt install ca-certificates curl gnupg lsb-release -y
    echo "[LOG]: Adding docker keyring..."
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "[LOG]: Adding docker to apt repo..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    echo "[LOG]: Updating apt repo..."
    apt update
    echo "[LOG]: Installing docker with apt..."
    apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    echo "[LOG]: Enabling and starting docker service..."
    systemctl enable --now docker
else
    echo "[ERR]: invalid or reject answer"
fi
