return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
        options = {
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
        },
        sections = {
            lualine_a = {
                {
                    'mode',
                    separator = { left = '', right = '' },
                },
            },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = {},
            lualine_x = { 'progress', 'location' },
            lualine_y = {},
            lualine_z = {
                {
                    'filename',
                    separator = { left = '', right = '' },
                },
            },
        },
    },
}
