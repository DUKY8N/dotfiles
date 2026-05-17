return {
    keymap = {
        preset = 'super-tab',

        ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
    },
    completion = {
        menu = {
            border = 'rounded',
        },
        documentation = {
            window = {
                border = 'rounded',
            },
        },
    }
}
