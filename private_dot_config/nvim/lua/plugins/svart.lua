return
{
    "m6vrm/svart.nvim",
    config = function()
        require("svart").configure({
            label_atoms = "asdghklqwertyuiopzxcvbnmfj",
            search_update_register = false,
        })
    end,
    cmd = { "Svart" },
}
