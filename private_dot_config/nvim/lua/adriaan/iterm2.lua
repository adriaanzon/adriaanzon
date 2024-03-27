-- Mappings using the Command modifier key. iTerm2 should be configured to send
-- CSI u escape sequences pressing these key combinations.
-- See: `:h tui-modifyOtherKeys`, https://www.leonerd.org.uk/hacks/fixterms/,
--       https://github.com/neovim/neovim/pull/24357
vim.keymap.set({ "n", "i", "v", "c" }, "<D-s>", "<Cmd>update<CR>")
vim.keymap.set({ "n", "i", "v", "c" }, "<D-w>", "<Cmd>quit<CR>")
vim.keymap.set({ "n", "v" }, "<D-c>", '"+y')

-- When scrolling vertically while holding shift, iTerm2 reports horizontal
-- scrolls with the shift modifier. Vim's S-ScrollWheel* mappings scroll one
-- page which is too much. The following keymaps reset it back to regular
-- horizontal scrolling without shift modifier, and with 3x speed. This does
-- not affect horizontal scrolling with touchpad.
vim.keymap.set({ "n", "i", "v" }, "<S-ScrollWheelLeft>", "<3-ScrollWheelLeft>")
vim.keymap.set({ "n", "i", "v" }, "<S-ScrollWheelRight>", "<3-ScrollWheelRight>")

-- Register an autocommand to automatically adjust the vim colorscheme when the
-- system theme changes. SIGWINCH is sent by an iTerm2 python script.
vim.api.nvim_create_autocmd("Signal", {
    group = vim.api.nvim_create_augroup("AutoAdjustColorScheme", { clear = true }),
    pattern = "SIGWINCH",
    callback = function ()
        local colors = require("adriaan.colors")
        local result = vim.fn.systemlist({ "defaults", "read", "-g", "AppleInterfaceStyle" })[1]

        if result == "Dark" then
            colors.set_color_scheme("dark")
        else
            colors.set_color_scheme("light")
        end
    end,
})
