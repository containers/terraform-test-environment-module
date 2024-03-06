#!/usr/bin/env bash

sudo -u fedora -i <<'EOF'

sudo dnf install -y flatpak xorg-x11-xauth xorg-x11-xdm
sudo dnf clean all
touch ~/.Xauthority
flatpak update
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub io.podman_desktop.PodmanDesktop
sudo echo "X11Forwarding yes" >> /etc/ssh/sshd_config
sudo echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
sudo echo "X11UseLocalhost yes" >> /etc/ssh/sshd_config
sudo systemctl restart sshd

EOF
