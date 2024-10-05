if vim.fn.expand("%:t"):find(".env") then
    vim.b.copilot_enabled = false
end
