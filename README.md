# Initial setup
	1. setfont ter-120n
	2. Network Setup
		1. iwctl
		2. device list
		3. station wlan0 get-networks
		4. station wlan0 connect {{SSID}}
		5. exit
	3. ping 1.1.1.1 (test connection)
	4. Locale Settings
		1. timedatectl
		2. timedatectl list-timezones | grep {{zone}}
		3. timedatectl set-timezone {{zone}}
		4. timedatectl set-ntp true
	5. pacman -Sy (sync package database)
	6. pacman -Sy archlinux-keyring

# Disk partitioning
	1. lsblk
	2. cfdisk /dev/{{id}}
	3. Partitions
		1. EFI System (1G)
		2. Linux Filesystem (>32G)
	4. Formatting
		1. mkfs.fat -F32 /dev/{{EFI Partition}}
		2. mkfs.btrfs /dev/{{Linux Partition}}

# BTRFS Config
	1. mount /dev/{{linux}} /mnt
	2. btrfs subvolume create /mnt/@
	3. btrfs subvolume create /mnt/@home
	4. umount /mnt
	5. mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@ /dev/{{linux}} /mnt
	6. mount --mkdir -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@home /dev/{{linux}} /mnt/home
	7. mount --mkdir /dev/{{efi}} /mnt/boot

# Installing Linux
	1. Base Installation
		1. pacstrap /mnt base base-devel linux linux-headers linux-firmware btrfs-progs timeshift sudo networkmanager grub grub-btrfs efibootmgr
		2. Extras
			1. amd-ucode / intel-ucode
			2. ntfs-3g (ntfs filesystem support)
			3. git
			4. bluez & bluez-utils (Bluetooth support)
	2. Fstab (auto mounting partitions)
		1. genfstab -U /mnt >> /mnt/etc/fstab
		2. cat /mnt/etc/fstab (check for correct configuration)

# Completing install
	1. arch-chroot /mnt
	2. Locale Settings
		1. ln -sf /usr/share/zoneinfo/{{zone}} /etc/localtime
		2. hwclock --systohc
		3. EDITOR /etc/locale.gen
			1. (Uncomment your locale)
		4. locale-gen
		5. echo "LANG={{locale}}" >> /etc/locale.conf (eg locale: en_US.UTF-8)
		6. echo "{{hostname}}" >> /etc/hostname (hostname can be anything)
	3. Passwords and User
		1. passwd (set your system password)
		2. useradd -m -g users -G wheel,storage,power,audio,video {{username}}
		3. passwd {{username}}
		4. echo "{{username}} ALL=(ALL) ALL" >> /etc/sudoers.d/{{username}} (gives your user permission to use sudo)
	4. Grub
		1. grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
		2. grub-mkconfig -o /boot/grub/grub.cfg
	5. systemctl enable NetworkManager
	6. systemctl enable bluetooth (if bluetooth was installed)
	7. exit
	8. umount -lR /mnt
	9. shutdown now
	10. (remove installation usb)

# Personal setup
	1. Login to your user
	2. WiFi
		1. nmcli dev status
		2. nmcli radio wifi on
		3. nmcli dev wifi list
		4. sudo nmcli dev wifi connect {{SSID}} password "{{password}}"
	3. sudo pacman -Syu
	4. Dotfiles setup
		1. git clone https://github.com/paul-s-cameron/dotfiles.git ~/.dotfiles
		2. sh ~/.dotfiles/install
