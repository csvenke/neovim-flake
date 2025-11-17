local M = {}

function M.setup()
  require("roslyn").setup({
    broad_search = true,
    lock_target = true,
    silent = true,
  })

  local group = vim.api.nvim_create_augroup("user-lsp-roslyn-hooks", { clear = true })

  -- Workaround: https://github.com/dotnet/roslyn/issues/79939
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "cs" },
    callback = function()
      vim.api.nvim_clear_autocmds({
        pattern = "*",
        event = "LspProgress",
        group = "noice_lsp_progress",
      })
    end,
  })
end

return M
