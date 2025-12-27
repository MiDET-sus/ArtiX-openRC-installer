#!/bin/bash
# Advanced Artix Linux OpenRC Installer
# Version: 2.0
# Features: Automatic partitioning, LVM, encryption, btrfs, multiple desktop environments

set -euo pipefail
trap 'cleanup_on_error' ERR

# ==================== CONFIGURATION ====================
VERSION="2.0"
SCRIPT_NAME="Artix OpenRC Installer"
REPO_BASE="https://mirror1.artixlinux.org"

# ==================== VARIABLES ====================
declare -A CONFIG=(
    [install_drive]=""
    [boot_mode]=""
    [disk_layout]="auto"           # auto, manual, lvm, encryption
    [filesystem]="ext4"           # ext4, btrfs, xfs
    [hostname]="artix"
    [username]=""
    [user_password]=""
    [root_password]=""
    [timezone]=""
    [locale]="en_US.UTF-8"
    [keymap]="us"
    [desktop]="none"
    [additional_packages]=""
    [swap_size]="4G"
    [uefi_bootloader]="grub"      # grub, refind
    [kernel]="linux"              # linux, linux-lts, linux-zen
    [mirror_country]="global"
    [enable_multilib]="true"
    [enable_testing]="false"
    [zram_enabled]="true"
    [trim_enabled]="true"
)

# ==================== COLOR OUTPUT ====================
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'
readonly CHECK="✓"
readonly CROSS="✗"
readonly ARROW="→"

# ==================== DESKTOP ENVIRONMENTS ====================
declare -A DESKTOP_PACKAGES=(
    [plasma]="plasma-meta plasma-wayland-session kde-applications-meta sddm"
    [gnome]="gnome gnome-extra gdm"
    [xfce]="xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
    [lxqt]="lxqt breeze-icons sddm"
    [mate]="mate mate-extra lightdm lightdm-gtk-greeter"
    [cinnamon]="cinnamon lightdm lightdm-gtk-greeter"
    [budgie]="budgie-desktop lightdm lightdm-gtk-greeter"
    [sway]="sway swaybg swayidle swaylock waybar wofi"
    [i3]="i3-wm i3status dmenu i3blocks lightdm lightdm-gtk-greeter"
    [bspwm]="bspwm sxhkd polybar rofi lightdm lightdm-gtk-greeter"
    [hyprland]="hyprland waybar rofi wofi"
    [none]=""
)

declare -A DESKTOP_SERVICES=(
    [plasma]="sddm"
    [gnome]="gdm"
    [xfce]="lightdm"
    [lxqt]="sddm"
    [mate]="lightdm"
    [cinnamon]="lightdm"
    [budgie]="lightdm"
    [sway]=""
    [i3]="lightdm"
    [bspwm]="lightdm"
    [hyprland]=""
    [none]=""
)

# ==================== LOGGING ====================
LOG_FILE="/tmp/artix-install-$(date +%Y%m%d-%H%M%S).log"
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> >(tee -a "$LOG_FILE") 2>&1

# ==================== FUNCTIONS ====================

# Logging functions
log_header() {
    echo -e "\n${BOLD}${CYAN}==>${NC} ${BOLD}$1${NC}"
}

log_step() {
    echo -e "${BOLD}${BLUE}  ->${NC} $1"
}

log_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}${CROSS}${NC} $1" >&2
}

log_info() {
    echo -e "${WHITE}${ARROW}${NC} $1"
}

# Display functions
print_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║               Artix Linux OpenRC Installer               ║"
    echo "║                        Version $VERSION                         ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_config_summary() {
    local summary=(
        "Installation Drive: ${CONFIG[install_drive]:-Not selected}"
        "Boot Mode: ${CONFIG[boot_mode]:-Not detected}"
        "Disk Layout: ${CONFIG[disk_layout]}"
        "Filesystem: ${CONFIG[filesystem]}"
        "Hostname: ${CONFIG[hostname]}"
        "Username: ${CONFIG[username]:-Not set}"
        "Timezone: ${CONFIG[timezone]:-Not set}"
        "Locale: ${CONFIG[locale]}"
        "Keymap: ${CONFIG[keymap]}"
        "Desktop: ${CONFIG[desktop]}"
        "Kernel: ${CONFIG[kernel]}"
        "Swap: ${CONFIG[swap_size]}"
        "ZRAM: ${CONFIG[zram_enabled]}"
        "TRIM: ${CONFIG[trim_enabled]}"
    )
    
    echo -e "${BOLD}${YELLOW}Configuration Summary:${NC}"
    for item in "${summary[@]}"; do
        echo -e "  ${WHITE}•${NC} $item"
    done
    echo
}

