#!/bin/bash

#sudo apt install tmux neovim -y  #Need to have this already for off-line install

mkdir -p ~/.config/nvim
cp -r lua ~/.config/nvim
cp -r plugin ~/.config/nvim
cp -r doc  ~/.config/nvim
echo 'require("mousetrap")' >> ~/.config/nvim/init.lua

