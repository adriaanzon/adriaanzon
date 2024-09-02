require("nvim-surround").buffer_setup({
    surrounds = {
        m = {
            add = function ()
                local config = require("nvim-surround.config")
                local result = config.get_input("Blade directive: @")
                if result then
                    result_without_expression = result:match("^%w+")
                    return {
                        { "@" .. result .. " " },
                        { " @end" .. result_without_expression }
                    }
                end
            end,

            find = function()
                return require("nvim-surround.config").get_selection({ motion = "am" })
            end,
        },
    },
    aliases = {
        d = "m",
    },
})
