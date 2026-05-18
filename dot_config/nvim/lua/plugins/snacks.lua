return {
    bigfile = { enabled = true },
    indent = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },

    picker = {
        enabled = true,
        win = {
            input = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } },
            list = { keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } } },
        },
    },
}
