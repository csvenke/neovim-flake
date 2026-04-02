local M = {}

local function normalize_path(path)
  return vim.fs.normalize(path)
end

function M.workspace_root()
  local root = vim.env.INTEGRATION_TEST_WORKSPACE_ROOT

  if type(root) ~= "string" or root == "" then
    error("Missing INTEGRATION_TEST_WORKSPACE_ROOT")
  end

  if vim.fn.isdirectory(root) ~= 1 then
    error(string.format("Integration test workspace does not exist: %s", root))
  end

  return root
end

function M.absolute_path(relative_path)
  if type(relative_path) ~= "string" or relative_path == "" then
    error("Missing integration-test relative path")
  end

  if relative_path:sub(1, 1) == "/" then
    error(string.format("Integration-test path must stay within the workspace root: %s", relative_path))
  end

  local root = normalize_path(M.workspace_root())
  local path = normalize_path(root .. "/" .. relative_path)
  local root_prefix = root:gsub("/+$", "") .. "/"

  if path ~= root and not vim.startswith(path, root_prefix) then
    error(string.format("Integration-test path must stay within the workspace root: %s", relative_path))
  end

  return path
end

function M.open_file(relative_path)
  local root = M.workspace_root()
  local path = M.absolute_path(relative_path)

  vim.api.nvim_set_current_dir(root)
  vim.cmd.edit(vim.fn.fnameescape(path))

  return vim.api.nvim_get_current_buf(), path
end

function M.cursor_position(bufnr, needle, opts)
  bufnr = bufnr or 0
  opts = opts or {}

  if type(needle) ~= "string" or needle == "" then
    error("Missing integration-test search text")
  end

  local occurrence = opts.occurrence or 1
  local col_offset = opts.col_offset or 0
  local matches = 0

  for line_number, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local column = line:find(needle, 1, true)

    if column then
      matches = matches + 1

      if matches == occurrence then
        return { line_number, (column - 1) + col_offset }
      end
    end
  end

  error(string.format("Could not find integration-test text: %s", needle))
end

function M.set_cursor(bufnr, needle, opts)
  local position = M.cursor_position(bufnr, needle, opts)

  vim.api.nvim_win_set_cursor(0, position)

  return position
end

return M
