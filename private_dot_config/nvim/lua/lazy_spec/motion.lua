-- Extensions to `:h motion.txt` and `:h change.txt`

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
    {
        "AndrewRadev/splitjoin.vim",
        init = function ()
            vim.g.splitjoin_php_method_chain_full = true
        end,
    },
    {
        "christoomey/vim-sort-motion",
        keys = { { "gs", mode = { "n", "x" } } }
    },
    { "justinmk/vim-sneak", keys = { "s", "S" } },
    textobj("kana/vim-textobj-entire", "e"),
    { "kylechui/nvim-surround", config = true, event = "VeryLazy" },
    {
        "tommcdo/vim-exchange",
        init = function ()
            -- With vim-exchange, there's no need for Vim's default behavior of
            -- copying the visual selection when pasting over it.
            vim.keymap.set("v", "p", '<Cmd>normal! "_dP<CR>')
        end,
        keys = { "cx", { "X", mode = "v" } },
    },
    "tpope/vim-repeat",
    {
        "wellle/targets.vim",
        init = function ()
            vim.g.targets_aiAI = "aIAi"
        end,
    },
    textobj("whatyouhide/vim-textobj-xmlattr", "x"),
}
