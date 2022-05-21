local utils = {}

function utils.get_plugin_config_module(plugin_name)
    -- Deal with plugins that have weird characters in their name (often a '.').
    -- For these we only use the first letters
    local first_part = string.gmatch(plugin_name, "[a-zA-Z0-9%-_]+")()
    local plugin_config_name = "config." .. first_part
    local present, module = pcall(require, plugin_config_name)
    if not present then
        vim.notify("Failed to require plugin config module [" .. plugin_config_name .. "]")
        return
    end
    return module
end

function utils.is_text_before_cursor()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return utils
