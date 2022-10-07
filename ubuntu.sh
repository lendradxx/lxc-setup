#!/usr/bin/env bash
read -p "Enter Username (Default: user): " USERNAME
read -p "Enter Password (Default: pass123): " PASSWORD

if [[ ! $USERNAME && ! $PASSWORD ]]; then
    USERNAME="admin"
    PASSWORD="admin123"
fi

echo "[LOG]: Creating backup for local repo..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
fi

echo -e "deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse" >/etc/apt/sources.list
echo "[LOG]: Creating ssh user..."
groupadd wheel
useradd -mG wheel $USERNAME -s $(which bash) && echo -e "$PASSWORD\n$PASSWORD" | passwd admin
echo "[LOG]: Updating user..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh
