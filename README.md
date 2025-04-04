# Description

Mousetrap is a neovim plugin that uses tmux and scripted windows to allow users to execute complex terminal operations by keeping your hands on the keyboard and off of the mouse.  The major goal is to reduce cognitive load by working in a nvim instance and actively documenting your actions as you operate.

Mousetrap is similar to vim-slime, but more tmux specific with better terminal navigation and logging features.  Credit to Erik Falor's talk [Vim Muggle to Wizard in 10 Easy Steps](youtube.com/watch?v=-7RSVclyOEg) for unlocking the Wizardry of vim.

# Why use Mousetrap?

When conducting red team assessments, I wanted to improve my efficiency and logging.  I found that I could address both of these goals by primarilly operating within vim.  By synergizing tmux, [ultisnips](https://github.com/SirVer/ultisnips) and vim, I could:

1) Stay focused on the objective at hand by remaining in vim and sending my commands to tmux windows.
2) Stay consistent by using red team playbooks developed and stored as Ultisnips snippets.
3) Log my activities by parsing the output of my tmux and scripted windows, and saving them off as yaml files.
4) Quickly reconstruct my activities by logging all commands sent through vim in a csv.

# Installation

However you choose to install, tmux and neovim are dependencies.

```
apt install tmux neovim -y
```

* with [lazy.nvim](https://github.com/folke/lazy.nvim)

```
return {
  'CleverNamesTaken/Mousetrap',
}
```

* Bootstrap install

```
mkdir -p ~/.config/nvim
sudo apt install tmux neovim -y
git clone https://github.com/CleverNamesTaken/Mousetrap 
cp -r Mousetrap/lua ~/.config/nvim
cp -r Mousetrap/plugin ~/.config/nvim
cp -r Mousetrap/doc  ~/.config/nvim
echo 'require("mousetrap")' >> ~/.config/nvim/init.lua
```

# Tutorial

See TUTORIAL.md

# Customize your settings

The default settings are quite reasonable, but the things that you might be interested in changing are as follows:

## Log settings

Mousetrap has three settings in `mousetrap/config.lua`:
- workDir : Where scripted window files will be created. Default setting is `~/work/mousetrap`.
- logDir : This is where `lastCommand.txt` and directories for each terminal will be created.  Default setting is `~/work/mousetrap/logs/`.
- logTime : This is how many minutes that Mousetrap will allow you wait before giving up on trying to re-update your command output yaml files or `lastCommand.txt`.  By default, this is 5 minutes.

## Keybindings

Keybindings can be modified in `plugins/mousetrap.lua`.  There are a lot here, and default Mousetrap keybindings stomp on `<c-a>` to clear a terminal.  The other non-leader keybinds it uses are as follows (all in normal mode):

- `<c-k>`
- `<C-s>`
- `+`
- `-`
- `H`
- `K`
- `U`

# TODO

Known bugs:

- If you try to pull back too much data at once, it might freeze up your nvim.  Put in a check to tell you that you are trying to pull back too much and that it is safer to just blind update and view `lastCommand.txt`.
- If you drop into a docker container (and presumably other types of shells out there), your pane title might change.  This will break Mousetrap's ability to send commands, so implement some sort of way to revert the pane title back.
- Depending on your your shell's `$PS1`, you might need to comment out line 48 of `lua/mousetrap/logging.lua`.  The issue here is because some shells give you more newlines than others after you execute a command.
- Sending a line starting with `-- ` confuses Mousetrap.

# Similar projects

- [vim slime](https://github.com/jpalardy/vim-slime)
- [vim-tmux-runner](https://github.com/christoomey/vim-tmux-runner)
- [nvim-terminal-send](https://github.com/max607/nvim-terminal-send)
