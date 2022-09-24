#!/usr/bin/env bash
echo "[LOG]: Creating backup for local repo..."

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
fi

echo -e "deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME=jammy} main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME=jammy}-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME=jammy}-security main restricted universe multiverse" >/etc/apt/sources.list
echo "[LOG]: Creating admin user..."
groupadd wheel
useradd -mG wheel admin -s $(which bash) && echo -e "admin123\nadmin123" | passwd admin
echo "[LOG]: Updating user..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh
