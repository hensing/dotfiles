-- Claude AI integration — only loaded when ANTHROPIC_API_KEY is set
return {
    {
        "anthropics/claude.vim",
        cond = function()
            return vim.env.ANTHROPIC_API_KEY ~= nil
        end,
        config = function()
            vim.g.claude_api_key = vim.env.ANTHROPIC_API_KEY
        end,
    },
}
