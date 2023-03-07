-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

--#region helper functions
--#endregion


--#region plugins

-- disable builtins plugins
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

require("lazy").setup({
    { "nvim-lua/plenary.nvim", },

    {
        'rcarriga/nvim-notify',
        config = function()
            local notify = require("notify")
            notify.setup({
                stages = "static",
                timeout = 2000,
            })
            vim.notify = notify
        end
    },

    {
        'dstein64/nvim-scrollview',
        opts = {
            excluded_filetypes = {},
            current_only = true,
            winblend = 0,
            base = 'right',
            column = 1,
        }
    },
    {
        -- 'Iron-E/nvim-soluarized'
        'stkr/nvim-soluarized'
    },
    {
        'nvim-lualine/lualine.nvim',
        config = function() require("config.lualine").config() end,
    },

    -- Add indentation guides even on blank lines
    { 'lukas-reineke/indent-blankline.nvim', },

    -- Add git related info in the signs columns and popups
    { "airblade/vim-gitgutter", },

    {
        'folke/which-key.nvim',
        config = function() require("config.which-key").config() end,
    },
    {
        "svart",
        url = 'https://gitlab.com/madyanov/svart.nvim',
        config = function()
            require("svart").configure({
                label_atoms = "asdghklqwertyuiopzxcvbnmfj",
                search_update_register = false,
            })
        end,
        cmd = { "Svart" },
    },

    {
        "ethanholz/nvim-lastplace",
        opts = {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
            lastplace_open_folds = true
        }
    },

    {
        "gbprod/cutlass.nvim",
        config = function()
            require("cutlass").setup({
                exclude = { "ns", "nS" },
                cut_key = "x",
            })
        end,
    },

    { "vim-scripts/ReplaceWithRegister", },

    { "gbprod/stay-in-place.nvim", },

    { 'tpope/vim-abolish', },
    { 'tpope/vim-obsession', },

    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
        },
    },


    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'nvim-lua/lsp-status.nvim', },
            { 'ray-x/lsp_signature.nvim', },
        },
    },


    -- autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {

            {
                "L3MON4D3/LuaSnip",
                dependencies = { { "rafamadriz/friendly-snippets", }, },
            },

            { "saadparwaiz1/cmp_luasnip", },
            { "hrsh7th/cmp-nvim-lsp", },
            { "hrsh7th/cmp-buffer", },
            { "hrsh7th/cmp-path", },
        },
        config = function() require("config.nvim-cmp").config() end,
    },

    {
        'nvim-telescope/telescope.nvim',
        cmd = { "Telescope" },
        module = 'telescope',
        config = function() require("config.telescope").config() end,
        dependencies = {
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = function()
                    local build_cmd = "make"
                    if not vim.loop.os_uname().sysname:match 'Linux' then
                        -- for windows, a simple make is not enough...
                        build_cmd =
                            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && " ..
                            "cmake --build build --config Release && " ..
                            "cmake --install build --prefix build"
                    end
                    os.execute(build_cmd)
                end,
            },
            {
                "nvim-telescope/telescope-frecency.nvim",
                dependencies = { { "kkharji/sqlite.lua" }, }
            },
            {
                'nvim-telescope/telescope-ui-select.nvim',
            },

        }
    },

    {
        'echasnovski/mini.nvim',
        config = function()
            require("mini.surround").setup({
                mappings = {
                    add = 'Sa',            -- Add surrounding in Normal and Visual modes
                    delete = 'Sd',         -- Delete surrounding
                    find = 'Sf',           -- Find surrounding (to the right)
                    find_left = 'SF',      -- Find surrounding (to the left)
                    highlight = 'Sh',      -- Highlight surrounding
                    replace = 'Sr',        -- Replace surrounding
                    update_n_lines = 'Sn', -- Update `n_lines`
                    suffix_last = 'l',     -- Suffix to search with "prev" method
                    suffix_next = 'n',     -- Suffix to search with "next" method
                },
            })
            require("mini.cursorword").setup({})
            require("mini.align").setup({})
            require("mini.pairs").setup({})
        end
    },

    { 'andrewferrier/debugprint.nvim', },

    { "smjonas/inc-rename.nvim", },

    { "numToStr/Comment.nvim", },

    {
        "renerocksai/telekasten.nvim",
        config = function() require("config.telekasten").config() end,
    },

    {
        'sindrets/diffview.nvim',
        dependencies = { "nvim-lua/plenary.nvim", },
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose",
            "DiffviewToggleFiles", "DiffviewFocusFiles",
            "DiffviewRefresh", "DiffviewLog",
        },
        config = function() require("config.diffview").config() end,
    },

    {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        cmd = { "NvimTreeOpen", "NvimTreeClose", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeRefresh",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle", "NvimTreeClipboard", "NvimTreeResize", "NvimTreeCollapse",
            "NvimTreeCollapseKeepBuffers", },
        config = function() require("config.nvim-tree").config() end,
    }
})

