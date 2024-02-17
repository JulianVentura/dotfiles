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
 bat
 fd-find
 docker
 docker-compose
 tmux
)


sudo dnf install -y ${packages[@]}

log "Installing codecs"
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y lame\* --exclude=lame-devel

log "Installing tmux plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

## Add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Postman with retry logic as it uses to timeout
for i in 1 2 3; do flatpak install -y flathub com.getpostman.Postman && break || sleep 1; done

# Install Discord
for i in 1 2 3; do flatpak install -y flathub com.discordapp.Discord && break || sleep 1; done

# Install Typora
for i in 1 2 3; do flatpak install flathub io.typora.Typora && break || sleep 1; done

#docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

log "Installing Oh My Zsh (zsh)"

#This will execute ohmizsh install.sh script and answer with "No" in its prompt
curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install.sh &&
sed -i 's/CHSH=no/CHSH=yes/g' /tmp/install.sh &&
echo "N" | sh /tmp/install.sh 

#Change default shell to zsh
chsh -s /usr/bin/zsh

log "Installing Powerlevel10k (zsh)"

sudo dnf install -y powerline powerline-fonts

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

log "Installing Zsh plugins"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

log "Installing nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Source .bashrc to reload config and use nvm
source ~/.bashrc

log "Installing latest Node LTS"

nvm install --lts

log "Installing pyenv"


# Install npm global packages
# npm install -g tldr

curl https://pyenv.run | bash

log "Installing poetry"

curl -sSL https://install.python-poetry.org | python3 -

log "Installing Rust"

curl https://sh.rustup.rs -sSf | sh -s -- -y

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
temp_directory="/tmp"

if [[ ! -d "$plugins_directory" ]]; then
  sudo mkdir -p "$plugins_directory"
fi

sudo git clone https://github.com/d86leader/dynamic_workspaces.git "${plugins_directory}/dynamic_workspaces"
cd "${plugins_directory}/dynamic_workspaces"
plasmapkg2 --type kwinscript -i .

cd - 

#Tiling window manager
git clone https://github.com/zeroxoneafour/polonium.git "${temp_directory}/polonium"
cd "${temp_directory}/polonium"
make
cd -
sudo mv "${temp_directory}/polonium" "${plugins_directory}"

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

lynk () {
  #This function will ensure that the destiniy file or directory not exists (deleting it)
  #and then it will create a symbolik lynk to it
  file_path=$1
  lynk_directory=$2
  file_name=$(basename $file_path)
  lynk_path="$lynk_directory/$file_name"
  if [[ -d $lynk_path ]]; then
    sudo rm -rf $lynk_path
  elif [[ -L $lynk_path ]]; then
    sudo rm $lynk_path
  fi

  sudo ln -sf $file_path $lynk_directory 
}

lynk ~/dotfiles/fedora/dnf.conf /etc/
lynk ~/dotfiles/common/Wallpapers ~/
lynk ~/dotfiles/common/.gitconfig ~/
lynk ~/dotfiles/common/.p10k.zsh ~/
lynk ~/dotfiles/common/.zshrc ~/
lynk ~/dotfiles/common/alacritty ~/.config/
lynk ~/dotfiles/common/nvim ~/.config/
lynk ~/dotfiles/common/.tmux.conf ~/
lynk ~/dotfiles/common/pypoetry ~/.config
lynk ~/dotfiles/fedora/dconf ~/.config
lynk ~/dotfiles/fedora/gtk-3.0 ~/.config
lynk ~/dotfiles/fedora/gtk-4.0 ~/.config
lynk ~/dotfiles/fedora/gtkrc ~/.config
lynk ~/dotfiles/fedora/gtkrc-2.0 ~/.config
lynk ~/dotfiles/fedora/kcmfonts ~/.config
lynk ~/dotfiles/fedora/kdeglobals ~/.config
lynk ~/dotfiles/fedora/kglobalshortcutsrc ~/.config
lynk ~/dotfiles/fedora/plasma-org.kde.plasma.desktop-appletsrc ~/.config
lynk ~/dotfiles/fedora/fontconfig ~/.config
lynk ~/dotfiles/fedora/kcminputrc ~/.config
lynk ~/dotfiles/fedora/kded5rc ~/.config
lynk ~/dotfiles/fedora/krunnerrc ~/.config
lynk ~/dotfiles/fedora/kwinrc ~/.config
lynk ~/dotfiles/fedora/systemsettingsrc ~/.config
lynk ~/dotfiles/fedora/xsettingsd ~/.config
lynk ~/dotfiles/common/.cargo/env ~/.cargo/env
lynk ~/dotfiles/common/.profiles ~/.profile

# Add file filters to git ignore
cd ~/dotfiles
~/dotfiles/common/git-config-setup.sh

log "Installation finished, reboot needed."
input "Reboot now?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
   sudo reboot
fi
