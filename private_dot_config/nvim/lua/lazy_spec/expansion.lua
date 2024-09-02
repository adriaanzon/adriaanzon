-- Extensions to `:h insert.txt`

return {
    {
        "adriaanzon/vim-emmet-ultisnips",
        dependencies = { "SirVer/ultisnips" },
        keys = {
            { "<Tab>", mode = "i", ft = { "html", "vue", "php" } }
        }
    },
    {
        "dkarter/bullets.vim",
        init = function ()
            vim.g.bullets_nested_checkboxes = false
            vim.g.bullets_renumber_on_change = false
        end,
    },
    {
        "github/copilot.vim",
        init = function ()
            vim.keymap.set('i', '<C-y>', 'copilot#Accept("")', {
                expr = true,
                replace_keycodes = false
            })
            vim.g.copilot_no_tab_map = true
        end,
    },
    "tpope/vim-endwise",
}
