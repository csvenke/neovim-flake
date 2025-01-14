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
    ChatFinder = function()
      require("telescope.builtin").live_grep({
        prompt_title = "Search gp chats",
        cwd = require("gp").config.chat_dir,
        default_text = "topic: ",
        vimgrep_arguments = {
          "rg",
          "--column",
          "--smart-case",
          "--sortr=modified",
        },
      })
    end,
    FindBugs = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Find potential issues and/or bugs, if you cant find any respond with 'LGTM'\n"
        .. "Write response in code comments and nothing else\n"
      local agent = plugin.get_chat_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
    Question = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "```{{command}}}```\n\n"
        .. "Write the response to the question above in code comments and nothing else\n"
      local agent = plugin.get_chat_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, "🤖 " .. agent.name)
    end,
    Explain = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Please respond by explaining the code above\n"
        .. "Write response in code comments and nothing else\n"
      local agent = plugin.get_chat_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
    SuggestNaming = function(plugin, params)
      local template = "I have the following code from {{filename}}:\n\n"
        .. "```{{filetype}}\n{{selection}}\n```\n\n"
        .. "Suggest naming alternatives that clearly describe the selected function/class/variable's purpose\n"
        .. "Prefer short, simple and elegant names if possible\n"
        .. "Write response in code comments and nothing else\n"
      local agent = plugin.get_chat_agent()

      plugin.Prompt(params, plugin.Target.prepend, agent, template, nil, nil)
    end,
  },
})

vim.keymap.set("n", "<leader>sa", "<cmd>GpChatFinder<cr>", { desc = "[s]earch [a]i chats" })

vim.keymap.set("n", "<leader>aa", "<cmd>GpNew<cr>", { desc = "quick chat" })
vim.keymap.set("v", "<leader>aa", ":GpNew<cr>", { desc = "quick chat with selection" })
vim.keymap.set("n", "<leader>aA", "<cmd>%GpNew<cr>", { desc = "quick chat with buffer" })

vim.keymap.set("n", "<leader>ac", "<cmd>GpChatToggle<cr>", { desc = "toggle [c]hat" })
vim.keymap.set("n", "<leader>aC", "<cmd>GpChatNew<cr>", { desc = "new [C]hat" })

vim.keymap.set("n", "<leader>av", "<cmd>GpChatNew vsplit<cr>", { desc = "new chat (vertical)" })
vim.keymap.set("v", "<leader>av", ":GpChatNew vsplit<cr>", { desc = "new chat (vertical)" })
vim.keymap.set("n", "<leader>aV", "<cmd>%GpChatNew vsplit<cr>", { desc = "new chat (vertical)" })

vim.keymap.set("n", "<leader>as", "<cmd>GpChatNew split<cr>", { desc = "new chat (horizontal)" })
vim.keymap.set("v", "<leader>as", ":GpChatNew split<cr>", { desc = "new chat (horizontal)" })
vim.keymap.set("n", "<leader>aS", "<cmd>%GpChatNew split<cr>", { desc = "new chat (horizontal)" })

vim.keymap.set("v", "<leader>ar", ":GpRewrite<cr>", { desc = "rewrite selection" })
vim.keymap.set("n", "<leader>aR", "<cmd>%GpRewrite<cr>", { desc = "rewrite buffer (dangerous)" })

vim.keymap.set("n", "<leader>ao", "<cmd>GpAppend<cr>", { desc = "write below" })
vim.keymap.set("v", "<leader>ao", ":GpAppend<cr>", { desc = "write below selection" })

vim.keymap.set("n", "<leader>aO", "<cmd>GpPrepend<cr>", { desc = "write above" })
vim.keymap.set("v", "<leader>aO", ":GpPrepend<cr>", { desc = "write above selection" })

vim.keymap.set("v", "<leader>ap", ":GpChatPaste<cr>", { desc = "paste selection to chat" })
vim.keymap.set("n", "<leader>aP", "<cmd>%GpChatPaste<cr>", { desc = "paste buffer to chat" })

vim.keymap.set("v", "<leader>ae", ":GpExplain<cr>", { desc = "explain selection" })
vim.keymap.set("v", "<leader>an", ":GpSuggestNaming<cr>", { desc = "suggest naming for selection" })

vim.keymap.set("v", "<leader>ab", ":GpFindBugs<cr>", { desc = "find bugs for selection" })
vim.keymap.set("n", "<leader>aB", "<cmd>%GpFindBugs<cr>", { desc = "find bugs for buffer (dangerous)" })

vim.keymap.set("v", "<leader>aq", ":GpQuestion<cr>", { desc = "question about selection" })
