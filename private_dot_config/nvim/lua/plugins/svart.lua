return
{
    "m6vrm/svart.nvim",
    commit = "b73f54728fc3129a59acead31d73fabdba8acfda",
    config = function()
        require("svart").configure({
            label_atoms = "asdghklqwertyuiopzxcvbnmfj",
            search_update_register = false,
        })
    end,
    cmd = { "Svart" },
}
