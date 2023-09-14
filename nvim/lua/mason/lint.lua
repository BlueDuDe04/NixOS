local lint = require('lint')

lint.linters_by_ft = {
  javascript = { 'eslint', },
  javascriptreact = { 'eslint', },

  typescript = { 'eslint', },
  typescriptreact = { 'eslint', },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set('n', '<leader>L', function() lint.try_lint() end)
