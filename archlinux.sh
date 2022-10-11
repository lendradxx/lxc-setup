#!/usr/bin/env bash

USERNAME="admin"
PASSWORD="admin123"

echo "[LOG]: Creating ssh user..."
useradd -mG wheel $USERNAME && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
echo "[LOG]: Creating temporary mirror..."
echo -e " ## Worldwide\nServer = http://mirror.rackspace.com/archlinux/\$repo/os/\$arch\nServer = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch" >/etc/pacman.d/mirrorlist
echo "[LOG]: Updating keyring..."
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
pacman -Sy archlinux-keyring --noconfirm
echo -e "\n"
echo "[LOG]: Updating arch linux and installing base-devel"
pacman -Syu --noconfirm && pacman -S base-devel git wget curl bash-completion sudo --needed --noconfirm
echo -e "\n"
echo "[LOG]: Installing ssh if needed..."
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
pacman -S openssh --needed && systemctl enable --now sshd
echo "[LOG]: Downloading yay..."
wget https://github.com/Jguer/yay/releases/download/v11.2.0/yay_11.2.0_x86_64.tar.gz
echo "[LOG]: Extracting yay..."
tar -xf ./yay_11.2.0_x86_64.tar.gz && cd yay_11.2.0_x86_64
echo "[LOG]: Installing yay to system..."
./yay -S yay-bin --noconfirm
echo "[LOG]: Installing rate-mirrors..."
yay -S rate-mirrors-bin --noconfirm
echo "[LOG]: Updating mirrors..."
rate-mirrors --allow-root --save /etc/pacman.d/mirrorlist arch
echo "[LOG]: Deleting temp yay"
rm -rf --verbose $HOME/yay_11.2.0_x86_64
rm --verbose $HOME/yay_11.2.0_x86_64.tar.gz

# Setup Docker
read -p "Do you want to setup docker? (y/n): " ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "yes" ]]; then
    # Installing Docker
    echo "[LOG]: Installing docker..."
    yay -S docker --noconfirm
    echo "[LOG]: Enabling and starting docker service..."
    systemctl enable --now docker
else
    echo "[ERR]: invalid or reject answer"
fi
