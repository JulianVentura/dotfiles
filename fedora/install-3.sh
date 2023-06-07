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
sudo dnf update -y

##Add external repos
sudo rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
## For zsh-completions
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_36/shells:zsh-users:zsh-completions.repo

log "Installing dependencies"

dependencies=(
  htop
  gcc
  g++
  patch
  zlib-devel
  bzip2
  bzip2-devel
  readline-devel
  sqlite
  sqlite-devel
  openssl-devel
  tk-devel
  libffi-devel
  xz-devel
  libuuid-devel
  gdbm-devel
  libnsl2-devel
)

sudo dnf install -y ${dependencies[@]} 

log "Installing packages"

packages=(
 alacritty
 zsh
 zsh-completions
 neofetch
 ripgrep
 fzf
 docker
 docker-compose
 tmux
)


sudo dnf install -y ${packages[@]}


log "Installing tmux plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

## Add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Postman
flatpak install -y flathub com.getpostman.Postman

#docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

log "Installing Oh My Zsh (zsh)"

bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

log "Installing Powerlevel10k (zsh)"

sudo dnf install -y powerline powerline-fonts

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

log "Installing Zsh plugins"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

log "Installing nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash


log "Installing latest Node LTS"

nvm install --lts

log "Installing pyenv"

curl https://pyenv.run | bash

log "Installing poetry"

curl -sSL https://install.python-poetry.org | python3 -


log "Installing Fonts"

declare -a fonts=(
  NerdFontsSymbolsOnly
	JetBrainsMono
)

version='2.3.3'
fonts_dir="/usr/local/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
    sudo mkdir -p "$fonts_dir"
fi

git clone https://github.com/gabrielelana/awesome-terminal-fonts atf
sudo cp atf/build/* ${fonts_dir}
rm -rf atf

cd "$fonts_dir"

for font in "${fonts[@]}"; do
   zip_file="${font}.zip"
   download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
   echo "Downloading $download_url"
   sudo wget "$download_url"
   sudo unzip "$zip_file" 
   sudo find . -type f ! -regex '\(.+\.sh\)\|\(.+\.ttf\)' -delete
done

sudo find -name '*Windows Compatible*' -delete

fc-cache -fv

cd -

#input "Is this a laptop?"
## Installs dependencies for TLP, a power management utility
#
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#   echo "NOT PORTED"  
#   # sudo pacman -S --noconfirm tlp tlp-rdw powertop acpi
#   # sudo systemctl enable tlp
#   # sudo systemctl enable tlp-sleep
#   # sudo systemctl mask systemd-rfkill.service
#   # sudo systemctl mask systemd-rfkill.socket
#fi
#

log "Installing KWin Plugins"

plugins_directory="/usr/share/kwin/manual"
if [[ ! -d "$plugins_directory" ]]; then
  sudo mkdir -p "$plugins_directory"
fi

sudo git clone https://github.com/d86leader/dynamic_workspaces.git "${plugins_directory}/dynamic_workspaces"
cd "${plugins_directory}/dynamic_workspaces"
plasmapkg2 --type kwinscript -i .

cd - 

#input "Is this a ThinkPad?"
#
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#   echo "NOT PORTED"  
#   #sudo pacman -S --noconfirm acpi_call
#fi

log "Cloning repository"

git clone https://github.com/JulianVentura/dotfiles.git ~/dotfiles

log "Creating symlinks"

sudo ln -sf ~/dotfiles/fedora/dnf.conf /etc/
sudo ln -sf ~/dotfiles/common/Wallpapers ~/
sudo ln -sf ~/dotfiles/common/.gitconfig ~/
sudo ln -sf ~/dotfiles/common/.p10k.zsh ~/
sudo ln -sf ~/dotfiles/common/.zshrc ~/
sudo ln -sf ~/dotfiles/common/alacritty ~/.config/
sudo ln -sf ~/dotfiles/common/nvim ~/.config/
sudo ln -sf ~/dotfiles/common/.tmux.conf ~/
sudo ln -sf ~/dotfiles/common/pypoetry ~/.config
sudo ln -sf ~/dotfiles/fedora/dconf ~/.config
sudo ln -sf ~/dotfiles/fedora/gtk-3.0 ~/.config
sudo ln -sf ~/dotfiles/fedora/gtk-4.0 ~/.config
sudo ln -sf ~/dotfiles/fedora/gtkrc-2.0 ~/.config
sudo ln -sf ~/dotfiles/fedora/kcmfonts ~/.config
sudo ln -sf ~/dotfiles/fedora/kdeglobals ~/.config
sudo ln -sf ~/dotfiles/fedora/kglobalshortcutsrc ~/.config
sudo ln -sf ~/dotfiles/fedora/plasma-org.kde.plasma.desktop-appletsrc ~/.config

log "Installation finished, reboot needed."
input "Reboot now?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
   sudo reboot
fi
