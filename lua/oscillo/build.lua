local M = {}

local signature = "__OSCILLO_BUILD_OUTPUT__"

function M.build()

    local origin_win = vim.api.nvim_get_current_win()
    local origin_buf = vim.api.nvim_get_current_buf()

    vim.cmd("botright split")
    vim.cmd("resize 20")

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, buf)
    -- vim.api.nvim_buf_set_name(buf, signature)
    vim.bo[buf].filetype = "cpp"

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Building..." })
    vim.cmd("redraw") 

    -- local output = vim.fn.system({ "cmake", "--build", "build" })
    local output = vim.fn.system({"./oscill_build"})
    local lines = vim.split(output, "\n", { trimempty = true })

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines);

    vim.api.nvim_set_hl(0, "MyErrorText",   { fg = "#ff5555", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "MyWarningText", { fg = "#ffaa00", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "MyPathText",    { fg = "#7a6146", bg = "NONE", italic = true })
    vim.api.nvim_set_hl(0, "MyNumberText",  { fg = "#0a86d3", bg = "NONE", bold = false })

    local ns = vim.api.nvim_create_namespace("build_highlight")
    for i, line in ipairs(lines) do
        -- error
        local s, e = string.find(line, "error:%s*")
        if s then
            vim.api.nvim_buf_add_highlight(buf, ns, "MyErrorText", i - 1, s - 1, e)
        end

        -- warning
        local ws, we = string.find(line, "warning:%s*")
        if ws then
            vim.api.nvim_buf_add_highlight(buf, ns, "MyWarningText", i - 1, ws - 1, we)
        end
      
        -- path
        for ps, _, pe in line:gmatch("()(/[%w%._%-%+%/]+)()") do
            vim.api.nvim_buf_add_highlight(buf, ns, "MyPathText", i-1, ps-1, pe-1)
        end
        for ps, _, pe in line:gmatch("()(%./[%w%._%-%+%/]+)()") do
            vim.api.nvim_buf_add_highlight(buf, ns, "MyPathText", i-1, ps-1, pe-1)
        end
        for ps, _, pe in line:gmatch("()(%.%./[%w%._%-%+%/]+)()") do
            vim.api.nvim_buf_add_highlight(buf, ns, "MyPathText", i-1, ps-1, pe-1)
        end
    end

    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            local line = vim.api.nvim_get_current_line()
            local filepath, linenum = string.match(line, "([^:%s]+%.%a+):(%d+):%d+")

            if filepath and linenum then
                vim.api.nvim_set_current_win(origin_win)

                vim.cmd("edit " .. filepath)
                vim.cmd(linenum)
            else
                print("No jumpable location on this line")
            end
        end
    })

end

return M
