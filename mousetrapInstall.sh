#!/bin/bash

mkdir -p ~/.config/nvim
cp -r lua ~/.config/nvim
cp -r plugin ~/.config/nvim
cp -r doc  ~/.config/nvim
echo 'require("mousetrap")' >> ~/.config/nvim/init.lua
sudo apt install tmux neovim -y

