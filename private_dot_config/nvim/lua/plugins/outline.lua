return
{
    "hedyhli/outline.nvim",
    commit = "33fcb583aa9072ba62b7d6119020c4063fc27f9f",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    config = function()
        require("outline").setup()
    end
}
