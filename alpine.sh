#!/usr/bin/env ash
echo "[LOG]: Updating system..."
apk update
apk upgrade

echo "[LOG]: Installing bash & sudo..."
apk add bash sudo

USERNAME="admin"
PASSWORD="admin123"

echo "[LOG]: Creating ssh user..."
adduser $USERNAME -G wheel -s /bin/bash -SD && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
echo "[LOG]: Installing openssh server..."
apk add openssh-server
echo "[LOG]: Enabling ssh server..."
rc-update add sshd
service ssh start

# Setup Docker
read -p "Do you want to setup docker? (y/n): " ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "yes" ]]; then
    # Installing Docker
    echo "[LOG]: Installing docker..."
    apk add docker
    echo "[LOG]: Enabling and starting docker service..."
    rc-update add docker
    service docker start
else
    echo "[ERR]: invalid or reject answer"
fi
