local M = {}

function M:setup()
  local group = vim.api.nvim_create_augroup("user-codecompanion-hooks", { clear = true })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionChatOpened",
    group = group,
    callback = function()
      vim.api.nvim_exec_autocmds("VimResized", {})
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = { "CodeCompanionToolFinished" },
    group = group,
    callback = function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          require("conform").format({ bufnr = buf })
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = { "CodeCompanionInlineFinished" },
    group = group,
    callback = function(request)
      require("conform").format({ bufnr = request.buf })
    end,
  })
end

M.handles = {}

return M
