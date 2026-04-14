local M = {}

---@param path string
---@return uv_fs_t?
local function stat(path)
  return vim.uv.fs_stat(vim.fs.normalize(path))
end

---@param directory string
---@return boolean
function M.is_directory(directory)
  local directory_stat = stat(directory)
  return directory_stat ~= nil and directory_stat.type == "directory"
end

---@param file string
---@return boolean
function M.is_file(file)
  local file_stat = stat(file)
  return file_stat ~= nil and file_stat.type == "file"
end

---@param path string
function M.change_current_directory(path)
  local current_dir = vim.fn.getcwd()
  local current_path = vim.api.nvim_buf_get_name(0)
  local relative_path = current_path ~= "" and vim.fs.relpath(current_dir, current_path) or nil
  local normalized_path = vim.fs.normalize(path)

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
  vim.api.nvim_set_current_dir(normalized_path)

  -- Attempt to find same file from previous working directory
  local next_path = "."
  if relative_path and M.is_file(vim.fs.joinpath(normalized_path, relative_path)) then
    next_path = relative_path
  end
  vim.cmd.edit(vim.fn.fnameescape(next_path))

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

  vim.system({ "cp", "-r", vim.fs.joinpath(from, "."), to }):wait()
end

return M
