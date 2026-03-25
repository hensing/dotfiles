return {
    -- comment toggling
    { "preservim/nerdcommenter" },

    -- fuzzy file finder
    { "ctrlpvim/ctrlp.vim" },

    -- todo.txt support
    { "dbeniamine/todo.txt-vim" },

    -- ansible YAML filetype
    { "pearofducks/ansible-vim" },

    -- Rust filetype support
    { "rust-lang/rust.vim", ft = "rust" },

    -- async syntax checking
    {
        "neomake/neomake",
        config = function()
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = "*",
                callback = function()
                    if vim.fn.exists(":Neomake") == 2 then
                        vim.cmd("Neomake")
                    end
                end,
            })
        end,
    },
}
