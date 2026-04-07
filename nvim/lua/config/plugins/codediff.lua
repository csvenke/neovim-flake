local workspace = require("config.lib.workspace")

local explorer_width = 40

require("codediff").setup({
  highlights = {
    line_insert = "DiffAdd",
    line_delete = "DiffDelete",
    char_insert = "DiffAdd",
    char_delete = "DiffDelete",
  },
  explorer = {
    initial_focus = "modified",
    view_mode = "tree",
    width = explorer_width,
  },
  diff = {
    compute_moves = true,
  },
  keymaps = {
    view = {
      quit = "<C-q>",
      toggle_explorer = "<Nop>",
      next_hunk = "gh",
      prev_hunk = "gH",
      next_file = "<Tab>",
      prev_file = "<S-Tab>",
      diff_get = "<Nop>",
      diff_put = "<Nop>",
    },
    explorer = {
      select = "l",
      hover = "K",
    },
    conflict = {
      accept_incoming = "<Nop>",
      accept_current = "<Nop>",
      accept_both = "<Nop>",
      discard = "<Nop>",
      next_conflict = "<Nop>",
      prev_conflict = "<Nop>",
      diffget_incoming = "<Nop>",
      diffget_current = "<Nop>",
    },
  },
})

local function open_codediff(cmd)
  workspace.enter()
  vim.cmd(cmd)
end

vim.keymap.set("n", "<leader>gd", function()
  open_codediff("CodeDiff")
end, { desc = "[g]it [d]iff view" })

vim.keymap.set("n", "<leader>gh", function()
  open_codediff("CodeDiff history %")
end, { desc = "[g]it [h]istory" })

vim.keymap.set("n", "<leader>gH", function()
  open_codediff("CodeDiff history")
end, { desc = "[g]it [H]istory" })

vim.keymap.set("n", "<leader>gr", function()
  open_codediff("CodeDiff origin/HEAD")
end, { desc = "[g]it code [r]eview" })

local group = vim.api.nvim_create_augroup("user-codediff-hooks", { clear = true })

vim.api.nvim_create_autocmd("BufUnload", {
  group = group,
  pattern = "codediff://*",
  callback = function()
    workspace.exit()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].filetype == "codediff-explorer" then
      vim.opt_local.winfixwidth = true
    end
  end,
})
