local colors = require("adriaan.colors")

local function init_when(background)
    return function()
        if (vim.env.THEME or "dark") == background then
            colors.set_color_scheme(background)
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
