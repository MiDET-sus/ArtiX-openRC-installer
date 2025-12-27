#!/bin/bash
# Quick Artix OpenRC Installer

set -e

# Быстрая установка с параметрами по умолчанию
quick_install() {
    local drive="$1"
    local hostname="$2"
    local username="$3"
    
    echo "Starting quick installation..."
    
    # Автоматическая разметка
    parted "$drive" mklabel gpt
    parted "$drive" mkpart primary fat32 1MiB 513MiB
    parted "$drive" set 1 esp on
    parted "$drive" mkpart primary ext4 513MiB 100%
    
    mkfs.fat -F32 "${drive}1"
    mkfs.ext4 -F "${drive}2"
    
    mount "${drive}2" /mnt
    mkdir -p /mnt/boot
    mount "${drive}1" /mnt/boot
    
    # Установка системы
    basestrap /mnt base base-openrc linux linux-firmware
    
    # Настройка
    echo "$hostname" > /mnt/etc/hostname
    echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
    echo "KEYMAP=us" > /mnt/etc/vconsole.conf
    
    # Пользователь
    if [[ -n "$username" ]]; then
        artix-chroot /mnt useradd -m -G wheel -s /bin/bash "$username"
        echo "User $username created. Set password with: passwd $username"
    fi
    
    # Загрузчик
    artix-chroot /mnt pacman -S grub efibootmgr --noconfirm
    artix-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Artix
    artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    echo "Installation complete! Reboot with: umount -R /mnt && reboot"
}