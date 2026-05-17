local telescope_actions = require 'telescope.actions'

return {
    defaults = {
        mappings = {
            i = {
                ['<esc>'] = telescope_actions.close,
                ['<C-j>'] = telescope_actions.move_selection_next,
                ['<C-k>'] = telescope_actions.move_selection_previous,
            },
            n = {
                ['<esc>'] = telescope_actions.close,
                ['<C-j>'] = telescope_actions.move_selection_next,
                ['<C-k>'] = telescope_actions.move_selection_previous,
            },
        },
    },
}
