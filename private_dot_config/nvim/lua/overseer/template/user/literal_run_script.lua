return {
    name = "run script",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cmd = { file }
        if vim.bo.filetype == "python" then
            cmd = { "python3", file }
        end
        if vim.bo.filetype == "go" then
            cmd = { "go", "run", file }
        end
        return {
            cmd = cmd,
            name = string.match(file, "[^/]*$"),
            components = {
                "on_output_summarize",
                "on_exit_set_status",
                "unique",
            },
        }
    end,
    condition = {
        filetype = { "sh", "python", "go" },
    },
}
