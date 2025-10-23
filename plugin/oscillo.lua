local command = {
    build = function() require("oscillo").build() end,
}

vim.api.nvim_create_user_command("Osci", function(opts)
    local args = opts.fargs;
    local cmd = args[1];


    local fn =  command[cmd]
    if fn then 
        fn()
    else
        vim.api.nvim_echo({{("[Oscillo] Unknown command: " .. (cmd or "")), "ErrorMsg"}}, false, {})
    end

end, {
    nargs = "+",
    complete = function(_, _, _)
        return vim.tbl_keys(commands)
    end,
})
