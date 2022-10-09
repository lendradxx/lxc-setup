#!/usr/bin/env bash

USERNAME="admin"
PASSWORD="admin123"

echo "[LOG]: Creating ssh user..."
groupadd wheel
useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
echo "[LOG]: Updating system..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh
