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

-- Buffers opened by shell/Claude "edit command line in $EDITOR" features.
-- Map the same keybindings that toggle the editor to write+quit, so they
-- round-trip back to the original prompt.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = {
		"/private/tmp/claude-prompt-*.md",
		"/private/var/folders/*/T/fish.*/command-line.fish",
	},
	callback = function(args)
		vim.keymap.set({ "n", "i", "x" }, "<C-g>", "<Cmd>wq<CR>", { buffer = args.buf, nowait = true })
		vim.keymap.set({ "n", "i", "x" }, "<M-v>", "<Cmd>wq<CR>", { buffer = args.buf, nowait = true })
	end,
})
