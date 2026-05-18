vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.g.snacks_animate = false

vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.laststatus = 3
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.showtabline = 1
vim.o.signcolumn = 'yes'
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.termguicolors = true
vim.o.winborder = 'rounded'
vim.o.wrap = false

vim.opt.shm:append("I")

vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
}
