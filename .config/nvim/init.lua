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

-- require important helper functions
local utils = require("utils")

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

    -- other evaluated colorschemes:
    --     2023-06: Iron-E/nvim-highlite: telescope background is nasty, searh and replace is not nice
    --     2023-06: olimorris/onedarkpro.nvim: Diffview is not supported
    --     2023-06: catppuccin/nvim: This is working fine, too "serile" for my taste in the light (latte) variant
    --     2023-06: neanias/everforest-nvim: Very nice theme, the differentiation in statusline between modes is not visible enough
    {
        -- 'Iron-E/nvim-soluarized'
        'stkr/nvim-soluarized',
        lazy = false,
        priority = math.huge, -- make sure to load this before all the other start plugins
        config = function()
            vim.o.termguicolors = true
            vim.o.background = 'light'
            vim.api.nvim_command 'colorscheme soluarized'
        end,
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

    {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },

    {
        "gbprod/stay-in-place.nvim",
        config = function()
            require("stay-in-place").setup()
        end
    },

    { 'tpope/vim-abolish', },
    { 'tpope/vim-obsession', },

    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
        },
        config = function()
            -- Treesitter configuration
            -- Parsers must be installed manually via :TSInstall
            require('nvim-treesitter.configs').setup {
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        local max_filesize = 500 * 1024
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
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
        end
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = {
            {
                'nvim-lua/lsp-status.nvim',
                config = function()
                    local lsp_status = require("lsp-status")
                    lsp_status.config({
                        current_function = false,
                        show_filename = false,
                        diagnostics = false,
                        update_interval = 100,
                        status_symbol = nil,
                    })
                    lsp_status.register_progress()
                end
            },
            { 'ray-x/lsp_signature.nvim', },
        },
    },


    -- autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
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
                    local build_cmd =
                        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && " ..
                        "cmake --build build --config Release && " ..
                        "cmake --install build --prefix build"
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
        },
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
            require("mini.ai").setup({ search_method = "cover" })
            require("mini.bracketed").setup({})
        end
    },

    {
        "chrisgrieser/nvim-various-textobjs",
        config = function()
            require("various-textobjs").setup({ useDefaultKeymaps = true })
        end,
    },

    {
        "chrisgrieser/nvim-spider",
        lazy = true
    },

    {
        'andrewferrier/debugprint.nvim',
        config = function() require("debugprint").setup() end,
    },

    {
        "smjonas/inc-rename.nvim",
        config = function() require("inc_rename").setup() end,
    },

    {
        "renerocksai/telekasten.nvim",
        cmd = { "Telekasten", },
        module = { "telekasten", },
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
        dependencies = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
        cmd = { "NvimTreeOpen", "NvimTreeClose", "NvimTreeToggle", "NvimTreeFocus", "NvimTreeRefresh",
            "NvimTreeFindFile",
            "NvimTreeFindFileToggle", "NvimTreeClipboard", "NvimTreeResize", "NvimTreeCollapse",
            "NvimTreeCollapseKeepBuffers", },
        config = function() require("config.nvim-tree").config() end,
    },

    -- Rust specifics
    -- {
    --     "rust-lang/rust.vim",
    --     ft = "rust",
    --     init = function()
    --     end,
    -- },
    {
        "MunifTanjim/rust-tools.nvim",
        dependencies = "neovim/nvim-lspconfig",
        ft = "rust",
        config = function()
            local lsp_utils = utils.safe_require("lsp_utils")
            if lsp_utils == nil then
                utils.err("Unable to load lsp_utils, lsp support is broken")
                return {}
            end
            local opts = {
                tools = {
                    inlay_hints = {
                        highlight = "InlayHint",
                        max_len_align = true,
                        max_len_align_padding = 4,
                    },
                    hover_actions = {
                        auto_focus = true,
                    },
                },
                server = {
                    on_attach = lsp_utils.on_attach,
                    capabilities = lsp_utils.get_capabilities(),
                },
                -- LLDB (for rust) prints (summary) representations for structs rather
                -- clumsily as the type + the memory location. To get to the struct
                -- fields, one would need to open the struct.
                -- However, LLDB allows changing the representation / format of
                -- variables (see https://lldb.llvm.org/use/variable.html).
                -- This can be (persistently) achieved by including a .lldbinit
                -- file containing statements to change that represenation.
                -- Note that LLDB per default does NOT load the .lldbinit files in
                -- the CWD due to security reasons. LLDB itself would have the
                -- command line switch --local-lldbinit to allow loading local
                -- .lldbinit files. However, since there is lldb-vscode in between
                -- which seems not to be able to supply additional command line
                -- options to LLDB, this approach does not work. However, since it
                -- is LLDB under the hood which finally is running, LLDB
                -- evaluates ~/.lldbinit. So as a workaround, it is possible
                -- to copy the (project specific) LLDB type summaries to ~/.lldbinit.
                -- dap = {
                --     adapter = {
                --         command = "lldb-vscode",
                --         args = { "--local-lldbinit" },
                --     },
                -- },
            }
            local rust_tools = require("rust-tools")
            rust_tools.setup(opts)
            vim.keymap.set('n', '<F8>', rust_tools.runnables.runnables)
            vim.keymap.set('n', '<F20>', rust_tools.debuggables.debuggables) -- <S-F8>
        end,
    },

    {
        "mfussenegger/nvim-dap",
        lazy = true,
        config = function()
            utils.safe_require("dapui")
        end
    },

    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            -- The default output for variables includes
            -- the type name. For rust structs, this is including the canonical name
            -- of the struct (incl. crate name, module names, etc.), leaving no
            -- space in the window to display the actual value.
            -- By using max_type_length = 0, we get rid of the type field
            -- in the variables view entirely (is is of questionable use anyway).
            -- Note that also the dap-virtual-text as well as evaluating a variable
            -- in the repl do not show type information.
            dapui.setup({ render = { max_type_length = 0, }, })

            dap.listeners.after.event_initialized["dapui_config"] = function()
                -- Some filetype specific plugins may have type overlays as virtual text themselves.
                -- Remove those in favor of the virtual text for debugging.
                if vim.bo.filetype == "rust" then
                    local rust_tools = utils.safe_require("rust-tools")
                    if rust_tools then
                        rust_tools.inlay_hints.disable()
                    end
                end
                utils.safe_require("nvim-dap-virtual-text")
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
                local rust_tools = utils.safe_require("rust-tools")
                if rust_tools then
                    rust_tools.inlay_hints.unset()
                end
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },

    {
        "theHamsta/nvim-dap-virtual-text",
        lazy = true,
        config = function()
            require("nvim-dap-virtual-text").setup({ virt_text_win_col = 80 })
        end,
    },
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

