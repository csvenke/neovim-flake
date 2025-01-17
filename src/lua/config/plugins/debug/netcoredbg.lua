local M = {}

--- @class ProjectInfo
--- @field path string
--- @field name string

--- @return ProjectInfo|nil
local function find_project_info()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_file, ":p:h")

  local check_dir = current_dir
  local root_dir = vim.fn.getcwd()

  while #check_dir >= #root_dir do
    local csproj = vim.fn.glob(check_dir .. "/*.csproj", false, true)

    if #csproj > 0 then
      local project_path = vim.fn.fnamemodify(csproj[1], ":p:h")
      local project_name = vim.fn.fnamemodify(csproj[1], ":t:r")

      return { path = project_path, name = project_name }
    end

    check_dir = vim.fn.fnamemodify(check_dir, ":h")
  end

  return nil
end

---@return string
local function get_nearest_dll_path()
  local info = find_project_info()

  if info == nil then
    return vim.fn.getcwd() .. "/bin/Debug"
  end

  local debug_path = info.path .. "/bin/Debug"
  local dll_file_name = info.name .. ".dll"
  local dll_files = vim.fn.globpath(debug_path, "**/" .. dll_file_name, false, true)

  if #dll_files == 0 then
    return debug_path
  end

  return dll_files[1]
end

function M.setup()
  local dap = require("dap")

  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      program = function()
        local dll_path = get_nearest_dll_path()
        return vim.fn.input("Path to dll", dll_path)
      end,
    },
  }
end

return M
