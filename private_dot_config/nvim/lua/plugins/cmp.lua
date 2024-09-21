local kind_icons = {
  Text = '  ',
  Method = '  ',
  Function = '  ',
  Constructor = '  ',
  Field = '  ',
  Variable = '  ',
  Class = '  ',
  Interface = '  ',
  Module = '  ',
  Property = '  ',
  Unit = '  ',
  Value = '  ',
  Enum = '  ',
  Keyword = '  ',
  Snippet = '  ',
  Color = '  ',
  File = '  ',
  Reference = '  ',
  Folder = '  ',
  EnumMember = '  ',
  Constant = '  ',
  Struct = '  ',
  Event = '  ',
  Operator = '  ',
  TypeParameter = '  ',
}

return
{
    "hrsh7th/nvim-cmp",
    revision = "5260e5e8ecadaf13e6b82cf867a909f54e15fd07",
    event = "InsertEnter",
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp", },
        { "hrsh7th/cmp-buffer", },
        { "hrsh7th/cmp-path", },
        { "saadparwaiz1/cmp_luasnip", },
    },
    config = function()
        local present, cmp = pcall(require, "cmp")
        if not present then
            vim.notify("Failed to require module [cmp].")
            return
        end

        local utils_present, utils = pcall(require, "utils")
        if not utils_present then
            vim.notify("Failed to require module [utils].")
            return
        end

        local luasnip_present, luasnip = pcall(require, "luasnip")
        if not luasnip_present then
            vim.notify("Failed to require module [luasnip].")
            return
        end

        -- This avoids jump marks being left over when (parts of) snippets 
        -- are deleted. These manifest itself in that a <cr> in insert mode 
        -- would jumpt to a remaining jump mark instead of inserting a newline.
        -- https://github.com/L3MON4D3/LuaSnip/issues/116
        luasnip.config.set_config({
            region_check_events = "InsertEnter",
            delete_check_events = "TextChanged,InsertLeave",
        })

        cmp.setup({
            completion = {
                completeopt = 'menu,menuone,preview',
                autocomplete = false, -- to enable, remove that line
            },

            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    vim_item.kind = string.format("%s", kind_icons[vim_item.kind], vim_item.kind)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        nvim_lua = "[Lua]",
                        buffer = "[BUF]",
                    })[entry.source.name]
                    return vim_item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),

                ['<CR>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.confirm({
                            behavior = cmp.ConfirmBehavior.Insert,
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
                { name = 'nvim_lsp', priority = 4, },
                { name = 'luasnip',  priority = 3, },
                { name = 'buffer',   priority = 2, },
                { name = 'path',     priority = 1, },
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            performance = {
                max_view_entries = 20,
            },
            -- window = {
            --     completion = cmp.config.window.bordered(),
            --     documentation = cmp.config.window.bordered(),
            -- },
        })
    end,
}
