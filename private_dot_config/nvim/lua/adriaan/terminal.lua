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
