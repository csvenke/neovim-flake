---@class BreadcrumbOpts
---@field max_depth number
---@field excluded_filetypes string[]

local icons = require("config.lib.icons")

local SEPARATOR = " " .. icons.separator .. " "
local ELLIPSIS = "..."
local MODIFIED_INDICATOR = " " .. icons.modified .. " "

---@param hl string
---@param text string
local function hl_text(hl, text)
  return "%#" .. hl .. "#" .. text
end

local function get_folder_icon()
  return icons.dir, "Directory"
end

---@param bufnr number
local function get_relative_path(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return nil
  end

  local cwd = vim.fn.getcwd()
  local relative = vim.fn.fnamemodify(filepath, ":~:.")

  if vim.startswith(filepath, cwd) then
    return relative
  else
    return vim.fn.fnamemodify(filepath, ":~")
  end
end

---@param part string
---@param is_file boolean
local function render_part(part, is_file)
  if is_file then
    local icon, hl = icons.get_file_icon(part)
    local prefix = (icon ~= "" and hl ~= "") and hl_text(hl, icon .. " ") or ""
    return prefix .. hl_text("Normal", part)
  end

  local icon, hl = get_folder_icon()
  return hl_text(hl, icon .. " " .. part)
end

---@param parts string[]
---@param max_depth number
local function render_path(parts, max_depth)
  local folder_hl = select(2, get_folder_icon())
  local sep = hl_text(folder_hl, SEPARATOR)

  if #parts > max_depth then
    return table.concat({
      render_part(parts[1], false),
      sep,
      hl_text(folder_hl, ELLIPSIS),
      sep,
      render_part(parts[#parts - 1], false),
      hl_text("Comment", SEPARATOR),
      render_part(parts[#parts], true),
    }, "")
  end

  local result = {}
  for i, part in ipairs(parts) do
    if i > 1 then
      table.insert(result, sep)
    end
    table.insert(result, render_part(part, i == #parts))
  end
  return table.concat(result, "")
end

---@param bufnr number
---@param opts BreadcrumbOpts
local function format_breadcrumb(bufnr, opts)
  if vim.api.nvim_get_option_value("buftype", { buf = bufnr }) ~= "" then
    return ""
  end

  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if vim.tbl_contains(opts.excluded_filetypes, filetype) then
    return ""
  end

  local path = get_relative_path(bufnr)
  if not path then
    return ""
  end

  local parts = vim.split(path, "/", { plain = true })
  local breadcrumb = render_path(parts, opts.max_depth)

  -- Bug: Wont return true unless current buffer
  -- https://github.com/neovim/neovim/issues/32817
  if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
    breadcrumb = breadcrumb .. hl_text("WarningMsg", MODIFIED_INDICATOR)
  end

  return " " .. breadcrumb .. " "
end

---@param opts BreadcrumbOpts
local function update_all_breadcrumbs(opts)
  for _, winnr in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local breadcrumb = format_breadcrumb(bufnr, opts)
    pcall(vim.api.nvim_set_option_value, "winbar", breadcrumb, { win = winnr })
  end
end

---@param opts BreadcrumbOpts
local function setup(opts)
  local group = vim.api.nvim_create_augroup("user-breadcrumbs-hooks", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWinEnter",
    "WinEnter",
    "DirChanged",
    "BufModifiedSet",
    "ColorScheme",
  }, {
    group = group,
    callback = function()
      vim.schedule(function()
        update_all_breadcrumbs(opts)
      end)
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
