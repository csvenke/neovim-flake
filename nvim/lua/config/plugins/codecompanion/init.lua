require("render-markdown").setup({
  file_types = { "codecompanion" },
  latex = {
    enabled = false,
  },
  heading = {
    backgrounds = {},
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
      show_settings = true,
      show_references = true,
      keymaps = {
        send = {
          modes = { n = "<CR>", i = "<C-s>" },
        },
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
      tools = {
        opts = {
          auto_submit_errors = true,
          auto_submit_success = true,
        },
      },
    },
    inline = {
      adapter = "anthropic",
      opts = {
        auto_submit = true,
        auto_apply = true,
      },
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

vim.keymap.set({ "n" }, "<leader>aa", "<cmd>CodeCompanion<cr>", { desc = "[a]i [a]sk" })
vim.keymap.set({ "v" }, "<leader>aa", ":'<,'>CodeCompanion<cr>", { desc = "[a]i [a]sk" })
vim.keymap.set({ "n", "v" }, "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "[a]i [n]ew chat" })
vim.keymap.set({ "n", "v" }, "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "[a]i [t]oggle chat" })
vim.keymap.set({ "n", "v" }, "<leader>ap", "<cmd>CodeCompanionAction<cr>", { desc = "[a]i action [p]alette" })
vim.keymap.set("n", "<leader>ah", "<cmd>CodeCompanionHistory<cr>", { desc = "[a] chat [h]istory" })
