echo "[LOG]: Creating backup for dnf config"
mv /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bck
echo "[LOG]: Generating new dnf config file..."
DNF_CONFIG="[main]\ngpgcheck=1\ninstallonly_limit=2\nclean_requirements_on_remove=True\nbest=True\nskip_if_unavailable=True\ndeltarpm=True\nmax_parallel_downloads=10\ndefaultyes=True\ninstall_weak_deps=False"
echo -e $DNF_CONFIG >/etc/dnf/dnf.conf

echo "[LOG]: Updating and installing missing tools..."
dnf update -y && dnf install ncurses bash-completion sudo -y
echo "[LOG]: Enabling rpm fusion..."
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
echo "[LOG]: Adding admin user..."
useradd -mG wheel admin && echo -e "admin123\nadmin123" | passwd admin
echo "[LOG]: Adding wheel groups to sudoers"
echo -e "%wheel ALL=(ALL:ALL) ALL" >>/etc/sudoers
echo "[LOG]: Enabling ssh remote && firewall..."
sudo systemctl enable --now sshd firewalld
echo "[LOG]: Enabling firewall for server..."
sudo firewall-cmd --set-default-zone=FedoraServer