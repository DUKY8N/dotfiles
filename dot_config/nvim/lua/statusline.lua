local M = {}

local modes = {
    n = { label = 'NORMAL', highlight = 'Function' },
    i = { label = 'INSERT', highlight = 'String' },
    v = { label = 'VISUAL', highlight = 'Keyword' },
    V = { label = 'V-LINE', highlight = 'Keyword' },
    s = { label = 'SELECT', highlight = 'Keyword' },
    S = { label = 'S-LINE', highlight = 'Keyword' },
    R = { label = 'REPLACE', highlight = 'DiagnosticError' },
    c = { label = 'COMMAND', highlight = 'DiagnosticWarn' },
    t = { label = 'TERMINAL', highlight = 'DiagnosticInfo' },
}

local function get_mode()
    local name = vim.api.nvim_get_mode().mode
    local key = name:sub(1, 1)

    if key == '\22' then
        return 'V-BLOCK', 'v'
    end

    local current = modes[key]
    if not current then
        return modes.n.label, 'n'
    end

    return current.label, key
end

local function set_highlights()
    local statusline = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })

    for key, config in pairs(modes) do
        local highlight = vim.api.nvim_get_hl(0, { name = config.highlight, link = false })
        local accent = highlight.fg or statusline.fg

        vim.api.nvim_set_hl(0, 'StatuslineMode' .. key, {
            fg = statusline.bg,
            bg = accent,
            bold = true,
        })
        vim.api.nvim_set_hl(0, 'StatuslineModeCap' .. key, {
            fg = accent,
            bg = statusline.bg,
        })
    end
end

local function mode_segment(key, content)
    local mode_highlight = '%#StatuslineMode' .. key .. '#'
    local cap_highlight = '%#StatuslineModeCap' .. key .. '#'

    return cap_highlight .. '' .. mode_highlight .. content .. cap_highlight .. ''
end

function M.render()
    local label, key = get_mode()

    return table.concat {
        mode_segment(key, ' ' .. label .. ' '),
        '%#StatusLine# %{v:lua.vim.diagnostic.status()}',
        '%=',
        '%{v:lua.vim.ui.progress_status()} ',
        '%l:%c %P ',
        mode_segment(key, ' %.40t%m%r '),
    }
end

set_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_highlights })
vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
