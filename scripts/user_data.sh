#!/usr/bin/env bash

dnf install -y flatpak xorg-x11-xauth xorg-x11-xdm
dnf clean all
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
echo "X11UseLocalhost yes" >> /etc/ssh/sshd_config
systemctl restart sshd

sudo -u fedora -i <<'EOF'

touch ~/.Xauthority
flatpak update
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub io.podman_desktop.PodmanDesktop

EOF
