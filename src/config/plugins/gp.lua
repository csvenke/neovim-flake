local function file_exists(filename)
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

local api_key_path = os.getenv("HOME") .. "/.vault/openai-api-key.txt"

if not file_exists(api_key_path) then
  require("gp").setup({})
  return
end

---@class GpConfig
local config = {
  openai_api_key = { "cat", api_key_path },
  default_chat_agent = "ChatGPT",
  default_command_agent = "CodeGPT",
  agents = {
    {
      name = "ChatGPT",
      chat = true,
      command = false,
      model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
      system_prompt = "You are a general AI assistant.\n\n"
        .. "The user provided the additional info about how they would like you to respond:\n\n"
        .. "- If you're unsure don't guess and say you don't know instead.\n"
        .. "- Ask question if you need clarification to provide better answer.\n"
        .. "- Think deeply and carefully from first principles step by step.\n"
        .. "- Zoom out first to see the big picture and then zoom in to details.\n"
        .. "- Use Socratic method to improve your thinking and coding skills.\n"
        .. "- Don't elide any code from your output if the answer requires coding.\n"
        .. "- Take a deep breath; You've got this!\n",
    },
    {
      name = "CodeGPT",
      chat = false,
      command = true,
      model = { model = "gpt-4o-mini", temperature = 0.8, top_p = 1 },
      system_prompt = "You are an AI specialized in refactoring code within Neovim.\n\n"
        .. "Please provide clear and concise code snippets without additional commentary.\n"
        .. "Enclose your responses within:\n\n```",
    },
  },
  hooks = {
    SuggestAlternativeNaming = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Give 5 alternative names that clearly describe the selected function/class/variable's purpose\n"
        .. "Write the suggestions in comments and nothing else"
      local agent = plugin.get_command_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
  },
}

require("gp").setup(config)

vim.keymap.set("n", "<leader>aa", "<cmd>GpChatToggle<cr>", { desc = "toggle chat" })
vim.keymap.set("n", "<leader>aA", "<cmd>GpChatNew<cr>", { desc = "new chat" })
vim.keymap.set("n", "<leader>av", "<cmd>GpChatNew vsplit<cr>", { desc = "new chat (vertical)" })
vim.keymap.set("n", "<leader>as", "<cmd>GpChatNew split<cr>", { desc = "new chat (horizontal)" })
vim.keymap.set({ "v", "x" }, "<leader>ap", ":'<,'>GpChatPaste<cr>", { desc = "paste selection to chat" })
vim.keymap.set({ "v", "x" }, "<leader>ar", ":'<,'>GpRewrite<cr>", { desc = "rewrite selection" })
vim.keymap.set({ "v", "x" }, "<leader>ao", ":'<,'>GpAppend<cr>", { desc = "insert below selection" })
vim.keymap.set({ "v", "x" }, "<leader>aO", ":'<,'>GpPrepend<cr>", { desc = "insert above selection" })
vim.keymap.set(
  { "v", "x" },
  "<leader>an",
  ":'<,'>GpSuggestAlternativeNaming<cr>",
  { desc = "suggest alternative naming" }
)