# Input functions
input_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    read -rp "$prompt [$default]: " input
    CONFIG["$var_name"]="${input:-$default}"
}

input_password() {
    local prompt="$1"
    local var_name="$2"
    
    while true; do
        read -rsp "$prompt: " pass1
        echo
        read -rsp "Confirm password: " pass2
        echo
        
        if [[ "$pass1" == "$pass2" && ${#pass1} -ge 8 ]]; then
            CONFIG["$var_name"]="$pass1"
            break
        elif [[ ${#pass1} -lt 8 ]]; then
            log_warning "Password must be at least 8 characters"
        else
            log_warning "Passwords do not match"
        fi
    done
}

select_option() {
    local prompt="$1"
    local options=("${@:2}")
    local selected=0
    
    while true; do
        clear
        echo -e "${BOLD}$prompt${NC}"
        echo
        
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                echo -e "${GREEN}${BOLD}❯ ${options[$i]}${NC}"
            else
                echo -e "  ${options[$i]}"
            fi
        done
        
        read -rsn1 key
        case "$key" in
            "A") # Up arrow
                ((selected > 0)) && ((selected--))
                ;;
            "B") # Down arrow
                ((selected < ${#options[@]}-1)) && ((selected++))
                ;;
            "") # Enter
                break
                ;;
        esac
    done
    
    echo "$selected"
}

# System detection
detect_boot_mode() {
    if [[ -d /sys/firmware/efi/efivars ]]; then
        CONFIG[boot_mode]="UEFI"
    else
        CONFIG[boot_mode]="BIOS"
    fi
    log_success "Boot mode detected: ${CONFIG[boot_mode]}"
}

detect_cpu() {
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        echo "intel"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        echo "amd"
    else
        echo "generic"
    fi
}

detect_gpu() {
    if lspci | grep -q -i "nvidia"; then
        echo "nvidia"
    elif lspci | grep -q -i "amd"; then
        echo "amd"
    elif lspci | grep -q -i "intel"; then
        echo "intel"
    else
        echo "generic"
    fi
}

# Disk functions
select_disk() {
    log_header "Select Installation Drive"
    
    local disks=()
    while IFS= read -r line; do
        disks+=("$line")
    done < <(lsblk -d -p -n -l -o NAME,SIZE,TYPE,MODEL | grep disk)
    
    if [[ ${#disks[@]} -eq 0 ]]; then
        log_error "No disks found!"
        exit 1
    fi
    
    local selected=$(select_option "Available disks:" "${disks[@]}")
    CONFIG[install_drive]=$(echo "${disks[$selected]}" | awk '{print $1}')
    
    # Ask for confirmation
    read -rp "WARNING: All data on ${CONFIG[install_drive]} will be destroyed. Continue? (y/N): " confirm
    [[ "$confirm" != "y" ]] && exit 1
}

select_filesystem() {
    local options=("ext4" "btrfs" "xfs" "f2fs")
    local selected=$(select_option "Select filesystem:" "${options[@]}")
    CONFIG[filesystem]="${options[$selected]}"
    
    if [[ "${CONFIG[filesystem]}" == "btrfs" ]]; then
        CONFIG[disk_layout]="btrfs"
    fi
}

select_kernel() {
    local options=("linux" "linux-lts" "linux-zen" "linux-hardened")
    local selected=$(select_option "Select kernel:" "${options[@]}")
    CONFIG[kernel]="${options[$selected]}"
}

# Partitioning functions
create_partitions_auto() {
    log_step "Creating partitions on ${CONFIG[install_drive]}"
    
    # Clear existing partitions
    wipefs -a -f "${CONFIG[install_drive]}" > /dev/null 2>&1
    
    if [[ "${CONFIG[boot_mode]}" == "UEFI" ]]; then
        # UEFI partitioning
        parted "${CONFIG[install_drive]}" mklabel gpt
        parted "${CONFIG[install_drive]}" mkpart primary fat32 1MiB 513MiB
        parted "${CONFIG[install_drive]}" set 1 esp on
        parted "${CONFIG[install_drive]}" mkpart primary ${CONFIG[filesystem]} 513MiB 100%
        
        BOOT_PART="${CONFIG[install_drive]}1"
        ROOT_PART="${CONFIG[install_drive]}2"
    else
        # BIOS partitioning
        parted "${CONFIG[install_drive]}" mklabel msdos
        parted "${CONFIG[install_drive]}" mkpart primary ${CONFIG[filesystem]} 1MiB 100%
        parted "${CONFIG[install_drive]}" set 1 boot on
        
        ROOT_PART="${CONFIG[install_drive]}1"
    fi
    
    # Format partitions
    if [[ "${CONFIG[boot_mode]}" == "UEFI" ]]; then
        mkfs.fat -F32 "$BOOT_PART"
    fi
    
    case "${CONFIG[filesystem]}" in
        "ext4") mkfs.ext4 -F "$ROOT_PART" ;;
        "btrfs") mkfs.btrfs -f "$ROOT_PART" ;;
        "xfs") mkfs.xfs -f "$ROOT_PART" ;;
        "f2fs") mkfs.f2fs -f "$ROOT_PART" ;;
    esac
    
    # Mount partitions
    mount "$ROOT_PART" /mnt
    
    if [[ "${CONFIG[boot_mode]}" == "UEFI" ]]; then
        mkdir -p /mnt/boot
        mount "$BOOT_PART" /mnt/boot
    fi
    
    log_success "Partitions created and mounted"
}

create_btrfs_layout() {
    log_step "Creating btrfs subvolumes"
    
    # Create subvolumes
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    btrfs subvolume create /mnt/@var_log
    btrfs subvolume create /mnt/@var_cache
    
    # Unmount root to remount with subvolume
    umount -R /mnt
    
    # Mount with subvolumes
    mount -o compress=zstd,noatime,subvol=@ "$ROOT_PART" /mnt
    mkdir -p /mnt/{home,.snapshots,var/{log,cache}}
    
    mount -o compress=zstd,noatime,subvol=@home "$ROOT_PART" /mnt/home
    mount -o compress=zstd,noatime,subvol=@snapshots "$ROOT_PART" /mnt/.snapshots
    mount -o compress=zstd,noatime,subvol=@var_log "$ROOT_PART" /mnt/var/log
    mount -o compress=zstd,noatime,subvol=@var_cache "$ROOT_PART" /mnt/var/cache
    
    if [[ "${CONFIG[boot_mode]}" == "UEFI" ]]; then
        mount "$BOOT_PART" /mnt/boot
    fi
    
    log_success "Btrfs subvolumes created"
}

create_swap_file() {
    log_step "Creating swap file"
    
    local swap_size="${CONFIG[swap_size]}"
    fallocate -l "$swap_size" /mnt/swapfile
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    
    log_success "Swap file created ($swap_size)"
}

# Network functions
configure_mirrors() {
    log_step "Configuring pacman mirrors"
    
    local mirror_url="$REPO_BASE/\$repo/os/\$arch"
    local mirror_file="/mnt/etc/pacman.d/mirrorlist"
    
    echo "Server = $mirror_url" > "$mirror_file"
    
    # Enable multilib if requested
    if [[ "${CONFIG[enable_multilib]}" == "true" ]]; then
        sed -i '/^#\[multilib\]/s/^#//' /mnt/etc/pacman.conf
        sed -i '/^#Include = \/etc\/pacman.d\/mirrorlist/s/^#//' /mnt/etc/pacman.conf
    fi
    
    # Enable testing if requested
    if [[ "${CONFIG[enable_testing]}" == "true" ]]; then
        cat >> /mnt/etc/pacman.conf << EOF

[artix-testing]
Include = /etc/pacman.d/mirrorlist

[galaxy-testing]
Include = /etc/pacman.d/mirrorlist
EOF
    fi
    
    log_success "Mirrors configured"
}

# Installation functions
install_base_system() {
    log_header "Installing base system"
    
    local base_packages="base-openrc ${CONFIG[kernel]} linux-firmware"
    local cpu_type=$(detect_cpu)
    local gpu_type=$(detect_gpu)
    
    # CPU microcode
    case "$cpu_type" in
        "intel") base_packages+=" intel-ucode" ;;
        "amd") base_packages+=" amd-ucode" ;;
    esac
    
    # Essential packages
    base_packages+=" pacman-contrib networkmanager-openrc nano vim git bash-completion"
    base_packages+=" elogind-openrc dbus-openrc eudev"
    
    # GPU drivers
    case "$gpu_type" in
        "nvidia") base_packages+=" nvidia nvidia-utils" ;;
        "amd") base_packages+=" mesa vulkan-radeon" ;;
        "intel") base_packages+=" mesa vulkan-intel" ;;
    esac
    
    log_step "Installing: $base_packages"
    basestrap /mnt $base_packages
    
    log_success "Base system installed"
}

