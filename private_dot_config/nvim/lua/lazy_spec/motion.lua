local function textobj(name, key)
    return {
        name,
        dependencies = { "kana/vim-textobj-user" },
        keys = {
            { "i" .. key, mode = { "o", "x" } },
            { "a" .. key, mode = { "o", "x" } },
        }
    }
end

return {
    textobj("adriaanzon/vim-textobj-matchit", "m"),
    textobj("kana/vim-textobj-entire", "e"),
    {
        "tommcdo/vim-exchange",
        keys = { "cx", { "X", mode = "v" } },
    },
    "tpope/vim-repeat",
    {
        "tpope/vim-surround",
        keys = { "ds", "cs", "ys", "yss", { "S", mode = "x" } },
    },
    {
        "wellle/targets.vim",
        init = function ()
            vim.g.targets_aiAI = "aIAi"
        end,
    },
}
