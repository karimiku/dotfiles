return {
  "NvChad/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = false,
        sass = { enable = false },
        virtualtext = "■",
      },
      buftypes = {},
    })
  end
}
