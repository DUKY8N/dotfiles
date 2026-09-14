local M = {}

local modes = {
    n = { label = 'NORMAL', color = 'Function' },
    i = { label = 'INSERT', color = 'String' },
    v = { label = 'VISUAL', color = 'Keyword' },
    V = { label = 'V-LINE', color = 'Keyword' },
    s = { label = 'SELECT', color = 'Keyword' },
    S = { label = 'S-LINE', color = 'Keyword' },
    R = { label = 'REPLACE', color = 'DiagnosticError' },
    c = { label = 'COMMAND', color = 'DiagnosticWarn' },
    t = { label = 'TERMINAL', color = 'DiagnosticInfo' },
}

local function mode()
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

    for key, value in pairs(modes) do
        local color = vim.api.nvim_get_hl(0, { name = value.color, link = false })
        local background = color.fg or statusline.fg

        vim.api.nvim_set_hl(0, 'StatuslineMode' .. key, {
            fg = statusline.bg,
            bg = background,
            bold = true,
        })
        vim.api.nvim_set_hl(0, 'StatuslineModeCap' .. key, {
            fg = background,
            bg = statusline.bg,
        })
    end

    local accent = vim.api.nvim_get_hl(0, { name = 'Function', link = false }).fg or statusline.fg
    vim.api.nvim_set_hl(0, 'StatuslineFile', {
        fg = statusline.bg,
        bg = accent,
        bold = true,
    })
    vim.api.nvim_set_hl(0, 'StatuslineFileCap', {
        fg = accent,
        bg = statusline.bg,
    })
end

function M.render()
    local label, key = mode()

    return table.concat {
        '%#StatuslineModeCap' .. key .. '#',
        '%#StatuslineMode' .. key .. '# ' .. label .. ' ',
        '%#StatuslineModeCap' .. key .. '#',
        '%#StatusLine# %{v:lua.vim.diagnostic.status()}',
        '%=',
        '%{v:lua.vim.ui.progress_status()} ',
        '%l:%c %P ',
        '%#StatuslineFileCap#',
        '%#StatuslineFile# %.40t%m%r ',
        '%#StatuslineFileCap#',
    }
end

set_highlights()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_highlights })
vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
