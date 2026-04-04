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

local wrapped_roslyn_clients = {}

-- Prevent roslyn LSP from crashing on codediff virtual buffers.
-- codediff virtual buffers (codediff://) may get tracked by Neovim's
-- LSP subsystem without roslyn receiving didOpen. When the buffer closes, Neovim
-- sends didClose, which crashes roslyn because the URI was never opened.
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "roslyn" then
      return
    end

    if wrapped_roslyn_clients[client.id] then
      return
    end
    wrapped_roslyn_clients[client.id] = true

    local original_rpc_notify = client.rpc.notify
    client.rpc.notify = function(method, params)
      if method == "textDocument/didClose" and params and params.textDocument then
        local uri = params.textDocument.uri
        if uri and uri:match("^codediff://") then
          return true
        end
      end
      return original_rpc_notify(method, params)
    end
  end,
})
