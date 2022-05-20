
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


return utils

