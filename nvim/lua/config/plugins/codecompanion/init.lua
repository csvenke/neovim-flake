require("render-markdown").setup({
  file_types = { "codecompanion" },
  latex = { enabled = false },
  heading = {
    backgrounds = {},
    icons = { "|> " },
  },
  overrides = {
    filetype = {
      codecompanion = {
        html = {
          tag = {
            buf = { icon = "󰈙 ", highlight = "Special" },
            file = { icon = "󰈔 ", highlight = "Special" },
            tool = { icon = "⚡", highlight = "Special" },
            help = { icon = "󰘥 ", highlight = "Special" },
            image = { icon = " ", highlight = "Special" },
            symbols = { icon = " ", highlight = "Special" },
            url = { icon = "󰖟 ", highlight = "Special" },
            var = { icon = " ", highlight = "Special" },
            prompt = { icon = " ", highlight = "Special" },
            group = { icon = " ", highlight = "Special" },
          },
        },
      },
    },
  },
})

require("codecompanion").setup({
  display = {
    action_palette = {
      provider = "default",
    },
    chat = {
      intro_message = "",
      show_header_separator = true,
      show_settings = false,
      show_context = false,
    },
  },
  adapters = {
    http = {
      opts = {
        show_defaults = false,
      },
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          schema = {
            extended_thinking = {
              default = false,
            },
          },
        })
      end,
    },
    acp = {
      opts = {
        show_defaults = false,
      },
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          defaults = {
            auth_method = "oauth-personal",
          },
        })
      end,
    },
  },
  strategies = {
    chat = {
      adapter = "anthropic",
      roles = {
        user = "🧑‍💻 (You)",
        llm = function(adapter)
          return string.format("🤖 Clank (%s)", adapter.formatted_name)
        end,
      },
      keymaps = {
        send = {
          modes = { n = "<cr>", i = "<Nop>" },
        },
      },
      tools = {
        opts = {
          default_tools = {
            "grep_search",
            "read_file",
            "get_changed_files",
            "insert_edit_into_file",
          },
        },
      },
    },
    inline = {
      adapter = "anthropic",
      keymaps = {
        accept_change = {
          modes = { n = "gA" },
        },
        reject_change = {
          modes = { n = "gR" },
        },
        always_accept = {
          modes = { n = "gY" },
        },
      },
    },
    cmd = {
      adapter = "anthropic",
    },
  },
  extensions = {
    spinner = {},
  },
})

require("config.plugins.codecompanion.hooks"):setup()

vim.keymap.set({ "n" }, "<leader>aa", function()
  vim.ui.input({ prompt = "⚡Ask (buffer)" }, function(input)
    if input ~= nil and input ~= "" then
      vim.cmd("CodeCompanionChat #{buffer} " .. input)
    end
  end)
end, { desc = "[a]i [a]sk" })

vim.keymap.set({ "v" }, "<leader>aa", function()
  vim.ui.input({ prompt = "⚡Ask (selected)" }, function(input)
    if input ~= nil and input ~= "" then
      vim.cmd("'<,'>CodeCompanionChat " .. input)
    end
  end)
end, { desc = "[a]i [a]sk" })

vim.keymap.set({ "n" }, "<leader>ae", function()
  vim.ui.input({ prompt = "⚡Edit (buffer)" }, function(input)
    if input ~= nil and input ~= "" then
      vim.cmd("%CodeCompanion " .. input)
    end
  end)
end, { desc = "[a]i [e]dit" })

vim.keymap.set({ "v" }, "<leader>ae", function()
  vim.ui.input({ prompt = "⚡Edit (selection)" }, function(input)
    if input ~= nil and input ~= "" then
      vim.cmd("'<,'>CodeCompanion " .. input)
    end
  end)
end, { desc = "[a]i [e]dit" })

vim.keymap.set({ "n", "v" }, "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "[a]i [n]ew chat" })
vim.keymap.set({ "n", "v" }, "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "[a]i [t]oggle chat" })
vim.keymap.set({ "n", "v" }, "<leader>ap", "<cmd>CodeCompanionAction<cr>", { desc = "[a]i action [p]alette" })
