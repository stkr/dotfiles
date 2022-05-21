local present, cmp = pcall(require, "cmp")
if not present then
    vim.notify("Failed to require module [cmp].")
    return
end

local luasnip_present, luasnip = pcall(require, "luasnip")
if not luasnip_present then
    vim.notify("Failed to require module [luasnip].")
    return
end

local utils_present, utils = pcall(require, "utils")
if not utils_present then
    vim.notify("Failed to require module [utils].")
    return
end

local callbacks = {}

function callbacks.config()
  -- make luasnip aware of the friendly-snippets
  require("luasnip.loaders.from_vscode").lazy_load()
  cmp.setup {
     completion = {
      completeopt = 'menu,menuone,preview',
      autocomplete = false,  -- to enable, remove that line 
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    formatting = {
      format = function(entry, vim_item)
        -- local icons = require "plugins.configs.lspkind_icons"
        -- vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          nvim_lua = "[Lua]",
          buffer = "[BUF]",
        })[entry.source.name]
        return vim_item
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-j>'] = cmp.mapping.select_next_item(),
      ['<C-k>'] = cmp.mapping.select_prev_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),

      ['<CR>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
            })
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<esc>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif utils.is_text_before_cursor() then
          cmp.complete()
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = {
      { name = 'nvim_lsp', priority = 1, max_item_count = 10 },
      { name = 'luasnip', priority = 1, max_item_count = 10  },
      { name = 'buffer', priority = 2, max_item_count = 10 },
      { name = 'path', priority = 3, max_item_count = 10 },
    },
  }
end

return callbacks
