-- Extensions to `:h filetype.txt`

return {
    {
        "alexandersix/vim-blade",
        cond = true, -- allow in vscode
    },
    {
        "alker0/chezmoi.vim",
        init = function ()
            vim.g["chezmoi#use_tmp_buffer"] = true
        end,
    },
    { "ii14/neorepl.nvim", cmd = "Repl" },
    {
        "neovim/nvim-lspconfig",
        config = function()
            vim.lsp.enable({
                "bashls",
            })

            -- Open diagnostics in a floating window when jumping to the next/previous diagnostic (with `]d` and `[d`).
            vim.diagnostic.config({ jump = { float = true } })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash",
                "blade",
                "html",
                "javascript",
                "markdown",
                "php",
                "php_only",
                "typescript",
                "vue",
            })
        end,
    },
    "tpope/vim-scriptease",
}
