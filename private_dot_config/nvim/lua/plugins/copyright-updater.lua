return
{
    'LittleMorph/copyright-updater.nvim',
    event = 'BufModifiedSet', -- Delay loading until a buffer is modified
    opts = {
        mappings = {
            toggle = nil,
        },
        limiters = {
            range = '1,10',
        }
    },
}
