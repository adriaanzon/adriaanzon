if vim.g.vscode then
    return {}
end

local colors = {}

colors.init_color_scheme = function (background)
    vim.opt.termguicolors = true

    colors.set_color_scheme(background)
end

colors.set_color_scheme = function (background)
    if background == "dark" then
        vim.cmd("colorscheme nord")
        vim.opt.background = "dark"
        vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
        vim.cmd("highlight CopilotSuggestion guifg=#414a5c ctermfg=8")
    else
        vim.cmd("colorscheme github")
        vim.opt.background = "light"
        vim.cmd("highlight CopilotSuggestion guifg=#cdd4e5 ctermfg=8")
    end
end

return colors
