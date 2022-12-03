#!/usr/bin/env bash

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
fi

# Variable
USERNAME="lendra"
PASSWORD="lendev"

# Function
function CreateLoginUser {
    echo "[LOG]: Creating ssh user..."
    groupadd wheel
    useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
    echo "[LOG]: Adding wheel groups to sudoers"
    echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
}

# Install Docker with distro ID
function InstallDocker() {
    # Setup Docker
    read -p "Do you want to setup docker? (y/n): " ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "yes" ]]; then
        if [[ $ID == "fedora" || $ID == "centos" ]]; then
            PM="dnf"
            if [[ $ID == "centos" ]]; then
                PM="yum"
            fi

            echo "[LOG]: Adding docker to $PM repo..."
            $PM config-manager --add-repo https://download.docker.com/linux/$ID/docker-ce.repo
            echo "[LOG]: Installing docker with dnf..."
            $PM install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
            echo "[LOG]: Enabling and starting docker service..."
            systemctl enable --now docker.socket
        elif [[ $ID == "ubuntu" || $ID == "debian" ]]; then
            echo "[LOG]: setup docker..."
            echo "[LOG]: Enabling https support for apt..."
            apt install ca-certificates curl gnupg lsb-release -y
            echo "[LOG]: Adding docker keyring..."
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "[LOG]: Adding docker to apt repo..."
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$ID $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
            echo "[LOG]: Updating apt repo..."
            apt update
            echo "[LOG]: Installing docker with apt..."
            apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
            echo "[LOG]: Enabling and starting docker service..."
            systemctl enable --now docker.sockets
        else
            echo "[LOG]: Unsupported Distro Linux"
        fi
    else
        echo "[ERR]: invalid or reject answer"
    fi

}

# Install methods

function FedoraInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/
    cd /etc/yum.repos.d/
    sed -i 's|baseurl=https://muug.ca|#baseurl=https://muug.ca|g' /etc/yum.repos.d/fedora*
    sed -i 's|#metalink=https://mirrors.fedoraproject.org|metalink=https://mirrors.fedoraproject.org|g' /etc/yum.repos.d/fedora*
    cd ~

    echo "[LOG]: Creating backup for dnf config"
    mv /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bck
    echo "[LOG]: Generating new dnf config file..."
    wget http://gogs.com/lendra/lxc-setup/raw/main/dnf.conf || curl -o dnf.conf http://gogs.com/lendra/lxc-setup/raw/main/dnf.conf
    mv dnf.conf /etc/dnf/
    echo "[LOG]: Updating and installing missing tools..."
    dnf -v update -y && dnf -v install ncurses bash-completion sudo dnf-plugins-core openssh-server -y
    CreateLoginUser
    echo "[LOG]: Enabling ssh remote && firewall..."
    sudo systemctl enable --now sshd
}

function ArchInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

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
}

function UbuntuInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

    echo "[LOG]: Creating backup for local repo..."
    echo -e "deb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse\ndeb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse\ndeb http://kartolo.sby.datautama.net.id/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse" >/etc/apt/sources.list
    echo "[LOG]: Creating ssh user..."
    groupadd wheel
    useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
    echo "[LOG]: Updating system..."
    apt update && apt upgrade -y && apt install sudo openssh-server curl -y
    echo "[LOG]: Installing ssh if needed..."
    echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
    systemctl enable --now ssh
}

function DebianInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

    echo "[LOG]: Creating ssh user..."
    groupadd wheel
    useradd -mG wheel $USERNAME -s $(which bash 2>/dev/null) && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
    echo "[LOG]: Updating system..."
    apt update && apt upgrade -y
    echo "[LOG]: Installing ssh if needed..."
    apt install sudo openssh-server curl -y
    echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
    systemctl enable --now ssh
}

function AlpineInstall() {
    echo "[LOG]: Disabling IPv6"
    echo -e "# Force IPv6 off\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1\nnet.ipv6.conf.eth0.disable_ipv6 = 1" >/etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
    echo "[LOG]: Updating system..."
    apk upgrade
    echo "[LOG]: Installing bash & sudo..."
    apk add bash sudo

    echo "[LOG]: Creating ssh user..."
    adduser $USERNAME -G wheel -s $(which bash 2>/dev/null) -SD && echo -e "$PASSWORD\n$PASSWORD" | passwd $USERNAME
    echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
    echo "[LOG]: Installing openssh server..."
    apk add openssh-server
    echo "[LOG]: Enabling ssh server..."
    rc-update add sshd
    service sshd start
}

function CentOSInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

    if (($VERSION_ID >= 8)); then
        if [[ "$PRETTY_NAME" =~ .*"Stream".* ]]; then
            echo "[LOG]: Using Distro CentOS Stream..."
        else
            echo "[LOG]: Fixing AppStream not Found..."
            cd /etc/yum.repos.d/
            sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
            sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
            cd ~
        fi
    fi

    echo "[LOG]: Updating the system..."
    yum update -y
    echo "[LOG]: Installing requirements..."
    yum install openssh-server sudo yum-utils ncurses -y
    echo "[LOG]: Enabling Extra Packages..."
    yum install epel-release -y
    echo "[LOG]: Updating system again..."
    yum update -y
    CreateLoginUser
    echo "[LOG]: Enabling SSH Server"
    systemctl enable --now sshd
}

function SUSELeapInstall() {
    echo "[LOG]: Disabling SLE and Backports mirror..."
    zypper mr -d repo-sle-update repo-backports-update
    echo "[LOG]: Updating and installing missing tools..."
    zypper -vn update -y && zypper -vn install bash-completion sudo curl wget

    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

    CreateLoginUser
    echo "[LOG]: Installing SSH Server..."
    zypper -vn install openssh-server
    echo "[LOG]: Enabling ssh remote..."
    systemctl enable --now sshd
}

function AlmaLinuxInstall() {
    echo "[LOG]: Prefering IPv4 instead of IPv6"
    wget http://gogs.com/lendra/lxc-setup/raw/main/gai.conf || curl -o gai.conf http://gogs.com/lendra/lxc-setup/raw/main/gai.conf
    mv gai.conf /etc/

    echo "[LOG]: Creating backup for dnf config"
    mv /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bck
    echo "[LOG]: Generating new dnf config file..."
    wget http://gogs.com/lendra/lxc-setup/raw/main/dnf.conf || curl -o dnf.conf http://gogs.com/lendra/lxc-setup/raw/main/dnf.conf
    mv dnf.conf /etc/dnf/
    echo "[LOG]: Updating and installing missing tools..."
    yum update -y && yum install bash-completion ncurses sudo -y
    CreateLoginUser
    echo "[LOG]: Installing SSH Server..."
    yum install openssh-server -y
    echo "[LOG]: Enabling ssh remote..."
    systemctl enable --now sshd
}

echo "[LOG]: Checking Distro ID..."
echo "[LOG]: Trying install for distro $ID"

case $ID in # Select methods install by distro ID
"fedora")
    FedoraInstall
    ;;
"debian")
    DebianInstall
    ;;
"ubuntu")
    UbuntuInstall
    ;;
"arch")
    ArchInstall
    ;;
"alpine")
    AlpineInstall
    ;;
"centos")
    CentOSInstall
    ;;
"almalinux")
    AlmaLinuxInstall
    ;;
"rocky")
    AlmaLinuxInstall
    ;;
"opensuse-leap")
    SUSELeapInstall
    ;;
*)
    echo "[LOG]: We don't support this distro yet"
    echo "[LOG]: So please wait for us to create installer for this distro..."
    ;;
esac
