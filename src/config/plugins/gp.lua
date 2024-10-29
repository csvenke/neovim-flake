local function file_exists(filename)
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

local default_chat_agent = nil
local default_command_agent = nil
local providers = {}
local agents = {}

local openai_api_key_path = os.getenv("HOME") .. "/.vault/openai-api-key.txt"
local anthropic_api_key_path = os.getenv("HOME") .. "/.vault/anthropic-api-key.txt"

if file_exists(openai_api_key_path) then
  default_chat_agent = "OpenAiChat"
  default_command_agent = "OpenAiCode"

  providers.openai = {
    endpoint = "https://api.openai.com/v1/chat/completions",
    secret = { "cat", openai_api_key_path },
  }
  table.insert(agents, {
    provider = "openai",
    name = "OpenAiChat",
    chat = true,
    command = false,
    model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
    system_prompt = require("gp.defaults").chat_system_prompt,
  })
  table.insert(agents, {
    provider = "openai",
    name = "OpenAiCode",
    chat = false,
    command = true,
    model = { model = "gpt-4o-mini", temperature = 0.7, top_p = 1 },
    system_prompt = require("gp.defaults").code_system_prompt,
  })
end

if file_exists(anthropic_api_key_path) then
  default_chat_agent = "AnthropicChat"
  default_command_agent = "AnthropicCode"

  providers.anthropic = {
    endpoint = "https://api.anthropic.com/v1/messages",
    secret = { "cat", anthropic_api_key_path },
  }
  table.insert(agents, {
    provider = "anthropic",
    name = "AnthropicChat",
    chat = true,
    command = false,
    model = { model = "claude-3-5-sonnet-20241022", temperature = 0.8, top_p = 1 },
    system_prompt = require("gp.defaults").chat_system_prompt,
  })
  table.insert(agents, {
    provider = "anthropic",
    name = "AnthropicCode",
    chat = false,
    command = true,
    model = { model = "claude-3-5-sonnet-20241022", temperature = 0.7, top_p = 1 },
    system_prompt = require("gp.defaults").code_system_prompt,
  })
end

if default_chat_agent == nil then
  return
end
if default_command_agent == nil then
  return
end

require("gp").setup({
  default_chat_agent = default_chat_agent,
  default_command_agent = default_command_agent,
  providers = providers,
  agents = agents,
  hooks = {
    Explain = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Please respond by explaining the code above\n"
        .. "Write the explaination in comments and nothing else\n"
      local agent = plugin.get_command_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
    SuggestAlternativeNaming = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Give 5 alternative names that clearly describe the selected function/class/variable's purpose\n"
        .. "Write the suggestions in comments and nothing else\n"
      local agent = plugin.get_command_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
  },
})

vim.keymap.set("n", "<leader>aa", "<cmd>GpChatToggle<cr>", { desc = "toggle chat" })
vim.keymap.set("n", "<leader>aA", "<cmd>GpChatNew<cr>", { desc = "new chat" })
vim.keymap.set("n", "<leader>av", "<cmd>GpChatNew vsplit<cr>", { desc = "new chat (vertical)" })
vim.keymap.set("n", "<leader>as", "<cmd>GpChatNew split<cr>", { desc = "new chat (horizontal)" })
vim.keymap.set("n", "<leader>ao", "<cmd>GpAppend<cr>", { desc = "insert below" })
vim.keymap.set("n", "<leader>aO", "<cmd>GpPrepend<cr>", { desc = "insert above" })
vim.keymap.set({ "v", "x" }, "<leader>ap", ":'<,'>GpChatPaste<cr>", { desc = "paste selection to chat" })
vim.keymap.set({ "v", "x" }, "<leader>ar", ":'<,'>GpRewrite<cr>", { desc = "rewrite selection" })
vim.keymap.set({ "v", "x" }, "<leader>ao", ":'<,'>GpAppend<cr>", { desc = "insert below selection" })
vim.keymap.set({ "v", "x" }, "<leader>aO", ":'<,'>GpPrepend<cr>", { desc = "insert above selection" })
vim.keymap.set({ "v", "x" }, "<leader>ae", ":'<,'>GpExplain<cr>", { desc = "explain selection" })
vim.keymap.set(
  { "v", "x" },
  "<leader>an",
  ":'<,'>GpSuggestAlternativeNaming<cr>",
  { desc = "suggest alternative naming" }
)
