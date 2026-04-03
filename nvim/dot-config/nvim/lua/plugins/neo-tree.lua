return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            "node_modules",
            ".DS_Store",
          },
          never_show = {},
        },
      },
    })
    -- 今開いているファイルをツリー上で見つけてフォーカスする
    vim.keymap.set('n', '<C-n>', '<cmd>Neotree toggle reveal right<cr>', {})
  end,
}
