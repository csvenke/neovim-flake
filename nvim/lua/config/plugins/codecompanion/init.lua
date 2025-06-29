require("render-markdown").setup({
  file_types = { "codecompanion" },
  latex = {
    enabled = false,
  },
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
    diff = {
      enabled = false,
    },
    chat = {
      intro_message = "",
      show_header_separator = true,
      show_settings = false,
      show_references = false,
      default_tools = {
        "read",
      },
    },
  },
  adapters = {
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
  strategies = {
    chat = {
      adapter = "anthropic",
      roles = {
        user = "🧑‍💻 (You)",
        llm = "🤖 Claude",
      },
      keymaps = {
        send = {
          modes = { n = "<cr>", i = "<Nop>" },
        },
      },
      tools = {
        opts = {
          auto_submit = false,
          auto_submit_errors = true,
          auto_submit_success = true,
        },
        groups = {
          ["read"] = {
            description = "Read",
            tools = { "grep_search", "read_file", "file_search" },
            opts = {
              collapse_tools = true,
            },
          },
          ["write"] = {
            description = "Write",
            tools = { "create_file", "insert_edit_into_file" },
            opts = {
              collapse_tools = true,
            },
          },
        },
      },
    },
    inline = {
      adapter = "anthropic",
      keymaps = {
        accept_change = {
          modes = { n = "<leader>aY" },
          description = "Accept the suggested change",
        },
        reject_change = {
          modes = { n = "<leader>aN" },
          description = "Reject the suggested change",
        },
      },
    },
    cmd = {
      adapter = "anthropic",
    },
  },
  extensions = {
    history = {
      enabled = true,
      opts = {
        keymap = "<leader>ah",
        picker = "telescope",
      },
    },
  },
})

require("config.plugins.codecompanion.hooks"):setup()

vim.keymap.set({ "n" }, "<leader>aa", function()
  vim.ui.input({ prompt = "⚡Ask" }, function(input)
    if input ~= nil and input ~= "" then
      vim.cmd("CodeCompanionChat " .. input)
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
vim.keymap.set("n", "<leader>ah", "<cmd>CodeCompanionHistory<cr>", { desc = "[a] chat [h]istory" })
