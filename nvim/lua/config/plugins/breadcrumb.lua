---@class Options
---@field max_depth number
---@field excluded_filetypes string[]

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

---@param filename string
local function get_icon(filename)
  if not has_devicons then
    return "", ""
  end

  local extension = filename:match("^.+%.(.+)$")
  local icon, hl = devicons.get_icon(filename, extension, { default = true })
  return icon or "", hl or ""
end

---@param bufnr number
local function get_relative_path(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return nil
  end

  local cwd = vim.fn.getcwd()
  local relative = vim.fn.fnamemodify(filepath, ":~:.")

  -- If file is outside cwd, show full path relative to home
  if vim.startswith(filepath, cwd) then
    return relative
  else
    return vim.fn.fnamemodify(filepath, ":~")
  end
end

---@param bufnr number
---@param opts Options
local function format_breadcrumb(bufnr, opts)
  -- Skip if buffer is not a normal file
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    return ""
  end

  -- Skip special filetypes (oil, terminals, etc.)
  local filetype = vim.bo[bufnr].filetype
  for _, ft in ipairs(opts.excluded_filetypes) do
    if filetype == ft then
      return ""
    end
  end

  -- Get relative path
  local path = get_relative_path(bufnr)
  if not path then
    return ""
  end

  local parts = vim.split(path, "/", { plain = true })
  local breadcrumb_parts = {}

  local max_depth = opts.max_depth

  -- Handle deep nesting
  if #parts > max_depth then
    -- Show first directory
    table.insert(breadcrumb_parts, "%#Comment#" .. parts[1])

    -- Add ellipsis
    table.insert(breadcrumb_parts, "%#Comment# 󰅂 ")
    table.insert(breadcrumb_parts, "%#Comment#...")

    -- Add separator before parent directory
    table.insert(breadcrumb_parts, "%#Comment# 󰅂 ")

    -- Show parent directory (second to last)
    table.insert(breadcrumb_parts, "%#Comment#" .. parts[#parts - 1])

    -- Add separator before filename
    table.insert(breadcrumb_parts, "%#Comment# 󰅂 ")

    -- Show filename with icon
    local filename = parts[#parts]
    local icon, hl = get_icon(filename)
    if icon ~= "" and hl ~= "" then
      table.insert(breadcrumb_parts, "%#" .. hl .. "#" .. icon .. " ")
    end
    table.insert(breadcrumb_parts, "%#Normal#" .. filename)
  else
    -- Normal display for shallow paths
    for i, part in ipairs(parts) do
      if i > 1 then
        table.insert(breadcrumb_parts, "%#Comment# 󰅂 ")
      end

      -- Last part (filename) gets an icon
      if i == #parts then
        local icon, hl = get_icon(part)
        if icon ~= "" and hl ~= "" then
          table.insert(breadcrumb_parts, "%#" .. hl .. "#" .. icon .. " ")
        end
        table.insert(breadcrumb_parts, "%#Normal#" .. part)
      else
        table.insert(breadcrumb_parts, "%#Comment#" .. part)
      end
    end
  end

  return " " .. table.concat(breadcrumb_parts, "") .. " "
end

---@param opts Options
local function update_all_breadcrumbs(opts)
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local ok, bufnr = pcall(vim.api.nvim_win_get_buf, winnr)
    if ok then
      local breadcrumb = format_breadcrumb(bufnr, opts)

      if breadcrumb ~= "" then
        pcall(vim.api.nvim_set_option_value, "winbar", breadcrumb, { win = winnr })
      else
        pcall(vim.api.nvim_set_option_value, "winbar", "", { win = winnr })
      end
    end
  end
end

local function init_highlights()
  local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  vim.api.nvim_set_hl(0, "WinBar", { bg = normal_bg })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = normal_bg })
end

---@param opts Options
local function setup(opts)
  init_highlights()

  local group = vim.api.nvim_create_augroup("user-breadcrumbs-hooks", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "DirChanged", "BufWritePost" }, {
    group = group,
    callback = function()
      update_all_breadcrumbs(opts)
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      init_highlights()
      update_all_breadcrumbs(opts)
    end,
  })

  vim.schedule(function()
    update_all_breadcrumbs(opts)
  end)
end

setup({
  max_depth = 4,
  excluded_filetypes = {
    "oil",
    "alpha",
  },
})
