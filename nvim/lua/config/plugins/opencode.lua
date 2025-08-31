if vim.fn.executable("opencode") == 0 then
  return
end

local group = vim.api.nvim_create_augroup("user-opencode-hooks", { clear = true })
local terminal_file_type = "opencode_terminal"

require("opencode").setup({
  terminal = {
    win = {
      bo = {
        filetype = terminal_file_type,
      },
    },
  },
})

vim.keymap.set("n", "<leader>aa", function()
  require("opencode").ask()
end, { desc = "[a]i [a]sk" })

vim.keymap.set("n", "<leader>aA", function()
  require("opencode").ask("@buffer: ")
end, { desc = "[a]i [A]sk (buffer)" })

vim.keymap.set("v", "<leader>aa", function()
  require("opencode").ask("@selection: ")
end, { desc = "[a]i [a]sk (selection)" })

vim.keymap.set({ "n", "v" }, "<leader>ap", function()
  require("opencode").select_prompt()
end, { desc = "[a]i select [p]rompt" })

vim.keymap.set("n", "<leader>at", function()
  require("opencode").toggle()
  vim.cmd("stopinsert")
  vim.cmd("wincmd =")
end, { desc = "[a]i [t]oggle chat" })

vim.keymap.set("n", "<leader>an", function()
  require("opencode").command("session_new")
end, { desc = "[a]i [n]ew session" })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = terminal_file_type,
  callback = function(args)
    vim.keymap.set("t", "<C-u>", function()
      require("opencode").command("messages_half_page_up")
    end, { buffer = args.buf })

    vim.keymap.set("t", "<C-d>", function()
      require("opencode").command("messages_half_page_down")
    end, { buffer = args.buf })
  end,
})