generate_fstab() {
    log_step "Generating fstab"
    fstabgen -U /mnt >> /mnt/etc/fstab
    
    # Add swap file to fstab
    if [[ -f /mnt/swapfile ]]; then
        echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
    fi
    
    # Add btrfs mount options if using btrfs
    if [[ "${CONFIG[filesystem]}" == "btrfs" ]]; then
        sed -i 's|subvolid=.*,subvol=/@|compress=zstd,noatime,subvol=/@|' /mnt/etc/fstab
    fi
    
    log_success "Fstab generated"
}

configure_system() {
    log_header "Configuring system"
    
    # Timezone
    ln -sf "/usr/share/zoneinfo/${CONFIG[timezone]}" /mnt/etc/localtime
    artix-chroot /mnt hwclock --systohc --utc
    
    # Localization
    echo "LANG=${CONFIG[locale]}" > /mnt/etc/locale.conf
    echo "${CONFIG[locale]} UTF-8" >> /mnt/etc/locale.gen
    artix-chroot /mnt locale-gen
    
    # Console
    echo "KEYMAP=${CONFIG[keymap]}" > /mnt/etc/vconsole.conf
    echo "FONT=ter-v16n" >> /mnt/etc/vconsole.conf
    
    # Hostname
    echo "${CONFIG[hostname]}" > /mnt/etc/hostname
    
    # Hosts
    cat > /mnt/etc/hosts << EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	${CONFIG[hostname]}.localdomain	${CONFIG[hostname]}
EOF
    
    # Network configuration
    cat > /mnt/etc/conf.d/network << EOF
# Network configuration
dns_domain_lo="localdomain"
hostname="${CONFIG[hostname]}"
EOF
    
    log_success "System configured"
}

