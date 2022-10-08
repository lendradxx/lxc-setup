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
echo "[LOG]: Updating user..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh
