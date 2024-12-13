return
{
    'LittleMorph/copyright-updater.nvim',
    commit = "b5986fee560ae8981598ae4da8d4c949a0550da0",
    event = 'BufModifiedSet', -- Delay loading until a buffer is modified
    opts = {
        return_cursor = true,
        mappings = {
            toggle = "",
        },
        limiters = {
            range = '1,10',
        }
    },
}
