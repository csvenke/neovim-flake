local U = require("nordic.utils")

---@param palette ExtendedPalette
---@param alpha number
local function visual(palette, alpha)
  return U.blend(palette.magenta.base, palette.gray0, alpha)
end

require("nordic").setup({
  after_palette = function(palette)
    palette.bg_selected = visual(palette, 0.05)
  end,
  on_highlight = function(highlights, palette)
    highlights.Visual = {
      bg = visual(palette, 0.1),
    }

    highlights.CursorLine = {
      bg = visual(palette, 0.03),
    }
  end,
})

vim.schedule(function()
  vim.cmd.colorscheme("nordic")
end)
