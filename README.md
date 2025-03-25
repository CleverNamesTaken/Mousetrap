# Description

Mousetrap is a neovim plugin that uses tmux and scripted windows to allow users to execute complex terminal operations by keeping your hands on the keyboard and off of the mouse.  The major goal is to reduce cognitive load by working in a nvim instance and actively documenting your actions as you operate.

Mousetrap is similar to vim-slime, but more tmux specific with better terminal navigation and logging features.  Credit to Erik Falor's talk [Vim Muggle to Wizard in 10 Easy Steps](youtube.com/watch?v=-7RSVclyOEg) for unlocking the Wizardry of vim.

# Why use Mousetrap?

When conducting red team assessments, I wanted to improve my efficiency and logging.  I found that I could address both of these goals by primarilly operating within vim.  By synergizing tmux, [ultisnips](https://github.com/SirVer/ultisnips) and vim, I could:

1) Stay focused on the objective at hand by remaining in vim and sending my commands to tmux windows.
2) Stay consistent by using red team playbooks developed and stored as Ultisnips snippets.
3) Log my activities by parsing the output of my tmux and scripted windows, and saving them off as yaml files.
4) Quickly reconstruct my activities by logging all commands send through vim in a csv.

# Installation

I don't really enjoy plugin managers, so here is how you do it manually:
1) Pull down repo
2) Move `lua` folder to `~/.config/nvim`
3) Move `plugin` folder to `~/.config/nvim`
4) Add `require("mousetrap")` to `init.lua`
5) Install dependencies
`apt install tmux neovim -y`

Running `mousetrapInstall.sh` will do this as well.

# Tutorial

See TUTORIAL.md

# Similar projects

[vim slime](https://github.com/christoomey/vim-tmux-runner)
