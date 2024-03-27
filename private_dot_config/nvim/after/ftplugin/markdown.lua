vim.opt_local.wrap = true

-- Fix underscore displaying as error when used as part of a word.
local function overrideHighlight()
    vim.cmd("highlight link markdownError NONE")
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ResetMarkdownHl", { clear = true }),
    buffer = 0,
    callback = overrideHighlight
})
overrideHighlight()
