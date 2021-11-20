set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

source ~/.vim/vimrc

lua << EOF
    -- Setup nvim-cmp.
    local cmp = require'cmp'
    cmp.setup({
        completion = {
            completeopt = 'menu,menuone,preview',
        },
        mapping = {
            ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ['<Tab>'] = cmp.mapping.confirm({ 
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }),
            ['<CR>'] = cmp.mapping.confirm({ 
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }),

            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        },
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
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
                sort_lastused = true
            }
        }
    }

EOF