configure_bootloader() {
    log_header "Configuring bootloader"
    
    if [[ "${CONFIG[boot_mode]}" == "UEFI" ]]; then
        # Install GRUB for UEFI
        artix-chroot /mnt pacman -S grub efibootmgr os-prober --noconfirm
        artix-chroot /mnt grub-install \
            --target=x86_64-efi \
            --efi-directory=/boot \
            --bootloader-id=Artix \
            --recheck
        
        # Configure GRUB
        cat >> /mnt/etc/default/grub << EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Artix"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX=""
EOF
        
        # Add btrfs to GRUB if needed
        if [[ "${CONFIG[filesystem]}" == "btrfs" ]]; then
            artix-chroot /mnt pacman -S grub-btrfs --noconfirm
            echo "GRUB_DISABLE_OS_PROBER=false" >> /mnt/etc/default/grub
        fi
        
        artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    else
        # Install GRUB for BIOS
        artix-chroot /mnt pacman -S grub --noconfirm
        artix-chroot /mnt grub-install --target=i386-pc "${CONFIG[install_drive]}"
        artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    fi
    
    log_success "Bootloader configured"
}

create_user() {
    log_header "Creating user"
    
    # Set root password
    echo "root:${CONFIG[root_password]}" | chpasswd -R /mnt
    
    if [[ -n "${CONFIG[username]}" ]]; then
        # Create user with home directory
        artix-chroot /mnt useradd -m -G wheel,audio,video,storage -s /bin/bash "${CONFIG[username]}"
        echo "${CONFIG[username]}:${CONFIG[user_password]}" | chpasswd -R /mnt
        
        # Configure sudo
        echo "%wheel ALL=(ALL:ALL) ALL" >> /mnt/etc/sudoers
        echo "Defaults timestamp_timeout=30" >> /mnt/etc/sudoers
        echo "Defaults insults" >> /mnt/etc/sudoers
    fi
    
    log_success "User created"
}

