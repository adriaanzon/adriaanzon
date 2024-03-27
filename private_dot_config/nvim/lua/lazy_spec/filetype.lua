return {
    {
        "alker0/chezmoi.vim",
        init = function ()
            vim.g["chezmoi#use_tmp_buffer"] = true
        end,
    },
    { "ii14/neorepl.nvim", cmd = "Repl" },
    { "rhysd/vim-gfm-syntax", ft = "markdown" },
    "tpope/vim-scriptease",
}
