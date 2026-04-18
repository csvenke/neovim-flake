local M = {}

--- @class ProjectInfo
--- @field path string
--- @field name string
--- @field file string

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
      local project_file = vim.fn.fnamemodify(csproj[1], ":p")

      return { path = project_path, name = project_name, file = project_file }
    end

    check_dir = vim.fn.fnamemodify(check_dir, ":h")
  end

  return nil
end

---@param value string
---@return string
local function normalize_path(value)
  return value:gsub("\\", "/"):lower()
end

---@param command string
---@return string[]
local function split_command(command)
  local ok, utils = pcall(require, "dap.utils")

  if ok and utils.splitstr then
    local split_ok, tokens = pcall(utils.splitstr, command)

    if split_ok and #tokens > 0 then
      return tokens
    end
  end

  return vim.split(command, "%s+", { trimempty = true })
end

---@param token string
---@return string
local function path_basename(token)
  return token:match("([^/]+)$") or token
end

---@param output string
---@return table|nil
local function decode_msbuild_properties(output)
  local ok, decoded = pcall(vim.json.decode, output)

  if ok and decoded and decoded.Properties then
    return decoded.Properties
  end

  local json_start = output:find("{", 1, true)

  if json_start == nil then
    return nil
  end

  ok, decoded = pcall(vim.json.decode, output:sub(json_start))

  if ok and decoded and decoded.Properties then
    return decoded.Properties
  end

  return nil
end

---@param info ProjectInfo
---@param properties string[]
---@param extra_properties table<string, string>|nil
---@return table|nil
local function get_msbuild_properties(info, properties, extra_properties)
  if vim.fn.executable("dotnet") ~= 1 then
    return nil
  end

  local args = {
    "dotnet",
    "msbuild",
    info.file,
    "-nologo",
    "-getProperty:" .. table.concat(properties, ","),
  }

  for name, value in pairs(extra_properties or {}) do
    table.insert(args, string.format("-property:%s=%s", name, value))
  end

  local result = vim.system(args, { cwd = info.path, text = true }):wait()

  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
    return nil
  end

  return decode_msbuild_properties(result.stdout)
end

---@param info ProjectInfo
---@return string|nil
local function pick_target_framework(info)
  local properties = get_msbuild_properties(info, { "TargetFramework", "TargetFrameworks" })

  if properties == nil then
    return nil
  end

  local framework = properties.TargetFramework

  if type(framework) == "string" and framework ~= "" then
    return framework
  end

  local frameworks = vim.split(properties.TargetFrameworks or "", ";", { trimempty = true })

  if #frameworks == 0 then
    return nil
  end

  return require("dap.ui").pick_if_many(frameworks, "Select target framework")
end

---@param info ProjectInfo
---@return string|nil
local function resolve_program_path(info)
  local framework = pick_target_framework(info)

  if framework == nil then
    return nil
  end

  local properties = get_msbuild_properties(info, { "TargetPath", "TargetFramework" }, {
    TargetFramework = framework,
  })

  if properties == nil or type(properties.TargetPath) ~= "string" or properties.TargetPath == "" then
    return nil
  end

  return vim.fn.fnamemodify(vim.fn.expand(properties.TargetPath), ":p")
end

---@param info ProjectInfo
---@param default_program string
---@param dap table
---@return string|dap.Abort
local function prompt_for_program(info, default_program, dap)
  local program =
    vim.fn.input(string.format("Path to %s debug program (.dll/.exe): ", info.name), default_program, "file")

  if program == nil or program == "" then
    return dap.ABORT
  end

  local absolute_program = vim.fn.fnamemodify(vim.fn.expand(program), ":p")

  if vim.fn.filereadable(absolute_program) ~= 1 then
    vim.notify(string.format("Debug program not found: %s", absolute_program), vim.log.levels.WARN, { title = "DAP" })
    return dap.ABORT
  end

  return absolute_program
