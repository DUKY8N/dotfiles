return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            diagnostics = 'nvim_lsp',
            always_show_bufferline = false,
            separator_style = 'slant',
        },
    },
}
