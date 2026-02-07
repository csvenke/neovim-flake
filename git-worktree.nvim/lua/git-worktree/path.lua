local M = {}

---@param directory string
---@return boolean
function M.is_directory(directory)
  return vim.fn.isdirectory(directory) == 1
end

---@param file string
---@return boolean
function M.is_file(file)
  return vim.fn.filereadable(file) == 1
end

---@param path string
function M.change_current_directory(path)
  local current_path = vim.fn.expand("%:.")

  -- Save all
  vim.cmd("silent! wa")

  -- Stop all lsp clients and close attached buffers
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    local buffers = vim.lsp.get_buffers_by_client_id(client.id)

    -- Attempt graceful shutdown
    vim.lsp.stop_client(client.id, true)
    vim.wait(3000, function()
      return vim.lsp.client_is_stopped(client.id)
    end)

    -- Remove loaded buffers
    for _, buffer in ipairs(buffers) do
      if vim.api.nvim_buf_is_loaded(buffer) then
        -- Use nvim_buf_delete instead of mini.bufremove
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
  end

  -- Clear diagnostic cache
  vim.diagnostic.reset()

  -- Change current directory
  vim.cmd("cd " .. path)

  -- Attempt to find same file from previous working directory
  local editable_path = M.is_file(current_path) and current_path or "."
  vim.cmd("edit " .. editable_path)

  -- Clear jumps/marks
  vim.cmd("delmarks!")
  vim.cmd("clearjumps")
end

---@param from string
---@param to string
function M.copy_directory(from, to)
  if not M.is_directory(from) then
    return
  end
  if not M.is_directory(to) then
    return
  end

  vim.system({ "cp", "-r", from .. "/.", to }):wait()
end

return M
