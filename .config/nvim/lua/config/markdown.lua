-- markdown.lua
local M = {}

-- Helper function to create pandoc export commands
local function create_pandoc_command(name, defaults_file)
    local cmd = string.format("command! %s !pandoc '%%' -d %s -o '%%:r.pdf'", name, defaults_file)
    vim.cmd(cmd)
end

function M.setup()
    -- Create export commands
    create_pandoc_command("MarkdownExportAcademic", "~/.pandoc/defaults/academic.yaml")
    create_pandoc_command("MarkdownExportDefault", "~/.pandoc/defaults/default.yaml")
    create_pandoc_command("MarkdownExportModern", "~/.pandoc/defaults/modern.yaml")

    -- Create HTML export command
    vim.cmd([[
        command! MarkdownExportHTML !pandoc '%'
            \ --to html5
            \ --standalone
            \ --mathjax
            \ --highlight-style=pygments
            \ --css= markdown.css
            \ --bibliography=bibliography.bib
            \ --csl=chicago-author-date.csl
            \ -o '%:r.html'
    ]])

    -- Keymaps for exports
    local opts = { silent = true, buffer = true }
    vim.keymap.set("n", "<leader>ma", ":MarkdownExportAcademic<CR>", opts)
    vim.keymap.set("n", "<leader>md", ":MarkdownExportDefault<CR>", opts)
    vim.keymap.set("n", "<leader>mm", ":MarkdownExportModern<CR>", opts)
    vim.keymap.set("n", "<leader>mh", ":MarkdownExportHTML<CR>", opts)

    -- Basic markdown settings
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.breakindent = true
            vim.opt_local.conceallevel = 2
            vim.opt_local.spell = false
            vim.opt_local.spelllang = "en_us"
        end,
    })
end

return M