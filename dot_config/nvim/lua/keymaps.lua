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
for _, binding in ipairs {
    { key = '<leader><leader>', picker = 'files', desc = 'Find files' },
    { key = '<leader>fb', picker = 'buffers', desc = 'Find buffers' },
    { key = '<leader>fc', picker = 'commands', desc = 'Commands' },
    { key = '<leader>ff', picker = 'files', desc = 'Find files' },
    { key = '<leader>fg', picker = 'grep', desc = 'Live grep' },
    { key = '<leader>fh', picker = 'help', desc = 'Help tags' },
    { key = '<leader>fk', picker = 'keymaps', desc = 'Keymaps' },
    { key = '<leader>fm', picker = 'man', desc = 'Man pages' },
    { key = '<leader>fr', picker = 'registers', desc = 'Registers' },
} do
    vim.keymap.set('n', binding.key, function()
        Snacks.picker[binding.picker]()
    end, { desc = binding.desc })
end

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

-- Git
vim.keymap.set({ 'n', 'v' }, '<leader>gB', function()
    Snacks.gitbrowse()
end, { desc = 'Open GitHub in Browser' })

vim.keymap.set('n', '<leader>gg', function()
    Snacks.lazygit.open()
end, { desc = 'Lazygit 열기' })

-- Translation
vim.keymap.set({ 'n', 'x' }, '<leader>te', '<cmd>Translate EN<cr>', { desc = 'Translate to English' })
vim.keymap.set({ 'n', 'x' }, '<leader>tk', '<cmd>Translate KO<cr>', { desc = 'Translate to Korean' })

-- Pi
vim.keymap.set('n', '<leader>ai', '<cmd>PiAsk<cr>', { desc = 'Ask pi' })
vim.keymap.set('v', '<leader>ai', '<cmd>PiAskSelection<cr>', { desc = 'Ask pi (selection)' })

-- Neovim restart
vim.keymap.set('n', '<leader>R', function()
    local session = vim.fn.stdpath 'state' .. '/restart_session.vim'

    vim.cmd('mksession! ' .. vim.fn.fnameescape(session))
    vim.cmd('restart source ' .. vim.fn.fnameescape(session))
end, {
    desc = 'Restart Neovim',
})
