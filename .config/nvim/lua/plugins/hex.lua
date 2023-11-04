return
{
    'RaafatTurki/hex.nvim',
    config = function()
        require("hex").setup()
    end,
    cmd = { "HexDump", "HexToggle", "HexAssemble", },
}
