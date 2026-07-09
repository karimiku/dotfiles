return {
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- ヘッダーの色を設定
      pcall(vim.api.nvim_set_hl, 0, "DashboardHeader", { fg = "#6CABDD", bold = true })

      local header = {}
      if vim.fn.executable("figlet") == 1 then
        -- かっこいいフォントのオプション
        -- header = vim.fn.systemlist('figlet -f slant "NEOVIM"')      -- 斜め
        -- header = vim.fn.systemlist('figlet -f 3d "NEOVIM"')         -- 3D
        -- header = vim.fn.systemlist('figlet -f banner3 "NEOVIM"')    -- バナー3
        -- header = vim.fn.systemlist('figlet -f block "NEOVIM"')      -- ブロック
        -- header = vim.fn.systemlist('figlet -f big "NEOVIM"')       -- 大きい
        header = vim.fn.systemlist('figlet -f doom "NEOVIM"')         -- ドゥーム風（おすすめ）
      else
        -- かっこいい手動ASCIIアート
        header = {
          "",
          "",
          "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
          "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
          "",
          "",
        }
      end

      require("dashboard").setup({
        theme = "hyper",
        config = {
          header = header,
          center = {
            { icon = "  ", desc = "New file",      key = "e", action = "ene | startinsert" },
            { icon = "  ", desc = "Find file",     key = "f", action = "Telescope find_files" },
            { icon = "  ", desc = "Recent files",  key = "r", action = "Telescope oldfiles" },
            { icon = "  ", desc = "Live grep",     key = "g", action = "Telescope live_grep" },
            { icon = "  ", desc = "Edit config",   key = "c", action = "edit $MYVIMRC" },
            { icon = "  ", desc = "Quit",          key = "q", action = "qa" },
          },
          footer = {},
        },
      })
    end,
  },
}
