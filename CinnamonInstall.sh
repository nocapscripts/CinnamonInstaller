k#!/bin/bash
set -e  # Stop on any error

echo "==> Syncing mirrors & updating package DB..."
sudo pacman -Syy --noconfirm

echo "==> Installing Cinnamon..."
sudo pacman -S cinnamon --noconfirm

echo "==> Installing LightDM..."
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm

echo "==> Switching display manager to LightDM..."
sudo rm -f /etc/systemd/system/display-manager.service
sudo systemctl enable lightdm
sudo systemctl disable sddm || true

echo "==> Removing KDE..."
sudo pacman -Rns plasma plasma-meta kde-applications sddm --noconfirm || true

echo "==> Removing CachyOS KDE meta packages (if any)..."
cachy_kde=$(pacman -Q | grep -i cachy | grep -i kde | awk '{print $1}')
if [ -n "$cachy_kde" ]; then
    echo "$cachy_kde" | xargs sudo pacman -Rns --noconfirm
else
    echo "No CachyOS KDE meta packages found."
fi

echo "==> Cleaning orphans..."
orphans=$(pacman -Qdtq 2>/dev/null || true)
if [ -n "$orphans" ]; then
    echo "$orphans" | xargs sudo pacman -Rns --noconfirm
else
    echo "No orphans found."
fi

echo "==> All done! Rebooting in 5 seconds... (Ctrl+C to cancel)"
sleep 5
reboot now
