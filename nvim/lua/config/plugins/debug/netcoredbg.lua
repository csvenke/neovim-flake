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

function M.setup()
  local dap = require("dap")
  local utils = require("dap.utils")

  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "attach - netcoredbg",
      request = "attach",
      justMyCode = false,
      sourceFileMap = {
        ["/build/source"] = "${workspaceFolder}",
      },
      symbolOptions = {
        searchPaths = { "~/symbols", "${workspaceFolder}/symbols" },
        searchMicrosoftSymbolServer = true,
        searchNuGetOrgSymbolServer = true,
      },
      processId = function()
        local info = find_project_info()

        return utils.pick_process({
          prompt = "Attach to process",
          filter = function(proc)
            if info == nil then
              return true
            end

            return vim.endswith(proc.name, info.name)
          end,
        })
      end,
      cwd = function()
        local info = find_project_info()

        if info ~= nil then
          return info.path
        end

        return vim.fn.getcwd()
      end,
    },
  }
end

return M
