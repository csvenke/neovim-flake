local gitsigns = require("gitsigns")

gitsigns.setup({
  on_attach = function()
    local function stage_visual_hunk()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end

    local function reset_visual_hunk()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end

    vim.keymap.set("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "toggle [g]it [b]lame" })
    vim.keymap.set("v", "gh", stage_visual_hunk, { desc = "git stage [h]unk" })
    vim.keymap.set("v", "gH", reset_visual_hunk, { desc = "git reset [H]unk" })
  end,
})
