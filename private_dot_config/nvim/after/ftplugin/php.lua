vim.treesitter.start()

-- Fold using treesitter for PHP files
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Automatically fold imports
vim.schedule(function()
    local original_cursor_position = vim.api.nvim_win_get_cursor(0)
    local first_use_line_number = vim.fn.search("^use\\s", "n")

    if first_use_line_number > 0 then
        vim.api.nvim_win_set_cursor(0, {first_use_line_number, 0})
        vim.cmd("silent! normal! zc")
    end

    vim.api.nvim_win_set_cursor(0, original_cursor_position)
end)
