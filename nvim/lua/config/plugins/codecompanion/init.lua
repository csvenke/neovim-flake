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
      provider = "mini_diff",
    },
    chat = {
      intro_message = "",
      show_header_separator = true,
      show_settings = true,
      show_references = false,
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
          extended_output = {
            default = false,
          },
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
        stop = {
          modes = { n = "<leader>aS" },
          description = "Stop the inline assistant",
        },
      },
    },
    cmd = {
      adapter = "anthropic",
    },
  },
})

require("config.plugins.codecompanion.hooks"):setup()

vim.keymap.set({ "n" }, "<leader>aa", "<cmd>CodeCompanion<cr>", { desc = "[a]i [a]sk" })
vim.keymap.set({ "v" }, "<leader>aa", ":'<,'>CodeCompanion<cr>", { desc = "[a]i [a]sk" })
vim.keymap.set({ "n", "v" }, "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "[a]i [n]ew chat" })
vim.keymap.set({ "n", "v" }, "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "[a]i [t]oggle chat" })
vim.keymap.set({ "n", "v" }, "<leader>ap", "<cmd>CodeCompanionAction<cr>", { desc = "[a]i action [p]alette" })
