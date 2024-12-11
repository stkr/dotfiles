return
{
    "ibhagwan/fzf-lua",
    commit = "b7e4d478d0ba4cb8495a7b249fe53cf4613072cf",
    dependencies = { "echasnovski/mini.nvim" },
    cmd = "FzfLua",
    opts = {
        defaults   = {
            file_icons = true,
            git_icons = false, -- This is VERY slow on large repos in windows. Disabled for now.
        },
        grep       = {
            rg_glob = true,
            -- first returned string is the new search query
            -- second returned string are (optional) additional rg flags
            -- @return string, string?
            rg_glob_fn = function(query, _)
                local regex, flags = query:match("^(.-)%s%-%-(.*)$")
                -- If no separator is detected will return the original query
                return (regex or query), flags
            end

        },
        keymap     = {
            fzf = {
                ["ctrl-d"] = "half-page-down",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-q"] = "select-all+accept",
            },
        },
        winopts    = {
            preview = {
                default = false,
            },
        },
        fzf_colors = {
            ["fg"]      = { "fg", "CursorLine" },
            ["bg"]      = { "bg", "Normal" },
            ["hl"]      = { "fg", "Comment" },
            ["fg+"]     = { "fg", "Normal" },
            ["bg+"]     = { "bg", "CursorLine" },
            ["hl+"]     = { "fg", "Statement" },
            ["info"]    = { "fg", "PreProc" },
            ["prompt"]  = { "fg", "Conditional" },
            ["pointer"] = { "fg", "Exception" },
            ["marker"]  = { "fg", "Keyword" },
            ["spinner"] = { "fg", "Label" },
            ["header"]  = { "fg", "Comment" },
            ["gutter"]  = "-1",
        },
    },
}
