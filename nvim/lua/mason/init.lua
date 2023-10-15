local function init()
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ','

    require('mason.gitsigns')
    require('mason.lualine')
    require('mason.nvim-tree')
    require('mason.treesitter')
    require('mason.telescope')
    require('mason.lspconfig')
    require('mason.cmp')
    -- require('mason.harpoon')
    require('mason.lint')
    require('mason.comment')
    require('mason.dashboard')
    require('mason.neotest')
    require('mason.refactoring')
    require('mason.neorg')
    require('mason.colorizer')

    require('mason.keymap')

    vim.o.nu = true
    vim.o.relativenumber = true
    vim.opt.fillchars:append { eob = " " }

    vim.o.tabstop = 4
    vim.o.softtabstop = 4
    vim.o.shiftwidth = 4
    vim.o.expandtab = true

    vim.o.swapfile = false
    vim.o.backup = false
    vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
    vim.o.undofile = true

    vim.o.hlsearch = false
    vim.o.incsearch = true

    vim.opt.clipboard = "unnamedplus"

    vim.cmd.colorscheme "tokyonight-night"

    -- vim.keymap.set("n", "<leader>y", "\"+y")
    -- vim.keymap.set("v", "<leader>y", "\"+y")

    vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "<S-Up>", ":m '<-2<CR>gv=gv")

    vim.keymap.set('n', '<Leader>F', '<cmd>:NvimTreeToggle<cr>')

    -- vim.keymap.set('n', '<Leader>F', '<cmd>:NvimTreeFocus<cr>')

    vim.keymap.set('n', '<Leader>W', '<cmd>:WhichKey<cr>')

    vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
end

return {
    init = init,
}
