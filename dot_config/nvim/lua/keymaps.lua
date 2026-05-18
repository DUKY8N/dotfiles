-- Clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set('n', '<leader>Y', function()
    vim.fn.setreg('+', vim.fn.expand '%:t')
end, { desc = 'Yank file name to system clipboard' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window', remap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window', remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window', remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window', remap = true })

-- File explorer
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

-- Snacks Picker
vim.keymap.set('n', '<leader><leader>', function()
  Snacks.picker.files()
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>fb', function()
  Snacks.picker.buffers()
end, { desc = 'Find buffers' })

vim.keymap.set('n', '<leader>fc', function()
  Snacks.picker.commands()
end, { desc = 'Commands' })

vim.keymap.set('n', '<leader>ff', function()
  Snacks.picker.files()
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>fg', function()
  Snacks.picker.grep()
end, { desc = 'Live grep' })

vim.keymap.set('n', '<leader>fh', function()
  Snacks.picker.help()
end, { desc = 'Help tags' })

vim.keymap.set('n', '<leader>fk', function()
  Snacks.picker.keymaps()
end, { desc = 'Keymaps' })

vim.keymap.set('n', '<leader>fm', function()
  Snacks.picker.man()
end, { desc = 'Man pages' })

vim.keymap.set('n', '<leader>fr', function()
  Snacks.picker.registers()
end, { desc = 'Registers' })

-- Code
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostic' })
vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })

vim.keymap.set({ 'n', 'x' }, '<leader>cf', function()
    require('conform').format()
end, { desc = 'Format' })

vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1 }
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1 }
end, { desc = 'Next diagnostic' })

-- Translation
vim.keymap.set({ 'n', 'x' }, '<leader>te', '<cmd>Translate EN<cr>', { desc = 'Translate to English' })
vim.keymap.set({ 'n', 'x' }, '<leader>tk', '<cmd>Translate KO<cr>', { desc = 'Translate to Korean' })

-- Neovim restart
vim.keymap.set('n', '<leader>R', function()
    local session = vim.fn.stdpath 'state' .. '/restart_session.vim'

    vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
    vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end, {
    desc = 'Restart Neovim',
})
