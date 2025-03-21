#!/bin/bash

if ! command -v yay &> /dev/null; then
  echo "Installing yay"

  # Dependencies
  sudo pacman -S --needed git base-devel

  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si

  # Cleanup
  cd ..
  rm -r yay

  echo "Yay installation complete"
else
  echo "Yay is installed"
fi

echo "Installing packages"
yay -S --needed --noconfirm - < ~/.dotfiles/packages |& grep -v "skipping"

# Check if oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo 'Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo 'Updating oh-my-zsh'
  $ZSH/tools/upgrade.sh
fi

# Change default shell
if [[ ${SHELL##*/} != "zsh" ]]; then
  echo 'Changing default shell to zsh'
  sudo chsh -s /bin/zsh $(whoami)
else
  echo 'Already using zsh'
fi
