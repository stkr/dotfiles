return
{
    "svart",
    url = 'https://gitlab.com/madyanov/svart.nvim',
    config = function()
        require("svart").configure({
            label_atoms = "asdghklqwertyuiopzxcvbnmfj",
            search_update_register = false,
        })
    end,
    cmd = { "Svart" },
}
