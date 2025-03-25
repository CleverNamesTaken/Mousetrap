-- mousetrap session commands
vim.api.nvim_create_user_command("StartMousetrap", require("mousetrap").start, {})
vim.api.nvim_create_user_command("StopMousetrap", require("mousetrap").stop, {})
vim.api.nvim_create_user_command("Clear", require("mousetrap").resetPane, {})
vim.api.nvim_create_user_command("MousetrapSafetyToggle", require("mousetrap").safetyToggle, {})
vim.api.nvim_create_user_command("NewWindow", function(args) require("mousetrap").newWindow(args.args) end,
	{ nargs = "?" })
vim.api.nvim_create_user_command("NewPane", function(args) require("mousetrap").newPane(args.args) end, { nargs = "?" })


-- mapleader with the window number to focus on that window.
for i = 0, 9 do
    vim.api.nvim_set_keymap('n', string.format('<leader>%d', i),
        string.format(':lua require("mousetrap").changeWindow(%d)<CR>', i),
        { noremap = true, silent = true })
end

vim.api.nvim_set_keymap('n', '<leader><c-space>', ':lua require("mousetrap").formatWindows()<CR>',
			{ noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader><space>', ':lua require("mousetrap").nextPane()<CR>',
			{ noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-k>', ':lua require("mousetrap").smartPane()<CR>', { noremap = true, silent = true })


-- mousetrap buffer shortcuts
vim.api.nvim_set_keymap('n', '<C-s>', ':lua require("mousetrap").timestamp()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '+', ':lua require("mousetrap").forceUpdate()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '-', ':lua require("mousetrap").fetchOutput()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'H', ':lua require("mousetrap").sendSave()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', ':lua require("mousetrap").sendConsume()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'U', ':lua require("mousetrap").sendFetch()<CR>', { noremap = true, silent = true })


-- mousetrap quality of life functions
vim.api.nvim_set_keymap('n', '<leader>z', ':lua require("mousetrap").focusPane()<CR>',
			{ noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<c-a>', ':lua require("mousetrap").resetPane()<CR>', { noremap = true, silent = true })


-- send CTRL+C to window.  Wish I could do CTRL+C instead of CTRL+X
vim.api.nvim_set_keymap('n', '<leader>c',
			':lua require("mousetrap").sendCtrlC()<CR>',
			{ noremap = true, silent = true })