install_desktop_environment() {
    [[ "${CONFIG[desktop]}" == "none" ]] && return
    
    log_header "Installing ${CONFIG[desktop]} desktop"
    
    local packages="${DESKTOP_PACKAGES[${CONFIG[desktop]}]}"
    local service="${DESKTOP_SERVICES[${CONFIG[desktop]}]}"
    
    # Common packages for all desktops
    local common_packages="xorg-server xorg-xinit mesa xdg-user-dirs xdg-utils"
    
    # Audio
    common_packages+=" pulseaudio pulseaudio-alsa alsa-utils"
    
    # Fonts
    common_packages+=" ttf-dejavu ttf-liberation noto-fonts"
    
    # Utilities
    common_packages+=" firefox kitty thunar gparted"
    
    log_step "Installing desktop packages"
    artix-chroot /mnt pacman -S $packages $common_packages --noconfirm
    
    # Enable display manager service if specified
    if [[ -n "$service" ]]; then
        artix-chroot /mnt rc-update add "$service" default
    fi
    
    # Configure autologin for display manager
    if [[ -f "/mnt/etc/lightdm/lightdm.conf" ]]; then
        sed -i 's/^#autologin-user=/autologin-user='"${CONFIG[username]}"'/' \
            /mnt/etc/lightdm/lightdm.conf
    fi
    
    log_success "Desktop environment installed"
}

install_additional_packages() {
    log_header "Installing additional packages"
    
    local additional=""
    
    # Network tools
    additional+=" wpa_supplicant-openrc networkmanager-openrc nm-connection-editor"
    additional+=" openssh-openrc curl wget"
    
    # Development tools
    additional+=" base-devel git python nodejs npm"
    
    # Media
    additional+=" vlc gimp audacious"
    
    # System tools
    additional+=" htop neofetch btop rsync"
    
    # File systems
    if [[ "${CONFIG[filesystem]}" == "btrfs" ]]; then
        additional+=" btrfs-progs snapper snap-pac"
    fi
    
    # ZRAM
    if [[ "${CONFIG[zram_enabled]}" == "true" ]]; then
        additional+=" zram-init-openrc"
    fi
    
    log_step "Installing: $additional"
    artix-chroot /mnt pacman -S $additional --noconfirm
    
    log_success "Additional packages installed"
}

configure_zram() {
    [[ "${CONFIG[zram_enabled]}" != "true" ]] && return
    
    log_step "Configuring ZRAM"
    
    cat > /mnt/etc/conf.d/zram << 'EOF'
# ZRAM configuration
ZRAM_ALGORITHM=lz4
ZRAM_FRACTION=0.5
ZRAM_PRIORITY=100
EOF
    
    artix-chroot /mnt rc-update add zram default
    log_success "ZRAM configured"
}

configure_trim() {
    [[ "${CONFIG[trim_enabled]}" != "true" ]] && return
    
    log_step "Configuring TRIM"
    
    # Enable weekly TRIM for SSDs
    cat > /mnt/etc/cron.weekly/fstrim << 'EOF'
#!/bin/bash
/sbin/fstrim -v /
EOF
    
    chmod +x /mnt/etc/cron.weekly/fstrim
    
    # Enable continuous TRIM for btrfs
    if [[ "${CONFIG[filesystem]}" == "btrfs" ]]; then
        echo "MOUNT_OPTIONS=\"compress=zstd,noatime,autodefrag\"" >> /mnt/etc/conf.d/btrfs
    fi
    
    log_success "TRIM configured"
}

configure_services() {
    log_header "Configuring services"
    
    # Enable essential services
    artix-chroot /mnt rc-update add dbus default
    artix-chroot /mnt rc-update add NetworkManager default
    artix-chroot /mnt rc-update add sshd default
    artix-chroot /mnt rc-update add cronie default
    artix-chroot /mnt rc-update add elogind default
    
    # Disable console font service (causes issues)
    artix-chroot /mnt rc-update del consolefont boot
    
    log_success "Services configured"
}

run_chroot_commands() {
    log_header "Running post-installation commands"
    
    # Update package database
    artix-chroot /mnt pacman -Sy
    
    # Generate initramfs
    artix-chroot /mnt mkinitcpio -P
    
    # Set permissions
    chmod 700 /mnt/root
    if [[ -n "${CONFIG[username]}" ]]; then
        chown -R "${CONFIG[username]}:${CONFIG[username]}" "/mnt/home/${CONFIG[username]}"
    fi
    
    log_success "Post-installation commands completed"
}

# Interactive configuration
interactive_config() {
    print_banner
    
    # Step 1: Disk selection
    select_disk
    
    # Step 2: Disk layout
    log_header "Disk Configuration"
    local layout_options=("Auto (recommended)" "Manual" "Btrfs with subvolumes")
    local layout_choice=$(select_option "Select disk layout:" "${layout_options[@]}")
    
    case "$layout_choice" in
        0) CONFIG[disk_layout]="auto" ;;
        1) CONFIG[disk_layout]="manual"
           log_warning "Manual partitioning not yet implemented. Using auto."
           CONFIG[