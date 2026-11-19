local osc7 = require("config.lib.osc7")

local group = vim.api.nvim_create_augroup("user-osc7", { clear = true })

---@param seq string
local function send(seq)
  if vim.api.nvim_ui_send then
    vim.api.nvim_ui_send(seq)
  else
    io.stdout:write(seq)
    io.stdout:flush()
  end
end

local function report()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  send(osc7.build(vim.fn.getcwd(-1, -1)))
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = report,
})

vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    if vim.v.event.scope == "global" then
      report()
    end
  end,
})
