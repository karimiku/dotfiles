-- タブとインデントの基本設定
vim.opt.expandtab = true      -- タブをスペースに変換
vim.opt.tabstop = 2           -- タブの表示幅
vim.opt.softtabstop = 2       -- タブキーを押したときの幅
vim.opt.shiftwidth = 2        -- 自動インデントの幅

-- インデント設定
vim.opt.autoindent = true     -- 前の行のインデントを継続
vim.opt.smartindent = true    -- スマートインデント
vim.opt.breakindent = true    -- 折り返し時にインデントを保持

-- ファイル自動読み込み設定
vim.opt.autoread = true

-- ファイルが外部で変更された時に自動的にリロード
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- ファイルが変更された時に通知
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("ファイルが外部で変更されました", vim.log.levels.WARN)
  end,
})

-- 行番号と表示設定
vim.opt.number = true           -- 行番号を表示
vim.opt.relativenumber = true   -- 相対行番号を表示
vim.opt.cursorline = true       -- カーソル行をハイライト
vim.opt.signcolumn = "yes"      -- 記号列を常に表示
vim.opt.termguicolors = true    -- 24bitカラーを有効化

-- 検索設定
vim.opt.ignorecase = true       -- 検索時に大文字小文字を区別しない
vim.opt.smartcase = true        -- 大文字が含まれる場合は区別
vim.opt.incsearch = true        -- インクリメンタル検索
vim.opt.hlsearch = true         -- 検索結果をハイライト

-- スクロール設定
vim.opt.scrolloff = 8           -- 画面端から8行の余裕
vim.opt.sidescrolloff = 8       -- 横スクロールも同様

-- クリップボード統合
vim.opt.clipboard = "unnamedplus"  -- システムクリップボードを使用

-- ファイル管理
vim.opt.backup = false          -- バックアップファイルを作らない
vim.opt.swapfile = false        -- スワップファイルを作らない
vim.opt.undofile = true         -- undo履歴を永続化
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"  -- undo履歴の保存場所

-- ウィンドウ分割
vim.opt.splitbelow = true       -- 水平分割時に下に開く
vim.opt.splitright = true       -- 垂直分割時に右に開く

-- その他
vim.opt.mouse = "a"             -- マウスサポート
vim.opt.wrap = false            -- 行の折り返しを無効化
vim.opt.updatetime = 250        -- CursorHoldのタイミング

vim.g.mapleader= " "