--
-- end)

--#endregion


--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

-- Enable cursorline
vim.o.cursorline = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

-- Use 4 spaces for indentation
-- show existing tab with 4 spaces width
vim.o.tabstop = 4
-- when indenting with '>', use 4 spaces width
vim.o.shiftwidth = 4
-- On pressing tab, insert 4 spaces
vim.o.expandtab = true

-- Reasonable listchars
vim.o.listchars = "eol:¬,tab:>>,trail:~,extends:>,precedes:<,space:·"

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250
vim.o.signcolumn = 'yes'

--Set colorscheme
vim.o.termguicolors = true
vim.o.background = 'light'
vim.cmd [[ colorscheme soluarized ]]


--Set clipboard to use system clipboard per default
vim.o.clipboard = "unnamedplus"

-- If run from within tmux, nvim per default on yank does copy also to a tmux
-- buffer. This a kind of shared clipboard between tmux panes. In addition,
-- tmux has the feature that it can copy this buffer to the client. This would
-- be using an OSC52 sequence, therefore requiring a terminal that supports
-- that.
--
-- To yank to tmux, nvim uses the "tmux load-buffer" command (see man tmux). In
-- order for that additional copy step to the client to happen, the -w argument
-- to load-buffer is required. Now per design nvim does not enable that
-- (https://github.com/neovim/neovim/issues/14545). Therefore, we need to
-- override the clipboard command ourselves and add that -w option with the
-- following configuration.
--
-- Note, there would also be an alternative to this approach - an alias for
-- "load-buffer" to "load-buffer -w" from within tmux
-- (https://github.com/tmux/tmux/issues/3088). This was tried and working as
-- well, however, it seems to be quite invasive and therefore this approach was
-- taken.

if os.getenv("TMUX") then
    vim.api.nvim_exec([[
let g:clipboard = {
          \   'name': 'myClipboard',
          \   'copy': {
          \      '+': ['tmux', 'load-buffer', '-w', '-'],
          \      '*': ['tmux', 'load-buffer', '-w', '-'],
          \    },
          \   'paste': {
          \      '+': ['tmux', 'save-buffer', '-'],
          \      '*': ['tmux', 'save-buffer', '-'],
          \   },
          \   'cache_enabled': 1,
          \ }
    ]], false)
end

-- New splits shall be below or to the right
vim.o.splitbelow = true
vim.o.splitright = true

-- Add a keybinding to zoom in on the current split. This copies the split and creates a new
-- tab from it, so a simple close of the window is good enough to get back to the prev split
-- layout.
vim.keymap.set('n', '<C-W>z', ":tabnew %<CR>")

-- The s, and S keys are bound to svart and surround. Disable the inbuilt ones.
vim.keymap.set('n', 'S', "<nop>")

-- When doing command completion, do only complete as much as possible
-- and provide a list.
vim.o.wildmode = "longest:full,full"
vim.keymap.set('c', '<cr>', function()
    return vim.fn.pumvisible() == 1 and '<c-y>' or '<cr>'
end, { expr = true })
-- Interestingly enough, these won't work - neither their vimscript version
-- nor the lua version. So we stick with TAB for now...
-- vim.api.nvim_command([[ cnoremap <expr> <c-j> wildmenumode() ? "\<down>" : "\<c-j>" ]])
-- vim.api.nvim_command([[ cnoremap <expr> <c-k> wildmenumode() ? "\<up>" : "\<c-k>" ]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Ignore eol in visual block mode and allow having the cursor
-- one char after the end of the line
vim.o.virtualedit = "block,onemore"

-- Detect when a file is changed
vim.o.autoread = true

-- Use treesitter for folding
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

-- Make marks always go to the marked column
vim.keymap.set('n', "'", "`")

-- Write a file as root
vim.api.nvim_create_user_command("SudoWrite", function(opts) require('utils').sudo_write() end, {})
-- vim.keymap.set('c', 'w!!<CR>', require('utils').sudo_write)

--Remap comma as leader key
vim.keymap.set({ 'n', 'v' }, ',', '<Nop>', { silent = true })
vim.g.mapleader = ','
vim.g.maplocalleader = ','

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('v', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('v', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--- Don't copy the replaced text after pasting in visual mode
vim.keymap.set("v", "p", "p:let @+=@0<CR>")

-- Make gp select the recently pasted text
vim.keymap.set("n", "gp", "'[V']")

-- Avoid the escape key http://vim.wikia.com/wiki/Avoid_the_escape_key
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('i', 'kj', '<esc>')

-- Search for word under cursor without jumping around.
vim.keymap.set('n', '*', ':set hlsearch <bar> :let @/=expand(\'<cword>\')<CR>')

-- Quick jump
vim.keymap.set({ "n", "x", "o" }, "s", "<cmd>Svart<cr>")

--#region autocommands

-- Reload file after change
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/149214
-- Trigger `autoread` when files changes on disk
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
-- https://vi.stackexchange.com/questions/14315/how-can-i-tell-if-im-in-the-command-window
-- getcmdwintype() returns a non-empty string if current window is the commandline window.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    command = "if mode() != 'c' && getcmdwintype() == '' | checktime | endif"
})

-- Save file when focus is lost
require("autosave").enable()

-- Notification after file change
-- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
    callback = function()
        require('utils').warn('File changed on disk. Buffer reloaded.')
    end
})

-- Automatically reload buffers when re-entering vim.
vim.api.nvim_create_autocmd({ "BufWinLeave" }, { command = "let b:winview = winsaveview()" })
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    command = "if exists('b:winview') | call winrestview(b:winview) | unlet b:winview"
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Do not prefix newlines with the comment char if they are inserted
-- with O. The typical usecase for when we want that prefix is if we are editing
-- a comment and creating a newline with <cr>.
-- Normally one would just change the setting here. However A LOT of ftplugins
-- override the option. The suggested way to deal with it is to define yet another
-- autocommand that overrides the ftplugin's override :-(
-- https://codeahoy.com/q/287/vim-faq
-- https://stackoverflow.com/questions/23691236/vim-removing-r-from-format-options-for-all-filetypes
vim.api.nvim_create_autocmd({ "Filetype" }, { command = "set formatoptions-=o" })

--#endregion

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- Gitgutter settings
vim.g.gitgutter_map_keys = 0
vim.g.gitgutter_close_preview_on_escape = 1

-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers)
-- vim.keymap.set('n', '<leader>sf', function()
--   require('telescope.builtin').find_files { previewer = false }
-- end)
-- vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
-- vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
-- vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
-- vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
-- vim.keymap.set('n', '<leader>so', function()
--   require('telescope.builtin').tags { only_current_buffer = true }
-- end)
-- vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
    highlight = {
        enable = true, -- false will disable the whole extension
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = nil,
            node_incremental = nil,
            scope_incremental = 'ga',
            node_decremental = nil,
        },
    },
    indent = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
            },
            goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
            },
            goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
            },
            goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
            },
        },
    },
}


