return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
        'neovim/nvim-lspconfig',
        { 'mason-org/mason.nvim', opts = {} },
        { 'mason-org/mason-lspconfig.nvim', opts = {} },
    },
    opts = {
        ensure_installed = {
            'lua-language-server',
            'typescript-language-server',
            'ruff',
            'stylua',
            'prettier',
            'eslint_d',
        },
    },
}
