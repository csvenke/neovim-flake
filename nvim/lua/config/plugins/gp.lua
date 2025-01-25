require("gp").setup({
  default_chat_agent = "AnthropicChat",
  default_command_agent = "AnthropicCode",
  providers = {
    anthropic = {
      endpoint = "https://api.anthropic.com/v1/messages",
      secret = os.getenv("ANTHROPIC_API_KEY"),
    },
  },
  agents = {
    {
      provider = "anthropic",
      name = "AnthropicChat",
      chat = true,
      command = false,
      model = { model = "claude-3-5-sonnet-latest" },
      system_prompt = require("gp.defaults").chat_system_prompt,
    },
    {
      provider = "anthropic",
      name = "AnthropicCode",
      chat = false,
      command = true,
      model = { model = "claude-3-5-sonnet-latest" },
      system_prompt = require("gp.defaults").code_system_prompt,
    },
  },
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
