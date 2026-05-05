require("gitsigns").setup({
  on_attach = function()
    local actions = require("gitsigns.actions")

    local function stage_visual_hunk()
      actions.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end

    local function reset_visual_hunk()
      actions.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end

    vim.keymap.set("n", "<leader>tg", actions.toggle_current_line_blame, { desc = "[t]oggle [g]it blame" })
    vim.keymap.set("n", "<leader>gb", actions.blame_line, { desc = "[g]it [b]lame line" })
    vim.keymap.set("v", "gh", stage_visual_hunk, { desc = "git stage [h]unk" })
    vim.keymap.set("v", "gH", reset_visual_hunk, { desc = "git reset [H]unk" })
  end,
})
