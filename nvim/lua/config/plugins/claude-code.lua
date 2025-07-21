vim.keymap.set("n", "<leader>aa", function()
  local prompt = vim.fn.input({ prompt = "⚡Ask" })
  if prompt == nil or prompt == "" then
    return
  end

  local relative_path = vim.fn.expand("%:.")
  local full_prompt = string.format("'@%s %s'", relative_path, prompt)

  vim.cmd("vsplit | term claude " .. full_prompt)
  vim.bo.filetype = "claude"
end, { desc = "[a]i [a]sk" })

vim.keymap.set("n", "<leader>an", function()
  vim.cmd.vsplit()
  vim.cmd("term claude")
  vim.bo.filetype = "claude"
end, { desc = "[a]i [a]sk" })

vim.keymap.set("n", "<leader>at", function()
  vim.cmd.vsplit()
  vim.cmd("term claude --continue")
  vim.bo.filetype = "claude"
end, { desc = "[a]i [a]sk" })
