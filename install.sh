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

#TODO: Add mirrorlist using reflector
log "Updating system"
sudo pacman -Syu --noconfirm

log "Installing dependencies"

dependencies=(
  xorg-server
  xorg-apps 
  xorg-xinit
  iw
  wpa_supplicant
  dialog
  intel-ucode
  git
  reflector
  lshw
  unzip
  htop
  wget
  pulseaudio
  alsa-utils
  alsa-plugins
  pavucontrol
  xdg-user-dirs
  man
)

sudo pacman -S --needed --noconfirm ${dependencies[@]} 

log "Installing packages"

packages=(
  i3-gaps
  lightdm 
  lightdm-gtk-greeter
  dmenu
  rofi
  neovim
  polybar
  picom
  firefox
  alacritty
  zsh
  zsh-completions
  neofetch
  feh
  lxappearance
  thunar
  arc-gtk-theme
  papirus-icon-theme
  materia-gtk-theme
  ripgrep
  tk
  sxhkd
  fzf
  htop
  obsidian
  docker
)

sudo pacman -S --needed --noconfirm ${packages[@]}

#lightdm
sudo systemctl enable lightdm

#docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

log "Installing yay"

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm --needed -si
cd -

log "Installing Oh My Zsh (zsh)"

bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended


log "Installing Powerlevel10k (zsh)"

yay -S --noconfirm zsh-theme-powerlevel10k-git
sudo pacman -S --noconfirm powerline-common awesome-terminal-fonts
yay -S --noconfirm ttf-meslo-nerd-font-powerlevel10k

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $~/.oh-my-zsh/custom/themes/powerlevel10k

log "Installing Zsh plugins"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

log "Installing nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

log "Installing pyenv"

curl https://pyenv.run | bash

log "Installing poetry"

curl -sSL https://install.python-poetry.org | python3 -
log "Installing Fonts"

declare -a fonts=(
  NerdFontsSymbolsOnly
	FiraCode
	FiraMono
	JetBrainsMono
)

version='2.3.3'
fonts_dir="${HOME}/.local/share/fonts"

if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
fi

cd "$fonts_dir"

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    unzip "$zip_file" 
    find . -type f ! -name '*.*tf' -delete
done

find -name '*Windows Compatible*' -delete

fc-cache -fv

cd -

input "Do you want to install bluetooth drivers?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm bluez bluez-utils blueman
    sudo systemctl enable bluetooth
fi

input "Is this a laptop?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm tlp tlp-rdw powertop acpi
    sudo systemctl enable tlp
    sudo systemctl enable tlp-sleep
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
fi

input "Is this a ThinkPad?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm acpi_call
fi

input "Are you using an SSD?"

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo systemctl enable fstrim.timer
fi

log "Cloning repository"

git clone https://github.com/JulianVentura/dotfiles.git ~/dotfiles

log "Creating symlinks"

sudo ln -sf ~/dotfiles/pacman.conf /etc/
ln -sf ~/dotfiles/Wallpapers ~/
ln -sf ~/dotfiles/Scripts ~/
ln -sf ~/dotfiles/.gitconfig ~/
ln -sf ~/dotfiles/.gtkrc-2.0 ~/
ln -sf ~/dotfiles/.p10k.zsh ~/
ln -sf ~/dotfiles/.zshrc ~/
ln -sf ~/dotfiles/alacritty ~/.config/
ln -sf ~/dotfiles/i3 ~/.config/
ln -sf ~/dotfiles/nvim ~/.config/
ln -sf ~/dotfiles/picom ~/.config/
ln -sf ~/dotfiles/polybar ~/.config/
ln -sf ~/dotfiles/rofi ~/.config/

log "Installation finished, reboot needed."
input -p "Reboot now?" -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot
fi

