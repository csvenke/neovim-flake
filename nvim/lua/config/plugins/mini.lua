local function deleteBuffer()
  local delete = require("mini.bufremove").delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 1 then
      vim.cmd.write()
      delete(0)
    elseif choice == 2 then
      delete(0, true)
    end
  else
    delete(0)
  end
end

local function deleteBufferForce()
  require("mini.bufremove").delete(0, true)
end

require("mini.pairs").setup()

require("mini.ai").setup({
  mappings = {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  },
})

require("mini.diff").setup()

vim.keymap.set("n", "<leader>bd", deleteBuffer, { desc = "[b]uffer [d]elete" })
vim.keymap.set("n", "<leader>bD", deleteBufferForce, { desc = "[b]uffer [D]elete (force)" })
