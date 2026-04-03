return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,  -- Treesitterと連携
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
        enable_check_bracket_line = true,  -- 括弧のチェックを有効化
        fast_wrap = {},  -- Alt+eで高速括弧ラップ
      })

      -- Enterキーで括弧内の改行時に自動インデント
      local Rule = require('nvim-autopairs.rule')
      npairs.add_rules({
        Rule("{", "}", {"lua", "javascript", "typescript", "python"})
          :set_end_pair_length(1)
      })
    end
  }
}
