#!/usr/bin/bash
echo "[LOG]: Creating admin user..."
useradd -mG wheel admin && echo -e "admin123\nadmin123" | passwd admin
echo -e "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers
echo "[LOG]: Creating temporary mirror..."
echo -e "## Worldwide\nServer = http://mirror.rackspace.com/archlinux/\$repo/os/\$arch\nServer = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch" >/etc/pacman.d/mirrorlist
echo "[LOG]: Updating keyring..."
rm -rf /etc/pacman.d/gnupg
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
pacman -Sy archlinux-keyring --noconfirm
echo -e "\n"
echo "[LOG]: Updating arch linux and installing base-devel"
pacman -Syu --noconfirm && pacman -S base-devel git wget curl --needed --noconfirm
echo -e "\n"
echo "[LOG]: Installing ssh if needed..."
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
