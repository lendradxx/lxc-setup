#!/usr/bin/env bash

USERNAME="admin"
PASSWORD="admin123"

echo "[LOG]: Creating backup for dnf config"
mv /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bck
echo "[LOG]: Generating new dnf config file..."
DNF_CONFIG="[main]\ngpgcheck=1\ninstallonly_limit=2\nclean_requirements_on_remove=True\nbest=True\nskip_if_unavailable=True\ndeltarpm=True\nmax_parallel_downloads=10\ndefaultyes=True\ninstall_weak_deps=False"
echo -e $DNF_CONFIG >/etc/dnf/dnf.conf
echo "[LOG]: Updating and installing missing tools..."
dnf update -y && dnf install ncurses bash-completion sudo -y
echo "[LOG]: Enabling rpm fusion..."
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf groupupdate core -y && sudo dnf install openssh-server -y
echo "[LOG]: Creating ssh user..."
useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
echo "[LOG]: Adding wheel groups to sudoers"
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
echo "[LOG]: Enabling ssh remote && firewall..."
sudo systemctl enable --now sshd && sudo systemctl enable --now firewalld
echo "[LOG]: Enabling firewall for server..."
sudo firewall-cmd --set-default-zone=FedoraServer

# Setup Docker
read -p "Do you want to setup docker? (y/n): " ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "yes" ]]; then
    echo "[LOG]: Installing dnf-plugins-core (required)..."
    dnf -y install dnf-plugins-core
    echo "[LOG]: Adding docker to dnf repo..."
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    echo "[LOG]: Installing docker with dnf..."
    dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "[LOG]: Enabling and starting docker service..."
    systemctl enable --now docker.socket
else
    echo "[ERR]: invalid or reject answer"
fi
