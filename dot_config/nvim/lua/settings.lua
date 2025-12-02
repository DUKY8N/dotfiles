vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = 'yes'
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.laststatus = 3
vim.o.cmdheight = 0

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
})
