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
    else
        vim.cmd("colorscheme github")
        vim.opt.background = "light"
    end
end

return colors
