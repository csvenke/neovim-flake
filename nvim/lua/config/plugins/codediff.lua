local workspace = require("lib.workspace")

require("codediff").setup({
  highlights = {
    line_insert = "DiffAdd",
    line_delete = "DiffDelete",
    char_insert = "DiffAdd",
    char_delete = "DiffDelete",
  },
  explorer = {
    initial_focus = "modified",
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

vim.api.nvim_create_autocmd("BufUnload", {
  pattern = "codediff://*",
  callback = function()
    workspace.exit()
  end,
})

local wrapped_roslyn_clients = {}

-- Prevent roslyn LSP from crashing on codediff virtual buffers.
-- The issue: codediff virtual buffers (codediff://) may get tracked by Neovim's
-- LSP subsystem without roslyn receiving didOpen. When the buffer closes, Neovim
-- sends didClose, which crashes roslyn because the URI was never opened.
--
-- Solution: Wrap the roslyn client's rpc.notify method to filter out didClose for
-- codediff:// URIs. We wrap rpc.notify because client:notify eventually calls it.
vim.api.nvim_create_autocmd("LspAttach", {
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
