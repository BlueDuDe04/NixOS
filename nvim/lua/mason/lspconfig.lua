-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  -- add any options here, or leave empty to use the default settings
})

local lspconfig = require('lspconfig')
lspconfig.tsserver.setup {}
lspconfig.gopls.setup {}
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace"
      }
    }
  }
})
lspconfig.rust_analyzer.setup {}
-- lspconfig.rnix.setup {}
lspconfig.nil_ls.setup {}
lspconfig.zls.setup {}
lspconfig.pylsp.setup {}
