local present, cmp = pcall(require, "cmp")

if not present then
   return
end

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
   completion = {
       completeopt = 'menu,menuone,preview',
   },
   snippet = {
      expand = function(args)
         require("luasnip").lsp_expand(args.body)
      end,
   },
   formatting = {
      format = function(entry, vim_item)
         local icons = require "plugins.configs.lspkind_icons"
         vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)

         vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]",
         })[entry.source.name]

         return vim_item
      end,
   },

   mapping = {
       ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
       ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
       ['<CR>'] = cmp.mapping.confirm({
           behavior = cmp.ConfirmBehavior.Insert,
           select = true,
       }),

       ['<Tab>'] = cmp.mapping(
           function(fallback)
               if require("luasnip").expand_or_locally_jumpable() then
                   require("luasnip").expand_or_jump()
               elseif has_words_before() then
                   cmp.complete()
               else
                   fallback()
               end
           end, { "i", "s" }),

       ['<C-d>'] = cmp.mapping.scroll_docs(4),
       ['<C-u>'] = cmp.mapping.scroll_docs(-4),
   },

   sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "nvim_lua" },
      { name = "path" },
   },
}

