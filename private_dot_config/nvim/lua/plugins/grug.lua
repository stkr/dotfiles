return 
{
    'MagicDuck/grug-far.nvim',
    commit = '6b76bef24436e0c38e1723599f00c196d3cf7c2e',
    lazy = true,
    cmd = { "GrugFar" },
    config = function()
        require('grug-far').setup({
            extraRgArgs = '--smart-case',
            windowCreationCommand = 'split',
        });
    end,
}
