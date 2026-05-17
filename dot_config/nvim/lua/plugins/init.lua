vim.pack.add({
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
    { src = 'https://github.com/folke/which-key.nvim' },
    { src = 'https://github.com/kylechui/nvim-surround' },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/mason-org/mason.nvim' },
    { src = 'https://github.com/mfussenegger/nvim-lint' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-lualine/lualine.nvim' },
    { src = 'https://github.com/nvim-mini/mini.icons' },
    { src = 'https://github.com/nvim-mini/mini.pairs' },
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/saghen/blink.cmp' },
    { src = 'https://github.com/stevearc/conform.nvim' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/uga-rosa/translate.nvim' },
}, { load = true, confirm = false })

-- Tool Installer
require('mason').setup {}
require('mason-lspconfig').setup {}
require('mason-tool-installer').setup(require 'plugins.mason-tool-installer')

-- Completion
require('blink.cmp').setup {}

-- Formatting
require('conform').setup(require 'plugins.conform')

-- Linting
require('lint').linters_by_ft = {
    javascript = { 'eslint_d' },
    sh = { 'shellcheck' },
    proto = { 'buf_lint' },
}

require('telescope').setup(require 'plugins.telescope')
require('oil').setup {}
require('mini.pairs').setup {}
require('nvim-surround').setup {}
require('which-key').setup(require 'plugins.which-key')
require('lualine').setup(require 'plugins.lualine')
require('translate').setup(require 'plugins.translate')

vim.cmd.colorscheme 'catppuccin-mocha'
