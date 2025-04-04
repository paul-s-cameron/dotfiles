#!/bin/bash

# Check if oh-my-zsh is installed
if [ ! -d "$HOME/.oh-my-zsh/tools" ]; then
  echo 'Installing oh-my-zsh'
  rm -rf $HOME/.oh-my-zsh
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
