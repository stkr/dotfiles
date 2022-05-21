local present, lualine = pcall(require, "lualine")
if not present then
    vim.notify("Failed to require module [lualine].")
    return
end

local callbacks = {}

function callbacks.config()
    lualine.setup {
        options = {
            icons_enabled = true,
            theme = 'onedark',
            component_separators = '|',
            section_separators = '',
        },

        extensions = {},
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {}
        },
        sections = {
            lualine_a = { "mode", "vim.o.paste and 'PASTE' or ''" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" }
        },
        tabline = {}
    }
end

return callbacks
