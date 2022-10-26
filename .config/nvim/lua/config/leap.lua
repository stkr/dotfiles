local present, leap = pcall(require, "leap")
if not present then
    vim.notify("Failed to require module [leap].")
    return
end


local callbacks = {}

--Add leader shortcuts via whichkey
function callbacks.config()
    leap.setup {
        safe_labels = {},
        labels = {
            'a', 's', 'd', 'g', 'h', 'k', 'l', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'z', 'x', 'c', 'v', 'b',
            'n',
            'm', 'f', 'j',
        },
    }

    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
end

return callbacks
