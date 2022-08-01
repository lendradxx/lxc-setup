#!/usr/bin/bash
echo "[LOG]: Creating temporary mirror..."
echo -e "## Worldwide\nServer = http://mirror.rackspace.com/archlinux/\$repo/os/\$arch\nServer = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "[LOG]: Updating keyring..."
rm -fr /etc/pacman.d/gnupg && pacman-key --init && pacman-key --populate archlinux &&  pacman-key --refresh-keys && pacman -Sy archlinux-keyring --noconfirm
echo -e "\n"
echo "[LOG]: Updating arch linux and installing base-devel"
pacman -Syu --noconfirm && pacman -S base-devel git wget curl --needed --noconfirm
echo -e "\n"
echo "[LOG]: Creating admin user and install ssh server..."
useradd -mG admin && echo -e "admin123\nadmin123" | passwd admin && pacman -S openssh --needed && systemctl enable --now sshd && echo -e "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "[LOG]: Installing yay and updating mirror..."
wget https://github.com/Jguer/yay/releases/download/v11.2.0/yay_11.2.0_x86_64.tar.gz && pacman -U ./yay_11.2.0_x86_64.tar.gz --noconfirm && yay -S rate-mirrors-bin --noconfirm && rate-mirrors --allow-root --save /etc/pacman.d/mirrorlist arch