local autosave = {}

local present, utils = pcall(require, "utils")
if not present then
    vim.notify("Failed to require module [utils].")
    return
end

autosave.is_enabled = false

local augroup_name = "Autosave"

function autosave.enable()
    if autosave.is_enabled then
        return
    end

    local autosave_group = vim.api.nvim_create_augroup(augroup_name, { clear = true })
    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", }, { command = "silent! wall", group = autosave_group })
    autosave.is_enabled = true
    utils.info("Autosave is enabled")
end

function autosave.disable()
    if not autosave.is_enabled then
        return
    end
    vim.api.nvim_del_augroup_by_name(augroup_name)
    autosave.is_enabled = false
    utils.info("Autosave is disabled")
end

function autosave.toggle()
    if autosave.is_enabled then
        autosave.disable()
    else
        autosave.enable()
    end
end

return autosave

