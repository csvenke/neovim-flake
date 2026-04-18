local M = {}

---@return string[]
local function discover_debug_dlls()
  local cwd = vim.fn.getcwd()
  local matches = vim.fn.globpath(cwd, "**/bin/Debug/**/*.runtimeconfig.json", false, true)
  local dlls = {}
  for _, runtimeconfig in ipairs(matches) do
    local dll = runtimeconfig:gsub("%.runtimeconfig%.json$", ".dll")
    if vim.fn.filereadable(dll) == 1 then
      table.insert(dlls, dll)
    end
  end
  return dlls
end

local function relative_to_cwd(path)
  return vim.fn.fnamemodify(path, ":.")
end

---@param dap table
---@return string|dap.Abort
local function resolve_program(dap)
  local dlls = discover_debug_dlls()

  if #dlls == 0 then
    vim.notify("No dlls found", vim.log.levels.WARN, { title = "DAP" })
    return dap.ABORT
  end

  if #dlls == 1 then
    vim.notify("Debugging " .. relative_to_cwd(dlls[1]), vim.log.levels.INFO, { title = "DAP" })
    return dlls[1]
  end

  local co = coroutine.running()
  vim.ui.select(dlls, { prompt = "Select program:", format_item = relative_to_cwd }, function(choice)
    coroutine.resume(co, choice)
  end)

  local choice = coroutine.yield()
  if choice == nil then
    return dap.ABORT
  end

  return choice
end

---@param debug_dlls string[]
---@return fun(proc: { pid: integer, name: string }): boolean
local function make_dotnet_filter(debug_dlls)
  local keys = {}
  for _, dll in ipairs(debug_dlls) do
    keys[#keys + 1] = dll
    keys[#keys + 1] = dll:sub(1, -5)
  end

  return function(proc)
    local cmd = proc and proc.name or ""
    if #keys == 0 then
      return cmd:find("dotnet", 1, true) ~= nil or cmd:find(".dll", 1, true) ~= nil
    end
    for _, key in ipairs(keys) do
      if cmd:find(key, 1, true) then
        return true
      end
    end
    return false
  end
end

function M.setup()
  local dap = require("dap")
  local utils = require("dap.utils")
  local shared_configuration = {
    type = "coreclr",
    justMyCode = false,
    sourceFileMap = {
      ["/build/source"] = "${workspaceFolder}",
    },
    symbolOptions = {
      searchPaths = { "~/symbols", "${workspaceFolder}/symbols" },
      searchMicrosoftSymbolServer = true,
      searchNuGetOrgSymbolServer = true,
    },
  }

  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    vim.tbl_deep_extend("force", shared_configuration, {
      name = "launch - netcoredbg (.NET program)",
      request = "launch",
      cwd = "${workspaceFolder}",
      program = function()
        return resolve_program(dap)
      end,
    }),
    vim.tbl_deep_extend("force", shared_configuration, {
      name = "attach - netcoredbg (running process)",
      request = "attach",
      processId = function()
        return utils.pick_process({ filter = make_dotnet_filter(discover_debug_dlls()) })
      end,
    }),
  }
end

return M
