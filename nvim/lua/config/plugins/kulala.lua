local function open_requests_tab()
  local dir = vim.fs.joinpath(vim.fn.stdpath("data"), "kulala")
  local file = vim.fs.joinpath(dir, "requests.http")

  vim.fn.mkdir(dir, "p")

  if not vim.uv.fs_stat(file) then
    local fd = vim.uv.fs_open(file, "w", 420)
    if fd then
      vim.uv.fs_close(fd)
    end
  end

  vim.cmd("tabnew")
  vim.cmd.edit(vim.fn.fnameescape(file))
end

require("kulala").setup({
  kulala_keymaps = false,
  global_keymaps = false,
  ui = {
    default_winbar_panes = { "body", "headers" },
    disable_news_popup = true,
    max_response_size = 5242880, -- 5 MB
    win_opts = {
      wo = {
        foldenable = false,
      },
    },
  },
  lsp = {
    filetypes = { "http", "rest" },
  },
})

vim.keymap.set("n", "<leader>Ro", open_requests_tab, { desc = "[R]equests [o]pen" })
vim.keymap.set("n", "<leader>RR", open_requests_tab, { desc = "[R]equests [o]pen" })

local group = vim.api.nvim_create_augroup("user-kulala-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "http", "rest" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<F5>", function()
      require("kulala").run()
    end, { buffer = event.buf, desc = "Run request" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json.kulala_ui", "text.kulala_ui", "xml.kulala_ui" },
  group = group,
  callback = function(event)
    vim.keymap.set("n", "<tab>", function()
      require("kulala.ui").toggle_headers()
    end, { buffer = event.buf, desc = "Toggle headers" })
  end,
})
