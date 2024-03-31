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
    "tpope/vim-endwise",
}
