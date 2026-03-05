if vim.g.vscode then
    return
end

-- Mappings using the Command modifier key. The terminal should send CSI u
-- escape sequences for these key combinations. See: `:h tui-modifyOtherKeys`
vim.keymap.set({ "n", "i", "v", "c" }, "<D-s>", "<Cmd>update<CR>")
vim.keymap.set({ "n", "i", "v", "c" }, "<D-w>", "<Cmd>quit<CR>")
vim.keymap.set({ "n", "v" }, "<D-c>", '"+y')

-- Shift+scroll reports horizontal scrolls with the shift modifier. Vim's
-- S-ScrollWheel* mappings scroll one page which is too much. Reset it back to
-- regular horizontal scrolling without shift modifier, and with 3x speed.
vim.keymap.set({ "n", "i", "v" }, "<S-ScrollWheelLeft>", "<3-ScrollWheelLeft>")
vim.keymap.set({ "n", "i", "v" }, "<S-ScrollWheelRight>", "<3-ScrollWheelRight>")

-- Automatically adjust the colorscheme when the background changes.
local colors_group = vim.api.nvim_create_augroup("AutoAdjustColorScheme", { clear = true })

-- React to mode 2031 theme change notifications (Neovim 0.11+ updates
-- `background` automatically when the terminal reports a change).
vim.api.nvim_create_autocmd("OptionSet", {
    group = colors_group,
    pattern = "background",
    callback = function()
        require("adriaan.colors").set_color_scheme(vim.o.background)
    end,
})
