#!/bin/bash
# Post-install configuration for Artix OpenRC

post_install() {
    echo "Running post-install configuration..."
    
    # Обновление системы
    pacman -Syu --noconfirm
    
    # Установка yay (AUR helper)
    if ! command -v yay &> /dev/null; then
        pacman -S --needed git base-devel --noconfirm
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    # Настройка OpenRC
    rc-update add dbus default
    rc-update add NetworkManager default
    rc-update add sshd default
    rc-update add acpid default
    rc-update add cronie default
    
    # Установка полезных пакетов
    local packages=(
        "htop neofetch bat exa ripgrep fd"
        "python python-pip nodejs npm"
        "docker docker-openrc"
        "firefox chromium"
        "vlc mpv"
        "gimp inkscape"
        "code"  # Visual Studio Code
        "telegram-desktop"
        "qbittorrent"
    )
    
    for pkg_group in "${packages[@]}"; do
        pacman -S $pkg_group --noconfirm
    done
    
    # Настройка Docker
    if command -v docker &> /dev/null; then
        rc-update add docker default
        usermod -aG docker "$USER"
    fi
    
    # Настройка Git
    git config --global user.name "$USER"
    git config --global user.email "$USER@$HOSTNAME"
    git config --global core.editor "vim"
    
    echo "Post-install configuration complete!"
}