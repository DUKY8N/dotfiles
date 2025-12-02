vim.keymap.set({ 'n', 'x', 'v' }, '<leader>y', '"+y', { silent = true, desc = 'Yank to system clipboard' })

vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true, desc = 'Move to the left window', remap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true, desc = 'Move to the bottom window', remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true, desc = 'Move to the top window', remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true, desc = 'Move to the right window', remap = true })
