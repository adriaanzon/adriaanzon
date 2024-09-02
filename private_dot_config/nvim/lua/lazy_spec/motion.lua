-- Extensions to `:h motion.txt` and `:h change.txt`

local function textobj(name, keys, extra)
    local spec = { name, dependencies = { "kana/vim-textobj-user" }, keys = {} }

    for _, key in ipairs(keys) do
        table.insert(spec.keys, { "i" .. key, mode = { "o", "x" } })
        table.insert(spec.keys, { "a" .. key, mode = { "o", "x" } })
    end

    return vim.tbl_extend("error", spec, extra or {})
end

return {
    textobj("adriaanzon/vim-textobj-matchit", { "m" }, {
        init = function ()
            vim.g.textobj_matchit_filetype_mappings = true
        end,
        ft = { "blade", "lua" }
    }),
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
    textobj("kana/vim-textobj-entire", { "e" }),
    { "kylechui/nvim-surround", config = true, event = "VeryLazy" },
    {
        "tommcdo/vim-exchange",
        init = function ()
            -- With vim-exchange, there's no need for Vim's default behavior of
            -- copying the visual selection when pasting over it. See :help v_p
            vim.keymap.set("v", "p", "P")
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
    textobj("whatyouhide/vim-textobj-xmlattr", { "x" }),
}
