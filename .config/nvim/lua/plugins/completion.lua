return {
    -- python completion via Jedi
    {
        "davidhalter/jedi-vim",
        ft = "python",
        init = function()
            -- use jedi for go-to-definition etc. but let ultisnips handle <tab>
            vim.g["jedi#completions_command"] = "<C-Space>"
            vim.g["jedi#goto_command"]        = "<leader>d"
            vim.g["jedi#goto_assignments_command"] = "<leader>g"
            vim.g["jedi#documentation_command"] = "K"
            vim.g["jedi#usages_command"] = "<leader>n"
            vim.g["jedi#rename_command"] = "<leader>r"
        end,
    },

    -- snippet engine
    {
        "SirVer/ultisnips",
        init = function()
            vim.g.UltiSnipsSnippetsDir       = "~/.vim/bundle/vim-snippets/UltiSnips"
            vim.g.UltiSnipsExpandTrigger      = "<s-enter>"
            vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
            vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
        end,
    },

    -- community snippets
    { "honza/vim-snippets" },

    -- editorconfig support
    { "editorconfig/editorconfig-vim" },
}
