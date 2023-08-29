local _M = {}

local utils = require("utils")

-- LSP settings
function _M.on_attach(client, bufnr)
    local lsp_status = utils.safe_require("lsp-status")
    if lsp_status ~= nil then
        lsp_status.on_attach(client)
    end
    local lsp_signature = utils.safe_require("lsp_signature")
    if lsp_signature ~= nil then
        lsp_signature.on_attach({}, bufnr)
    end
end

-- This is a copy from cmp_nvim_lsp/init.lua. The rationale here is that in order
-- to use cmp_nvim_lsp one would need to require nvim-cmp in addition. However, we
-- definitely want to lazy-load nvim-cmp as it is the biggest contributor to
-- startuptime. This function is actually required for lsp confiuration and
-- independent from nvim-cmp so it can be easily extracted.
local function if_nil(val, default)
    if val == nil then return default end
    return val
end

local function update_capabilities(capabilities, override)
    override = override or {}
    local completionItem = capabilities.textDocument.completion.completionItem
    completionItem.snippetSupport = if_nil(override.snippetSupport, true)
    completionItem.preselectSupport = if_nil(override.preselectSupport, true)
    completionItem.insertReplaceSupport = if_nil(override.insertReplaceSupport, true)
    completionItem.labelDetailsSupport = if_nil(override.labelDetailsSupport, true)
    completionItem.deprecatedSupport = if_nil(override.deprecatedSupport, true)
    completionItem.commitCharactersSupport = if_nil(override.commitCharactersSupport, true)
    completionItem.tagSupport = if_nil(override.tagSupport, { valueSet = { 1 } })
    completionItem.resolveSupport = if_nil(override.resolveSupport, {
        properties = {
            'documentation',
            'detail',
            'additionalTextEdits',
        }
    })
    return capabilities
end


function _M.get_capabilities()
    -- nvim-cmp supports additional completion capabilities which are added here
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = update_capabilities(capabilities)

    -- lsp-status.nvim supports additional capabilities
    local lsp_status = utils.safe_require("lsp-status")
    if lsp_status ~= nil then
        capabilities = vim.tbl_extend('keep', capabilities or {}, lsp_status.capabilities)
    end

    return capabilities
end

return _M
