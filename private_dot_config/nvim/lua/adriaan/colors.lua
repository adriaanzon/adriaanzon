if vim.g.vscode then
    return {}
end

local colors = {}

colors.set_color_scheme = function (background)
    vim.cmd("noautocmd set background=" .. background)
    if background == "dark" then
        vim.cmd("colorscheme nord")
        vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
        vim.cmd("highlight CopilotSuggestion guifg=#414a5c ctermfg=8")
    else
        vim.cmd("colorscheme github")
        vim.cmd("highlight CopilotSuggestion guifg=#cdd4e5 ctermfg=8")
    end
end

return colors
