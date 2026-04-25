---@class PopupOpts
---@field id? string
---@field cmd? string
---@field width? number
---@field height? number

-- Floating terminal/runtime popup orchestration.
local M = {}

local popup_counter = 0

---@return string
local function generate_unique_id()
  popup_counter = popup_counter + 1
  return "popup_" .. popup_counter .. "_" .. os.time()
end

---@param id string
---@param cwd string
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
local function find_win_for_buf(buf)
  local winid = vim.fn.bufwinid(buf)
  return winid ~= -1 and winid or nil
end

---@param opts PopupOpts
---@return vim.api.keyset.win_config
local function get_win_config(opts)
  local width_ratio = opts.width or 0.8
  local height_ratio = opts.height or 0.8

  local width = math.floor(vim.o.columns * width_ratio)
  local height = math.floor(vim.o.lines * height_ratio)
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }
end

---@param buf number
---@param opts PopupOpts
local function create_popup_win(buf, opts)
  local win_opts = get_win_config(opts)
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  local winhl = "FloatBorder:FloatTermBorder,Normal:FloatTermNormal"
  vim.api.nvim_set_option_value("winhl", winhl, { win = win })

  local group = vim.api.nvim_create_augroup("user-popup-hooks-" .. win, { clear = true })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, get_win_config(opts))
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(win),
    once = true,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, group)
    end,
  })

  return win
end

---@param id string
---@param cmd string?
---@param cwd string
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
        if winid and vim.api.nvim_win_is_valid(winid) then
          pcall(vim.api.nvim_win_close, winid, false)
        end

        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(buf) and vim.fn.bufwinid(buf) == -1 then
            pcall(vim.api.nvim_buf_delete, buf, { force = false })
          end
        end, 100)
      end),
    })
  end)

  return buf
end

---@param opts PopupOpts
function M.toggle(opts)
  local id = opts.id or opts.cmd or generate_unique_id()
  local cwd = vim.fn.getcwd()

  local existing_buf = find_popup_buf(id, cwd)
  if not existing_buf then
    local new_buf = create_popup_buf(id, opts.cmd, cwd)
    local new_win = create_popup_win(new_buf, opts)
    return new_buf, new_win
  end

  local existing_win = find_win_for_buf(existing_buf)
  if existing_win then
    vim.api.nvim_win_close(existing_win, false)
    return existing_buf, existing_win
  end

  local new_win = create_popup_win(existing_buf, opts)
  return existing_buf, new_win
end

return M
