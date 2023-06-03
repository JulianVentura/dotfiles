#!/bin/bash

# Auxiliary functions
log () {
    Green='\033[1;32m' 
    Reset='\033[0m'
    echo -e "${Green}$@${Reset}"
    echo
}

input () {
    Green=$'\e[1;32m' 
    Reset=$'\e[0m'
    read -p "${Green}$@ (y/n): ${Reset}" -n 1 -r
    echo
    echo
}

log "Updating system"
sudo dnf upgrade -y

#Add external repos
sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# For zsh-completions
dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_36/shells:zsh-users:zsh-completions.repo

log "Installing new dnf package manager"

sudo dnf install -y dnf5 dnf5-plugins
# Changing dnf from version 3 to version 5
sudo ln -sf /bin/dnf5 /bin/dnf 

log "Installing dependencies"

dependencies=(
  git
  htop
)

sudo dnf install -y ${dependencies[@]} 

log "Installing packages"

packages=(
  neovim
  firefox
  alacritty
  zsh
  zsh-completions
  neofetch
  ripgrep
  fzf
  docker
  docker-compose
)


sudo dnf install -y ${packages[@]}

# Add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Postman
flatpak install flathub com.getpostman.Postman

#docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

log "Installing Oh My Zsh (zsh)"

bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

log "Installing Powerlevel10k (zsh)"

sudo dnf -y zsh-theme-powerlevel10k-git
sudo dnf -y powerline-common awesome-terminal-fonts
sudo dnf -y ttf-meslo-nerd-font-powerlevel10k

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

log "Installing Zsh plugins"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

log "Installing nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

log "Installing pyenv"

curl https://pyenv.run | bash

log "Installing poetry"

curl -sSL https://install.python-poetry.org | python3 -

input "Is this a laptop?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
   echo "NOT PORTED"  
   # sudo pacman -S --noconfirm tlp tlp-rdw powertop acpi
   # sudo systemctl enable tlp
   # sudo systemctl enable tlp-sleep
   # sudo systemctl mask systemd-rfkill.service
   # sudo systemctl mask systemd-rfkill.socket
fi

input "Is this a ThinkPad?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
   echo "NOT PORTED"  
   #sudo pacman -S --noconfirm acpi_call
fi

input "Are you using an SSD?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "NOT PORTED"  
    #sudo systemctl enable fstrim.timer
fi

log "Cloning repository"

git clone https://github.com/JulianVentura/dotfiles.git ~/dotfiles

log "Creating symlinks"

sudo ln -sf ~/dotfiles/fedora/dnf.conf /etc/
sudo ln -sf ~/dotfiles/common/Wallpapers ~/
sudo ln -sf ~/dotfiles/common/.gitconfig ~/
sudo ln -sf ~/dotfiles/common/.p10k.zsh ~/
sudo ln -sf ~/dotfiles/common/.zshrc ~/
sudo ln -sf ~/dotfiles/common/alacritty ~/.config/
sudo ln -sf ~/dotfiles/nvim ~/.config/

log "Installation finished, reboot needed."
input "Reboot now?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
fi

