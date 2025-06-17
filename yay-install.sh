#!/bin/bash

if ! command -v yay &> /dev/null
then
    echo "yay is not installed, Installing yay..."
    sudo pacman -Syu --needed git base-devel --noconfirm

    git clone https://aur.archlinux.org/yay.git

    cd yay

    makepkg -si

    cd ..
    rm -rf yay

    echo "yay has been installed"
fi
