#!/bin/bash

echo "Updating system"
sudo pacman -Syu --noconfirm

echo "Cloning repository"

git clone https://github.com/JulianVentura/dotfiles.git ~/dotfiles

echo "Installing dependencies"

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
  pa-applet-git
  alsa-utils
  alsa-plugins
  pavucontrol
  xdg-user-dirs
)

sudo pacman -S --needed --noconfirm ${dependencies[@]} 

echo "Installing packages"

packages=(
  i3-gaps
  lightdm 
  lightdm-gtk-greeter
  dmenu
  rofi
  nvim
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
sudo systemctl status docker.service 
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

echo "Installing yay"

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd -

echo "Installing Oh My Zsh (zsh)"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing Powerlevel10k (zsh)"

yay -S --noconfirm zsh-theme-powerlevel10k-git
sudo pacman -S --noconfirm powerline-common awesome-terminal-fonts
yay -S --noconfirm ttf-meslo-nerd-font-powerlevel10k

echo "Installing Zsh plugins"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

echo "Installing nvm"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

echo "Installing pyenv"

curl https://pyenv.run | bash

echo "Installing poetry"

curl -sSL https://install.python-poetry.org | python3 -
echo "Installing Fonts"

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

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading $download_url"
    wget "$download_url"
    unzip "$zip_file" -d "$fonts_dir"
    find . -type f ! -name '*.ttf' -delete
done

find "$fonts_dir" -name '*Windows Compatible*' -delete

fc-cache -fv

read -p "Do you want to install bluetooth drivers?  (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm bluez bluez-utils blueman
    sudo systemctl enable bluetooth
fi

read -p "Is this a laptop? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm tlp tlp-rdw powertop acpi
    sudo systemctl enable tlp
    sudo systemctl enable tlp-sleep
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
fi

read -p "Is this a ThinkPad? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo pacman -S --noconfirm acpi_call
fi

read -p "Are you using an SSD? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo systemctl enable fstrim.timer
fi

echo "Creating symlinks"

sudo ln -s ~/dotfiles/pacman.conf /etc/
ln -s ~/dotfiles/.gitconfig ~/
ln -s ~/dotfiles/.gtkrc-2.0 ~/
ln -s ~/dotfiles/.p10k.zsh ~/
ln -s ~/dotfiles/.zshrc ~/
ln -s ~/dotfiles/alacritty ~/.config/
ln -s ~/dotfiles/i3 ~/.config/
ln -s ~/dotfiles/nvim ~/.config/
ln -s ~/dotfiles/picom ~/.config/
ln -s ~/dotfiles/polybar ~/.config/
ln -s ~/dotfiles/rofi ~/.config/

echo "Installation finished, reboot needed."
read -p "Reboot now? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
    reboot
fi

