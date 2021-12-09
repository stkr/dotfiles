set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

source ~/.vim/vimrc

lua << EOF

    local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local luasnip = require("luasnip")

    luasnip.config.set_config({
        region_check_events = "InsertEnter",
        delete_check_events = "TextChanged,InsertLeave",
    })

    -- Setup nvim-cmp.
    local cmp = require'cmp'
    cmp.setup({
        completion = {
            completeopt = 'menu,menuone,preview',
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
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s" }),

            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        },

        snippet = {
            expand = function(args)
                    require'luasnip'.lsp_expand(args.body)
                    end
            },
  
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'luasnip' },
        },
    })

    local actions = require('telescope.actions')
    require('telescope').setup{
        defaults = {
            mappings = {
                i = {
                    ["<C-k>"] = actions.move_selection_previous,
                    ["<C-j>"] = actions.move_selection_next,
                },
            },
        },
        pickers = {
            buffers = {
                sort_lastused = true,
				previewer = false,
            },
            file_browser = {
				previewer = false,
            }
        }
    }

    -- To get fzf loaded and working with telescope, you need to call
    -- load_extension, somewhere after setup function:
    require('telescope').load_extension('fzf')

EOF

