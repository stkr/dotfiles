local present, zk = pcall(require, "zk")
if not present then
    vim.notify("Failed to require module [zk].")
    return
end

local callbacks = {}

function callbacks.config()
    zk.setup {
        -- can be "telescope", "fzf" or "select" (`vim.ui.select`)
        -- it's recommended to use "telescope" or "fzf"
        picker = "telescope",
    }
end

return callbacks
