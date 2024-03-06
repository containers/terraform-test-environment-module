#!/usr/bin/env bash

dnf install -y podman flatpak xorg-x11-xauth xorg-x11-xdm
dnf clean all
tee -a /etc/ssh/sshd_config <<EOF
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
EOF
systemctl restart sshd
echo "XAuthLocation /usr/bin/xauth" >> /etc/ssh/ssh_config

cd /var/lib/flatpak
mkdir -p repo/objects repo/tmp
tee repo/config <<EOF
[core]
repo_version=1
mode=bare-user-only
min-free-space-size=500MB
EOF

sudo -u fedora -i <<'EOF'

touch ~/.Xauthority
flatpak update
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub io.podman_desktop.PodmanDesktop

EOF
