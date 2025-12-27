#!/bin/bash
# Backup and restore script for Artix

backup_system() {
    local backup_dir="/backup/artix-$(date +%Y%m%d)"
    local exclude_file="/tmp/exclude.txt"
    
    mkdir -p "$backup_dir"
    
    cat > "$exclude_file" << EOF
/proc/*
/sys/*
/dev/*
/tmp/*
/run/*
/mnt/*
/media/*
/var/cache/*
/var/tmp/*
/home/*/.cache/*
EOF
    
    tar --exclude-from="$exclude_file" -czf "$backup_dir/full-backup.tar.gz" /
    echo "Backup created: $backup_dir/full-backup.tar.gz"
}

restore_system() {
    local backup_file="$1"
    local restore_dir="${2:-/}"
    
    if [[ ! -f "$backup_file" ]]; then
        echo "Backup file not found!"
        exit 1
    fi
    
    echo "Restoring from $backup_file to $restore_dir"
    tar -xzf "$backup_file" -C "$restore_dir" --numeric-owner
    
    # Восстановление загрузчика
    if [[ -d "/sys/firmware/efi" ]]; then
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Artix
    else
        grub-install --target=i386-pc "/dev/sda"
    fi
    grub-mkconfig -o /boot/grub/grub.cfg
    
    echo "Restoration complete! Reboot recommended."
}