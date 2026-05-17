vim.keymap.set({ 'n', 'x', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window', remap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window', remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window', remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window', remap = true })

vim.keymap.set('n', '<leader><leader>', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<leader>?', function()
    require('which-key').show { global = false }
end, { desc = 'Buffer local keymaps' })

vim.keymap.set('n', '<leader>lf', function()
    require('conform').format()
end, { desc = 'Format buffer' })

vim.keymap.set({ 'n', 'v' }, '<leader>te', '<cmd>Translate EN<cr>', { desc = 'Translate to English' })
vim.keymap.set({ 'n', 'v' }, '<leader>tk', '<cmd>Translate KO<cr>', { desc = 'Translate to Korean' })

vim.keymap.set('n', '<leader>R', function()
    local session = vim.fn.stdpath('state') .. '/restart_session.vim'
    vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
    vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end, { desc = 'Restart Neovim' })
