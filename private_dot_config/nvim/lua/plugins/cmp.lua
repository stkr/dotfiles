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
                    luasnip.lsp_expand(args.body)
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

        -- Expand a snippet, go to normal mode without jumping into the snippet replacements, going back to insert and
        -- pressing tab is causing it to jump to the previous snippet. This can be avoided.
        -- Source: https://github.com/L3MON4D3/LuaSnip/issues/258
        vim.api.nvim_create_autocmd('ModeChanged', {
            pattern = '*',
            callback = function()
                if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
                    and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
                    and not luasnip.session.jump_active
                then
                    luasnip.unlink_current()
                end
            end
        })
    end,
}
