return
{
    "ibhagwan/fzf-lua",
    version = "5565f4bfe304df30c35962a982f14d8de1043336",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    opts = {
        defaults = {
            file_icons = true,
            git_icons = false, -- This is VERY slow on large repos in windows. Disabled for now.
        },
        grep     = {
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
        keymap   = {
            fzf = {
                ["ctrl-d"] = "half-page-down",
                ["ctrl-u"] = "half-page-up",
                ["ctrl-q"] = "select-all+accept",
            },
        },
        winopts  = {
            preview = {
                default = false,
            },
        },
    },
}
