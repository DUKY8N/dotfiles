return {
    preset = 'helix',
    win = {},
    spec = {
        { '<leader>c', group = 'Code' },
        { '<leader>f', group = 'Find' },
        { '<leader>l', group = 'LSP' },
        { '<leader>t', group = 'Translate' },

        { 'gr', group = 'LSP' },
        { 'gra', desc = 'Code action' },
        { 'gri', desc = 'Implementation' },
        { 'grn', desc = 'Rename' },
        { 'grr', desc = 'References' },
        { 'grt', desc = 'Type definition' },
        { 'grx', desc = 'Run CodeLens' },
    },
}
