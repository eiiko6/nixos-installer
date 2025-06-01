DISK="/dev/sda"

umount -A -R /mnt         # make sure everything is unmounted before we start
sgdisk -Z ${DISK}         # zap all on disk
sgdisk -a 2048 -o ${DISK} # new GPT disk 2048 alignment

# Create partitions
sgdisk -n 1::+500M --typecode=1:ef00 --change-name=1:"BOOT" ${DISK} # partition 1 (UEFI boot partition)
sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:"ROOT" ${DISK}    # partition 3 (Root), default start, remaining
partprobe ${DISK}                                                   # reread partition table to ensure it is correct

mkfs.fat -F32 -n "BOOT" ${DISK}1
mkfs.ext4 -F -L "ROOT" ${DISK}2

mount ${DISK}3 /mnt
mount --mkdir ${DISK}1 /mnt/boot

nixos-generate-config --root /mnt

export NIX_CONFIG="experimental-features = nix-command flakes"
