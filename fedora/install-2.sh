#!/bin/bash

#### Get the UUID of your btrfs system root.
ROOT_UUID="$(sudo grub2-probe --target=fs_uuid /)"

#### Get the btrfs subvolume mount options from your fstab.
OPTIONS="$(grep -m 1 '/home' /etc/fstab | awk '{print $4}' | cut -d, -f2-)"

# Create directory path
sudo mkdir -vp /var/lib/libvirt

# Create btrfs subvolumes
SUBVOLUMES=(
    "opt"
    "var/cache"
    "var/crash"
    "var/log"
    "var/spool"
    "var/tmp"
    "var/www"
    "var/lib/AccountsService"
    "var/lib/gdm"
    "var/lib/libvirt/images"
    "home/$USER/.mozilla"
)

for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}" ]] ; then
        sudo mv -v "/${dir}" "/${dir}-old"
        sudo btrfs subvolume create "/${dir}"
        sudo cp -ar "/${dir}-old/." "/${dir}/"
    else
        sudo btrfs subvolume create "/${dir}"
    fi
    sudo restorecon -RF "/${dir}"
    printf "%-41s %-24s %-5s %-s %-s\n" \
        "UUID=${ROOT_UUID}" \
        "/${dir}" \
        "btrfs" \
        "subvol=${dir},${OPTIONS}" \
        "0 0" | \
        sudo tee -a /etc/fstab
done

# Change permissions of some directories
sudo chmod 1777 /var/tmp
sudo chmod 1770 /var/lib/gdm
sudo chown -R $USER: /home/$USER/.mozilla

# Reload fstab
sudo systemctl daemon-reload

# Delete old directories
for dir in "${SUBVOLUMES[@]}" ; do
    if [[ -d "/${dir}-old" ]] ; then
        sudo rm -rf "/${dir}-old"
    fi
done

# Install snapper
sudo dnf5 install -y snapper python3-dnf-plugin-snapper

# Create snapper subvolumes configuration
sudo snapper -c root create-config /
sudo snapper -c home create-config /home

# Allow current user to use snapper without root privileges
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_ACL=yes
sudo snapper -c home set-config ALLOW_USERS=$USER SYNC_ACL=yes

# Add new snapshots to fstab
SNAPSHOTS=(
    ".snapshots"
    "home/.snapshots"
)

for dir in "${SNAPSHOTS[@]}" ; do
    printf "%-41s %-24s %-5s %-s %-s\n" \
        "UUID=${ROOT_UUID}" \
        "/${dir}" \
        "btrfs" \
        "subvol=${dir},${OPTIONS}" \
        "0 0" | \
        sudo tee -a /etc/fstab
done

sudo systemctl daemon-reload

# Disabling indexing of the .snapshots directories
echo 'PRUNENAMES = ".snapshots"' | sudo tee -a /etc/updatedb.conf

# Enable snapshot booting
echo 'SUSE_BTRFS_SNAPSHOT_BOOTING="true"' | sudo tee -a /etc/default/grub
sudo sed -i '1i set btrfs_relative_path="yes"' /boot/efi/EFI/fedora/grub.cfg
sudo grub2-mkconfig -o /boot/grub2/grub.cfg


# Clone and install grub-btrfs
git clone https://github.com/Antynea/grub-btrfs
cd grub-btrfs

sed -i '/#GRUB_BTRFS_SNAPSHOT_KERNEL/a GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="systemd.volatile=state"' config
sed -i '/#GRUB_BTRFS_GRUB_DIRNAME/a GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"' config
sed -i '/#GRUB_BTRFS_MKCONFIG=/a GRUB_BTRFS_MKCONFIG=/sbin/grub2-mkconfig' config
sed -i '/#GRUB_BTRFS_SCRIPT_CHECK=/a GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check' config

sudo make install
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo systemctl enable --now grub-btrfsd.service

cd ..
rm -rvf grub-btrfs

# Create a system root snapshot and set it as the default

sudo mkdir -v /.snapshots/1
sudo bash -c "cat > /.snapshots/1/info.xml" <<EOF
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>$(date -u +"%F %T")</date>
  <description>first root subvolume</description>
</snapshot>
EOF

sudo btrfs subvolume snapshot / /.snapshots/1/snapshot

SNAP_ID="$(sudo btrfs inspect-internal rootid /.snapshots/1/snapshot)"
sudo btrfs subvolume set-default ${SNAP_ID} / 

# Reboot system
sudo reboot

