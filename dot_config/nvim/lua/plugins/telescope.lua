return {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        { '<leader><leader>', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live grep' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
    },
    opts = {
        defaults = {
            mappings = {
                i = {
                    ['<esc>'] = require('telescope.actions').close,
                },
                n = {
                    ['<esc>'] = require('telescope.actions').close,
                },
            },
        },
    },
}
