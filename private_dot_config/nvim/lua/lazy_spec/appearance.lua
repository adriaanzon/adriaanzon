return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                background = { light = "latte", dark = "macchiato" },
                highlight_overrides = {
                    all = function(colors)
                        return {
                            diffAdded = { link = "DiffAdd" },
                            diffRemoved = { link = "DiffDelete" },
                        }
                    end,
                },
            })

            vim.cmd.colorscheme("catppuccin")
        end,
    },
}
