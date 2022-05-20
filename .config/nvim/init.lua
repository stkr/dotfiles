-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })




--#region helper functions
local function plugin_config(plugin_name, config)
    local utils = require("utils")
    local module = utils.get_plugin_config_module(plugin_name)
    module.config()
end

local function plugin_setup(plugin_name, config)
    local utils = require("utils")
    local module = utils.get_plugin_config_module(plugin_name)
    module.setup()
end
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

require('packer').startup(function(use)

    -- Speed up loading Lua modules
    use { 
        'lewis6991/impatient.nvim'
    }

    -- Package manager
    use {
        'wbthomason/packer.nvim',
    }

    -- Utilities, ALWAYS load that, lazyloading this has very weird effects!
    use {
        'nvim-lua/plenary.nvim'
    }

    use { 
        'folke/which-key.nvim',
        keys = { "," },
        config = plugin_config
    }

    use {
        'ggandor/lightspeed.nvim',
    }

  use 'tpope/vim-repeat'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-abolish'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-obsession'
  use 'tpope/vim-surround'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  -- use 'ludovicchabant/vim-gutentags' -- Automatic tags management

      -- UI to select things (files, grep results, open buffers...)
    use { 
        'nvim-telescope/telescope.nvim', 
        requires = { { 'nvim-lua/plenary.nvim', } },
        opt = true,
        cmd = { "Telescope" },
        module = 'telescope',
        config = plugin_config
    }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use 'mjlbach/onedark.nvim' -- Theme inspired by Atom

    -- Fancier statusline
    use {
        'nvim-lualine/lualine.nvim',
        opt = true,
        event = { 'BufEnter' },
        config = plugin_config 
    }

    -- Add indentation guides even on blank lines
    use { 
        'lukas-reineke/indent-blankline.nvim'
    }
    
    -- Add git related info in the signs columns and popups
    use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
    -- Highlight, edit, and navigate code using a fast incremental parsing library
    use {
      'nvim-treesitter/nvim-treesitter'
    }

    -- Additional textobjects for treesitter
    use { 
      'nvim-treesitter/nvim-treesitter-textobjects'
    }

  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'ray-x/lsp_signature.nvim'

    -- Autocompletion plugin
    use {
        "hrsh7th/nvim-cmp",
        module = { "cmp" },

        config = plugin_config,
        wants = { "LuaSnip" },
        requires = {
            {
                "L3MON4D3/LuaSnip",
                module = { "cmp" },
                wants = "friendly-snippets",
            },
            {
                "rafamadriz/friendly-snippets",
                module = { "cmp" },
            },
        },
    }

    use { 
        "hrsh7th/cmp-nvim-lsp", 
        after = "nvim-cmp",
    }
    use { "hrsh7th/cmp-buffer", after = "nvim-cmp" }
    use { "hrsh7th/cmp-path", after = "nvim-cmp" }
    use { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" }

  use {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
  }
  use {
      "vim-scripts/ReplaceWithRegister",
  }
	use {
			"farmergreg/vim-lastplace",
	}
  use {
    "mhinz/vim-sayonara",
    cmd = { "Sayonara" },
  }

end)
--#endregion

--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

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
vim.cmd [[colorscheme onedark]]

--Set clipboard to use system clipboard per default
vim.o.clipboard = "unnamedplus"

-- New splits shall be below or to the right
vim.o.splitbelow = true
vim.o.splitright = true

-- When doing command completion, do only complete as much as possible
-- and provide a list.
vim.o.wildmode = "longest:full,full"
vim.keymap.set('c', '<cr>', function()
  return vim.fn.pumvisible() == 1 and '<c-y>' or '<cr>'
end, {expr = true})
-- Interestingly enough, these won't work - nether their vimscript version
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

--Enable Comment.nvim
require('Comment').setup()

--Remap comma as leader key
vim.keymap.set({ 'n', 'v' }, ',', '<Nop>', { silent = true })
vim.g.mapleader = ','
vim.g.maplocalleader = ','

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Don't copy the replaced text after pasting in visual mode
vim.keymap.set("v", "p", "p:let @+=@0<CR>")

-- Don't yank text on cut ( x )
vim.keymap.set({ "n", "v" }, "x", '"_x')

-- Avoid the escape key http://vim.wikia.com/wiki/Avoid_the_escape_key
vim.keymap.set('i', 'jk', '<esc>')
vim.keymap.set('i', 'kj', '<esc>')

--#region autocommands

-- Reload file after change
    -- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/149214
    -- Triger `autoread` when files changes on disk
    -- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
    -- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
    -- https://vi.stackexchange.com/questions/14315/how-can-i-tell-if-im-in-the-command-window
    -- getcmdwintype() returns a non-empty string if current window is the commandline window.
vim.api.nvim_create_autocmd({"FocusGained","BufEnter","CursorHold","CursorHoldI"}, {
  command = "if mode() != 'c' && getcmdwintype() == '' | checktime | endif" })

-- Notification after file change
  -- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
vim.api.nvim_create_autocmd({"FileChangedShellPost"}, {
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl"})

-- Automatically reload buffers when re-entering vim.
vim.api.nvim_create_autocmd({"BufWinLeave"}, { command = "let b:winview = winsaveview()"})
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  command = "if exists('b:winview') | call winrestview(b:winview) | unlet b:winview"})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
--#endregion

--#region alignment

-- Additional alignment rules (easy align)
vim.cmd [[
    let g:easy_align_delimiters = {
    \ '^': { 'pattern': '\^' },
    \ 'b': { 'pattern': '\\' },
    \ }
]]

--#endregion

--Map blankline
vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- -- Gitsigns
-- require('gitsigns').setup {
--   signs = {
--     add = { text = '+' },
--     change = { text = '~' },
--     delete = { text = '_' },
--     topdelete = { text = '‾' },
--     changedelete = { text = '~' },
--   },
-- }


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
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
  vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})
end

-- nvim-cmp supports additional completion capabilities
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- For pyright, try to adapt for venv
local util = require('lspconfig/util')
local path = util.path

local function get_python_path(workspace)
  -- Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- Find and use virtualenv in workspace directory.
  for _, pattern in ipairs({'*', '.*'}) do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if match ~= '' then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- Fallback to system Python.
  return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
end

lspconfig.pyright.setup({
  before_init = function(_, config)
    config.settings.python.pythonPath = get_python_path(config.root_dir)
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

lspconfig.sumneko_lua.setup {
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
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