end

---@param info ProjectInfo|nil
---@param dap table
---@return string|dap.Abort
local function pick_program(info, dap)
  if info == nil then
    vim.notify(
      "No .csproj found from the current buffer up to the working directory",
      vim.log.levels.WARN,
      { title = "DAP" }
    )
    return dap.ABORT
  end

  local default_program = resolve_program_path(info)

  if default_program ~= nil and vim.fn.filereadable(default_program) == 1 then
    return default_program
  end

  return prompt_for_program(info, default_program or (info.path .. "/bin/Debug/"), dap)
end

---@param proc dap.utils.Proc
---@param info ProjectInfo
---@return integer
local function score_project_process(proc, info)
  local project_name = info.name:lower()
  local project_path = normalize_path(info.path)
  local best_score = 0

  for _, token in ipairs(split_command(proc.name)) do
    local normalized = normalize_path(token)
    local basename = path_basename(normalized)
    local stem = basename:gsub("%.csproj$", ""):gsub("%.dll$", ""):gsub("%.exe$", "")
    local in_project = normalized == project_path or vim.startswith(normalized, project_path .. "/")
    local in_build_output = in_project and normalized:find("/bin/", 1, true) ~= nil
    local score = 0

    if basename == project_name .. ".dll" then
      score = 6
    elseif basename == project_name .. ".exe" or basename == project_name then
      score = 5
    elseif basename == project_name .. ".csproj" then
      score = 3
    end

    if in_project then
      score = math.max(score, 2)
    end

    if in_build_output and stem == project_name then
      score = math.max(score, 7)
    end

    best_score = math.max(best_score, score)
  end

  return best_score
end

---@param proc dap.utils.Proc
---@return string
local function format_process_label(proc)
  return string.format("pid=%d name=%s", proc.pid, proc.name)
end

---@param info ProjectInfo|nil
---@param utils table
---@return dap.utils.Proc[]
local function get_attach_candidates(info, utils)
  local processes = utils.get_processes()

  if info == nil then
    return processes
  end

  local best_score = 0
  local scored = {}

  for _, proc in ipairs(processes) do
    local score = score_project_process(proc, info)

    if score > 0 then
      best_score = math.max(best_score, score)
      table.insert(scored, { proc = proc, score = score })
    end
  end

  if best_score == 0 then
    return {}
  end

  return vim.tbl_map(
    function(entry)
      return entry.proc
    end,
    vim.tbl_filter(function(entry)
      return entry.score == best_score
    end, scored)
  )
end

---@param info ProjectInfo|nil
---@param utils table
---@param dap table
---@return integer|dap.Abort
local function pick_process_id(info, utils, dap)
  local candidates = get_attach_candidates(info, utils)

  if #candidates == 0 then
    local message = "No attachable processes found"

    if info ~= nil then
      message = string.format("No attachable processes found for project %s", info.name)
    end

    vim.notify(message, vim.log.levels.WARN, { title = "DAP" })
    return dap.ABORT
  end

  local proc = require("dap.ui").pick_if_many(candidates, "Attach to process", format_process_label)
  return proc and proc.pid or dap.ABORT
end

function M.setup()
  local dap = require("dap")
  local utils = require("dap.utils")

  dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
  }

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
    cwd = function()
      local info = find_project_info()

      if info ~= nil then
        return info.path
      end

      return vim.fn.getcwd()
    end,
  }

  dap.configurations.cs = {
    vim.tbl_extend("force", shared_configuration, {
      name = "launch - netcoredbg (.NET program)",
      request = "launch",
      program = function()
        local info = find_project_info()
        return pick_program(info, dap)
      end,
    }),
    vim.tbl_extend("force", shared_configuration, {
      name = "attach - netcoredbg (running process)",
      request = "attach",
      processId = function()
        local info = find_project_info()
        return pick_process_id(info, utils, dap)
      end,
    }),
  }
end

return M
