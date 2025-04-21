vim.api.nvim_create_user_command("Vault", function()
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line:match("^$ANSIBLE_VAULT") then
        vim.cmd("%!ansible-vault decrypt")
    else
        vim.cmd("%!ansible-vault encrypt")
    end
end, { desc = "Toggle ansible vault encryption" })
