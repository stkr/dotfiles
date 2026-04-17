return
{
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        enabled = function()
            return vim.bo.buftype ~= "prompt"
        end,

        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            -- Note, for tab and s-tab the fallback action
            -- includes snippet_forward and snippet_backward
            -- implicitly, so if the completion menu is not open,
            -- tab jumps through snippets.
            preset = 'none',
            ['<C-j>'] = { 'select_next', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
            ['<Tab>'] = {
                function(cmp)
                    local utils = require("utils")


                    if utils.is_text_before_cursor() then
                        return cmp.show()
                    else
                        return false
                    end
                end,
                'select_next', 'fallback' },
            ['<C-k>'] = { 'select_prev', 'fallback' },
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<Esc>'] = { 'cancel', 'fallback' },
            ['<CR>'] = { function(cmp)
                if cmp.snippet_active() then
                    return { cmp.accept(), cmp.snippet_forward() }
                else
                    return cmp.accept()
                end
            end, 'fallback' },
        },

        appearance = {
            -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },

        completion = {
            -- Attention, the keymap for toggling autocompletion depends
            -- on menu.auto_show == true! If you change that here, they will get out of sync!
            documentation = {
                auto_show = false,
            },
            list = {
                selection = { preselect = false, auto_insert = true },
            },
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        cmdline = {
            keymap = {
                preset = 'none',
                ['<C-j>'] = { 'select_next', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<Tab>'] = { 'show', 'select_next', 'fallback' },
                ['<C-k>'] = { 'select_prev', 'fallback' },
                ['<Up>'] = { 'select_prev', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
            },
            completion = {
                menu = { auto_show = false },
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
            },
        },
    },
    opts_extend = { "sources.default" }
}
