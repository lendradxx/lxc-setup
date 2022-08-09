#!/usr/bin/env bash
echo "[LOG]: Creating admin user..."
groupadd wheel
useradd -mG wheel admin -s $(which bash) && echo -e "admin123\nadmin123" | passwd admin
echo "[LOG]: Updating user..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable --now ssh