return {
    -- statusline (replaces vim-airline)
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                icons_enabled = true,
                theme = "solarized_dark",
            },
            extensions = { "fugitive" },
        },
    },

    -- git change indicators in the gutter
    { "airblade/vim-gitgutter" },

    -- display, toggle and navigate marks
    { "kshenoy/vim-signature" },
}
