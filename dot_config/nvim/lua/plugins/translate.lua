return {
    'uga-rosa/translate.nvim',
    cmd = { 'Translate' },
    keys = {
        { '<leader>te', '<cmd>Translate EN<cr>', mode = { 'n', 'v' }, desc = 'Translate to English' },
        { '<leader>tk', '<cmd>Translate KO<cr>', mode = { 'n', 'v' }, desc = 'Translate to Korean' },
    },
    opts = {
        default = {
            command = 'google',
            output = 'floating',
        },
        preset = {
            output = {
                floating = {},
            },
        },
    },
}
