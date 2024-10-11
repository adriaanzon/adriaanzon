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

            -- Disable default << and >> mappings
            vim.g.bullets_set_mappings = false
            vim.g.bullets_custom_mappings = {
                { 'imap', '<cr>', '<Plug>(bullets-newline)' },
                { 'inoremap', '<C-cr>', '<cr>' },
                { 'nmap', 'o', '<Plug>(bullets-newline)' },
                { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
                { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
                { 'nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)' },
                { 'imap', '<C-t>', '<Plug>(bullets-demote)' },
                { 'imap', '<C-d>', '<Plug>(bullets-promote)' },
            }
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
