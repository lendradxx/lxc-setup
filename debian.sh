#!/usr/bin/env bash

read -p "Enter Username (Default: user): " USERNAME
read -p "Enter Password (Default: pass123): " PASSWORD

if [[ ! $USERNAME && ! $PASSWORD ]]; then
    USERNAME="admin"
    PASSWORD="admin123"
fi

echo "[LOG]: Creating ssh user..."
groupadd wheel
useradd -mG wheel $USERNAME -s $(which bash) && echo -e "$PASSWORD\n$PASSWORD" | passwd admin
echo "[LOG]: Updating user..."
apt update && apt upgrade -y && apt install sudo openssh-server curl -y
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
systemctl enable --now ssh
