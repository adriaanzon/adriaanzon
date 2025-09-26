-- Extensions to `:h motion.txt` and `:h change.txt`

local function textobj(name, keys, extra)
    local spec = {
        name,
        cond = true, -- allow in vscode
        dependencies = {
            {
                "kana/vim-textobj-user",
                cond = true, -- allow in vscode
            }
        },
        keys = {}
    }

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
        cond = true, -- allow in vscode
        init = function ()
            vim.g.splitjoin_php_method_chain_full = true
        end,
    },
    {
        "christoomey/vim-sort-motion",
        cond = true, -- allow in vscode
        keys = { { "gs", mode = { "n", "x" } } }
    },
    textobj("kana/vim-textobj-entire", { "e" }),
    {
        "kylechui/nvim-surround",
        cond = true, -- allow in vscode
        config = true,
        event = "VeryLazy",
    },
    {
        "tommcdo/vim-exchange",
        cond = true, -- allow in vscode
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
        cond = true, -- allow in vscode
        init = function ()
            vim.g.targets_aiAI = "aIAi"
        end,
    },
    textobj("whatyouhide/vim-textobj-xmlattr", { "x" }),
}
