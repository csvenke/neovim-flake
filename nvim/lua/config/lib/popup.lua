---@class PopupOpts
---@field id string
---@field cmd string|nil
---@field width number|nil
---@field height number|nil

local M = {}

---@param id string
---@param cwd string
---@return number|nil
local function find_popup_buf(id, cwd)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      if vim.b[buf].popup_id == id and vim.b[buf].popup_cwd == cwd then
        return buf
      end
    end
  end
  return nil
end

---@param buf number
---@return number|nil
local function find_win_for_buf(buf)
  local winid = vim.fn.bufwinid(buf)
  return winid ~= -1 and winid or nil
end

---@param buf number
---@param opts PopupOpts
---@return number
local function create_popup_win(buf, opts)
  local width_ratio = opts.width or 0.8
  local height_ratio = opts.height or 0.8

  local width = math.floor(vim.o.columns * width_ratio)
  local height = math.floor(vim.o.lines * height_ratio)
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  local winhl = "FloatBorder:FloatTermBorder,Normal:FloatTermNormal"
  vim.api.nvim_set_option_value("winhl", winhl, { win = win })

  return win
end

---@param id string
---@param cmd string|nil
---@param cwd string
---@return number
local function create_popup_buf(id, cmd, cwd)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.b[buf].popup_id = id
  vim.b[buf].popup_cwd = cwd

  vim.api.nvim_buf_call(buf, function()
    vim.fn.jobstart(cmd or vim.o.shell, {
      term = true,
      cwd = cwd,
      on_exit = vim.schedule_wrap(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        local winid = find_win_for_buf(buf)
        if winid then
          vim.api.nvim_win_close(winid, true)
        end

        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end),
    })
  end)

  vim.keymap.set("n", "q", "<cmd>close!<cr>", { buffer = buf, desc = "close popup" })

  return buf
end

---@param opts PopupOpts
---@return number, number
function M.toggle(opts)
  local id = opts.id or opts.cmd or ""
  local cwd = vim.fn.getcwd()

  local existing_buf = find_popup_buf(id, cwd)
  if not existing_buf then
    local new_buf = create_popup_buf(id, opts.cmd, cwd)
    local new_win = create_popup_win(new_buf, opts)
    return new_buf, new_win
  end

  local existing_win = find_win_for_buf(existing_buf)
  if existing_win then
    vim.api.nvim_win_close(existing_win, true)
    return existing_buf, existing_win
  end

  local new_win = create_popup_win(existing_buf, opts)
  return existing_buf, new_win
end

return M
