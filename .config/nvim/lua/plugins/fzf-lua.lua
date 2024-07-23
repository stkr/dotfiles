return
{
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = {
        grep    = {
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
        keymap  = {
            fzf = {
                ["ctrl-d"] = "half-page-down",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-q"] = "select-all+accept",
            },
        },
        winopts = {
            preview = {
                default = false,
            },
        },
    },
}
