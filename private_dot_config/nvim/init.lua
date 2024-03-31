vim.opt.expandtab = true
vim.opt.foldlevelstart = 99
vim.opt.ignorecase = true
vim.opt.joinspaces = false
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { tab = "──╴", trail = "·", extends = "…", precedes = "…" }
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.shortmess:append("I")
vim.opt.showbreak = " ↪"
vim.opt.smartcase = true
vim.opt.spelllang = { "en", "nl" }
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true
vim.opt.wrap = false

vim.keymap.set("n", "c#", "#NcgN")
vim.keymap.set("n", "c*", "*Ncgn")

vim.g.html_no_rendering = true
vim.g.mapleader = " "
vim.g.PHP_noArrowMatching = true

vim.cmd("cabbrev qw wq")

vim.api.nvim_create_autocmd("CmdWinEnter", { command = "startinsert" })

require("adriaan.iterm2")
require("init_lazy")
