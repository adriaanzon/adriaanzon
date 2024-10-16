vim.filetype.add({
    extension = {
        neon = "yaml",
    },
    pattern = {
        [".*php.*%.conf"] = "dosini"
    }
})
