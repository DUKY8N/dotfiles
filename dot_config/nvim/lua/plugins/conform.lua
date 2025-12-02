return {
    'stevearc/conform.nvim',
    keys = {
        {
            '<leader>lf',
            function()
                require('conform').format()
            end,
            desc = 'Format buffer (Conform)',
            mode = 'n',
        },
    },
    opts = {
        formatters_by_ft = {
			css = { "prettier" },
			less = { "prettier" },
			sh = { 'shfmt' },
            javascript = { 'prettier', timeout_ms = 500 },
            javascriptreact = { 'prettier', timeout_ms = 500 },
            json = { 'prettier', timeout_ms = 500 },
            jsonc = { 'prettier', timeout_ms = 500 },
            lua = { 'stylua' },
            markdown = { 'prettier' },
            python = { 'ruff', 'ruff_format' },
            rust = { 'rustfmt', lsp_format = 'fallback' },
            scss = { 'prettier' },
            typescript = { 'prettier', timeout_ms = 500 },
            typescriptreact = { 'prettier', timeout_ms = 500 },
            yaml = { 'prettier' },
        },
    },
}
