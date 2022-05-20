local present, cmp = pcall(require, "cmp")
if not present then
    vim.notify("Failed to require module [cmp].")
    return
end

local present, luasnip = pcall(require, "luasnip")
if not present then
    vim.notify("Failed to require module [luasnip].")
    return
end

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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

      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<esc>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
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