-- LSP settings
local lspconfig = require 'lspconfig'
local on_attach = function(client, bufnr)
    -- local opts = { buffer = bufnr }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<leader>wl', function()
    --     vim.inspect(vim.lsp.buf.list_workspace_folders())
    -- end, opts)
    -- vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    -- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
    -- vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})

    local lsp_status = require('lsp-status')
    lsp_status.on_attach(client, bufnr)
end

-- This is a copy from cmp_nvim_lsp/init.lua. The rationale here is that in order
-- to use cmp_nvim_lsp one would need to require nvim-cmp in addition. However, we
-- definitely want to lazy-load nvim-cmp as it is the biggest contributor to
-- startuptime. This function is actually required for lsp confiuration and
-- independent from nvim-cmp so it can be easily extracted.
local if_nil = function(val, default)
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

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = update_capabilities(capabilities)

-- lsp-status.nvim supports additional capabilities
local lsp_status = require('lsp-status')
lsp_status.config({
    current_function = false,
    show_filename = false,
    diagnostics = false,
    update_interval = 100,
    status_symbol = nil,
})
lsp_status.register_progress()
capabilities = vim.tbl_extend('keep', capabilities or {}, lsp_status.capabilities)


-- For pyright, try to adapt for venv
lspconfig.pyright.setup({
    before_init = function(_, config)
        config.settings.python.pythonPath = utils.get_python_path(config.root_dir)
    end,
    on_attach = on_attach,
    capabilities = capabilities,
})

-- Enable the following language servers
local servers = { 'clangd', 'rust_analyzer', 'tsserver' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end




-- Example custom server
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.lua_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}




-- vim: ts=4 sts=4 sw=4 et
