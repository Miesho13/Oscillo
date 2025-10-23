local M = {}

function M.setup(opts)
    vim.keymap.set("n", "<leader>c", function()
        M.build()
    end, { desc = "Oscillo build" })
end

function M.build()
    require("oscillo.build").build()
end

function M.set_build()
    require("oscillo.build").set_build()
end

return M
