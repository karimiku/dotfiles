return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- `make` コマンドがある場合のみビルドする
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  config = function()
    local builtin = require("telescope.builtin")

    -- プロジェクトルートから検索（.gitがある場所）
    vim.keymap.set('n', '<C-p>', function()
      local project_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
      if project_root and vim.fn.isdirectory(project_root) == 1 then
        builtin.find_files({ cwd = project_root })
      else
        -- .gitがない場合は現在のディレクトリから
        builtin.find_files({ cwd = vim.fn.getcwd() })
      end
    end, {})

    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

    require('telescope').setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          "^%.git/",
          ".next",
          "dist",
          "build",
          ".cache",
          ".vscode",
          ".idea",
          "coverage",
          ".nyc_output",
          ".pnp",
          ".yarn",
          "iCloud Drive",
          "iCloud Drive（アーカイブ）",
          ".local",
          "Library",
          "%.pdf$",
          "%.docx?$",
          "%.xlsx?$",
          "%.png$",
          "Movies",
          "*.log",
          "*.tmp",
          "*.swp",
          "*.swo",
          "*~",
          ".DS_Store",
          "yarn.lock",
          "package-lock.json",
          "bun.lock",
        },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
        mappings = {
          i = {
            ["<C-c>"] = "close",
          },
        },
        debounce = 50,
        path_display = { "smart" },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
      -- fzf拡張機能の設定
      extensions = {
        fzf = {
          fuzzy = true, -- あいまい検索を有効化
          override_generic_sorter = true, -- 汎用ソーターを上書き
          override_file_sorter = true, -- ファイルソーターを上書き
          case_mode = "smart_case", -- 賢い大文字小文字の区別
        },
      },
    })

    -- fzf拡張機能を読み込む
    require('telescope').load_extension('fzf')
  end,
}
