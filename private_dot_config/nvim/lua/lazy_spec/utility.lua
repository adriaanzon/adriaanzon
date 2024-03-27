return {
    { "airblade/vim-helptab", keys = ":" },
    { "arp242/auto_mkdir2.vim", event = "BufWritePre" },
    { "farmergreg/vim-lastplace", event = "BufRead" },
    "justinmk/vim-dirvish",
    {
        "tpope/vim-abolish",
        config = function ()
            vim.cmd("Abolish {,un}nec{ce,ces,e}sar{y,ily} {}nec{es}sar{}")
        end,
        event = "VeryLazy",
    },
    { "tpope/vim-characterize", keys = "ga" },
    "tpope/vim-eunuch",
    {
        "tpope/vim-projectionist",
        init = function ()
            vim.keymap.set("n", "<Space>a", "<Cmd>A<CR>")
        end,
    },
    {
        "tpope/vim-rhubarb",
        dependencies = { "tpope/vim-fugitive" },
        cmd = { "GBrowse" },
    },
    "tpope/vim-sleuth",
    { "tpope/vim-unimpaired", event = "VeryLazy" },
}
