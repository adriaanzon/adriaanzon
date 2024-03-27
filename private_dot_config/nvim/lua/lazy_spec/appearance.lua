local colors = require("adriaan.colors")

-- On startup, set the color scheme based on the $ITERM_THEME universal
-- variable in Fish. This variable is used, so the `defaults` command doesn't
-- have to be run on startup which could hurt performance.
local function init_when(background)
    return function ()
        if vim.env.ITERM_THEME == background then
            colors.init_color_scheme(background)
        end
    end
end

return {
    {
        "arcticicestudio/nord-vim",
        config = init_when("dark"),
        priority = 1000,
    },
    {
        "cormacrelf/vim-colors-github",
        config = init_when("light"),
        priority = 1000,
    },
}
