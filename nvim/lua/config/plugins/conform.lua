local conform = require("conform")

vim.g.autoformat = false

conform.setup({
  notify_on_error = false,
  format_on_save = function()
    if not vim.g.autoformat then
      return nil
    end

    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    bash = { "shfmt" },
    sh = { "shfmt" },
    elixir = { "mix_format" },
    eelixir = { "mix_format" },
    heex = { "mix_format" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    htmlangular = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
    handlebars = { "prettier" },
    kdl = { "kdlfmt" },
  },
  formatters = {
    stylua = {
      command = "stylua",
      cwd = require("conform.util").root_file({
        ".stylua.toml",
        "stylua.toml",
        ".editorconfig",
      }),
      require_cwd = false,
    },
    shfmt = {
      command = "shfmt",
      prepend_args = { "-i", "2" },
    },
    prettier = {
      command = "prettierd",
      cwd = require("conform.util").root_file({
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.js",
        "prettier.config.js",
        ".editorconfig",
      }),
      require_cwd = true,
    },
    kdlfmt = {
      command = "kdlfmt",
      args = { "format", "-" },
      cwd = require("conform.util").root_file({
        "kdlfmt.kdl",
        ".editorconfig",
      }),
    },
    mix_format = {
      command = "mix",
      args = { "format", "-" },
      cwd = require("conform.util").root_file({
        "mix.exs",
        ".formatter.exs",
      }),
      require_cwd = true,
    },
  },
})

local function format_buffer()
  conform.format({ async = true, lsp_fallback = true })
end

local function format_selection()
  conform.format({
    async = true,
    lsp_fallback = true,
  })
end

local function toggle_autoformat()
  vim.g.autoformat = not vim.g.autoformat
  if vim.g.autoformat then
    vim.notify("autoformat is on")
  else
    vim.notify("autoformat is off")
  end
end

vim.keymap.set("v", "F", format_selection, { desc = "format selection" })
vim.keymap.set("n", "F", format_buffer, { desc = "[F]ormat buffer" })
vim.keymap.set("n", "<leader>tf", toggle_autoformat, { desc = "[t]oggle auto[f]ormat" })
