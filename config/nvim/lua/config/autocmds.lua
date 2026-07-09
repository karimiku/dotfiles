-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- .lsp ファイルを Common Lisp として認識
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.lsp",
  callback = function()
    vim.bo.filetype = "commonlisp"
  end,
})

-- YAMLファイルのインデント設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
    vim.opt_local.autoindent = true
    vim.opt_local.indentkeys = "o,O,*<Return>,<:>,!^F"
  end,
})
