local function lsp_progress()
    if #vim.lsp.buf_get_clients() > 0 then
        local buf_messages = require('lsp-status/messaging').messages()
        local seen_clients = {}
        local msgs = {}
        for i = #buf_messages, 1, -1 do
            local msg = buf_messages[i]
            -- We show only the last message per client, everyting else is discarded
            -- Also, only include progress messages, no status messages
            if seen_clients[msg.name] == nil and msg.progress then
                local name = msg.name
                local client_name = '[' .. name .. ']'
                local contents
                if msg.progress then
                    contents = msg.title
                    if msg.message then contents = contents .. ' ' .. msg.message end

                    -- this percentage format string escapes a percent sign once to show a percentage and one more
                    -- time to prevent errors in vim statusline's because of it's treatment of % chars
                    if msg.percentage then contents = contents .. string.format(" (%.0f%%%%)", msg.percentage) end
                end
                table.insert(msgs, client_name .. ' ' .. contents)
                seen_clients[msg.name] = true
            end
        end
        return table.concat(msgs, '|')
        -- return require('lsp-status').status()
    end
    return ''
end

return
{
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            icons_enabled = true,
            theme = 'catppuccin',
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
            lualine_b = {
                "branch",
                {
                    "diff",
                    diff_color = {
                        added = { fg = '#aec800' },
                        removed = { fg = '#ff6f6c' },
                        modified = { fg = '#f3bf21' },
                    },
                },
                {
                    "diagnostics",
                    diagnostics_color = {
                        error = { fg = '#ff6f6c' },
                        warn = { fg = '#f3bf21' },
                        hint = { fg = '#6fc3fe' },
                        info = { fg = '#aec800' },
                    }
                },
            },
            lualine_c = { "filename", lsp_progress },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" }
        },
        tabline = {}
    },
}
