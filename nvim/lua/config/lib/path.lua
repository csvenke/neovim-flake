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
    local attached_buffers = client.attached_buffers

    -- Attempt graceful shutdown
    client:stop(true)
    vim.wait(3000, function()
      return client:is_stopped()
    end)

    -- Remove loaded buffers
    for buffer in pairs(attached_buffers) do
      if vim.api.nvim_buf_is_loaded(buffer) then
        require("mini.bufremove").delete(buffer, true)
      end
    end
  end

  -- Clear diagnostic cache
  vim.diagnostic.reset()

  -- Change current directory
  vim.cmd("cd " .. path)

  -- Attempt to find same file from pervious working directory
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
