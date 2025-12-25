return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
        'neovim/nvim-lspconfig',
        { 'mason-org/mason.nvim', opts = {} },
        { 'mason-org/mason-lspconfig.nvim', opts = {} },
    },
    opts = {
        ensure_installed = {
            'eslint_d',
            'lua-language-server',
            'prettier',
            'ruff',
            'shellcheck',
            'stylua',
            'typescript-language-server',
        },
    },
}
