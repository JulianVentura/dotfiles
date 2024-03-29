#!/bin/bash

input () {
    Green=$'\e[1;32m' 
    Reset=$'\e[0m'
    read -p "${Green}$@ (y/n): ${Reset}" -n 1 -r
    echo
    echo
}

#Eliminate grub2 write error on boot
sudo grub2-editenv - unset menu_auto_hide

#Add a label to / btrfs volume
sudo btrfs filesystem label / Fedora

#Modify dnf config to improve downlaod speeds
sudo bash -c 'cat >> /etc/dnf/dnf.conf' <<EOF
fastestmirror=True
max_parallel_downloads=10
EOF

#Clear and update local dnf cache
sudo dnf clean all
sudo dnf makecache

#Install new dnf package manager dnf5
#sudo dnf install -y dnf5 dnf5-plugins

#Change symlink of dnf from dnf3 to dnf5
#sudo ln -sf /bin/dnf5 /bin/dnf

#Install dependencies
sudo dnf install -y neovim inotify-tools make git

# Update system and reboot
sudo dnf update

input "Reboot now?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
   sudo reboot
fi