-- Improved word navigation
-- **Note** Note that for dot-repeat to work properly, you have to call this
--   plugin’s motions as Ex-command. Calling `function()
--   require("spider").motion("w") end` as third argument of the keymap do _not_
--   support dot-repeatability.
vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" })
vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<CR>", { desc = "Spider-ge" })

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
require("autosave").enable({ silent = true })

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

local lspconfig = utils.safe_require("lspconfig")
local lsp_utils = utils.safe_require("lsp_utils")
if lspconfig ~= nil and lsp_utils ~= nil then
    -- Enable the following language servers
    local servers = { 'clangd', 'tsserver' }
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
            on_attach = lsp_utils.on_attach,
            capabilities = lsp_utils.get_capabilities(),
        }
    end
end


-- The idea is to have the language server installed in the same virtual
-- environment as the proect itself. The venv is activated before nvim
-- is launched from that shell.
-- This allows to access the language servers as well as to run python
-- code from within nvim with the same environment.
if lspconfig ~= nil and lsp_utils ~= nil then
    lspconfig.pylsp.setup {
        on_attach = lsp_utils.on_attach,
        capabilities = lsp_utils.get_capabilities(),
        settings = {
            pylsp = {
                configurationSources = { "black" },
                plugins = {
                    -- default code style linter disabled in favor of black.
                    pycodestyle = {
                        enabled = false,
                    },
                    -- code actions:
                    rope_autoimport = {
                        enabled = true,
                    },
                    -- reformatting:
                    black = {
                        enabled = true,
                        line_length = 100,
                        preview = true,
                    }
                }
            }
        }
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


-- DAP

-- Note on the weird key-bindings for F17 and F29 below:
-- To get the escape sequences that the terminal uses to represent key presses, use
--     showkey -a
-- For this particular situation (alacritty, linux), the keys S-F5 and C-F5 get
-- reported as
--     ^[[15;2~         27 0033 0x1b
--     ^[[15;5~         27 0033 0x1b
-- Now to find out what key nvim does map that terminal sequence to, execute
-- nvim -V3/tmp/log
-- In the resulting log file, the sequences are found as:
--     key_f17                   kf17       = ^[[15;2~
--     key_f29                   kf29       = ^[[15;5~
-- So the <F17> mapping really is <S-F5> and <F29> is <C-F5>
-- It might be different on other terminal emulators / operating systems,
-- more evaluations needed.
-- (see also https://github.com/neovim/neovim/issues/7384)

vim.keymap.set('n', '<F5>', function() require("dap").continue() end)
vim.keymap.set('n', '<F29>', function() require("dap").run_last() end)  -- <C-F5>
vim.keymap.set('n', '<F17>', function() require("dap").terminate() end) -- <S-F5>
vim.keymap.set('n', '<F9>', function() require("dap").toggle_breakpoint() end)
vim.keymap.set('n', '<F10>', function() require("dap").step_over() end)
vim.keymap.set('n', '<F11>', function() require("dap").step_into() end)
vim.keymap.set('n', '<F23>', function() require("dap").step_out() end) --  <S-F11>

-- vim: ts=4 sts=4 sw=4 et
