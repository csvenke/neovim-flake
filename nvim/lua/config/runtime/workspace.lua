local Path = require("config.lib.path")

-- Editor/workspace transitions with full runtime orchestration.
local M = {}

---@param path string
function M.change_current_directory(path)
  local current_dir = vim.fn.getcwd()
  local current_path = vim.api.nvim_buf_get_name(0)
  local relative_path = current_path ~= "" and vim.fs.relpath(current_dir, current_path) or nil
  local normalized_path = vim.fs.normalize(path)

  vim.cmd("silent! wa")

  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    local attached_buffers = client.attached_buffers

    client:stop(true)
    vim.wait(3000, function()
      return client:is_stopped()
    end)

    for buffer in pairs(attached_buffers) do
      if vim.api.nvim_buf_is_loaded(buffer) then
        require("mini.bufremove").delete(buffer, true)
      end
    end
  end

  vim.diagnostic.reset()
  vim.api.nvim_set_current_dir(normalized_path)

  local next_path = "."
  if relative_path and Path.is_file(vim.fs.joinpath(normalized_path, relative_path)) then
    next_path = relative_path
  end
  vim.cmd.edit(vim.fn.fnameescape(next_path))

  vim.cmd("delmarks!")
  vim.cmd("clearjumps")
end

return M
