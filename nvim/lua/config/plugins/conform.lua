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
    cs = { "csharpier" },
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
    csharpier = {
      command = "dotnet-csharpier",
      args = { "--write-stdout" },
      cwd = require("conform.util").root_file({
        ".csharpierrc",
        ".csharpierrc.json",
        ".csharpierrc.yaml",
      }),
      require_cwd = true,
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
  },
})

local function format_buffer()
  conform.format({ async = true, lsp_fallback = true })
end

local function format_selection()
  conform.format({
    async = true,
    lsp_fallback = true,
    range = {
      start = vim.fn.getpos("'<"),
      ["end"] = vim.fn.getpos("'>"),
    },
  })
end

local function toggle_autoformat()
  vim.cmd("lua vim.g.autoformat = not vim.g.autoformat")
  if vim.g.autoformat then
    vim.notify("autoformat is on")
  else
    vim.notify("autoformat is off")
  end
end

vim.keymap.set("v", "F", format_selection, { desc = "format selection" })
vim.keymap.set("n", "F", format_buffer, { desc = "[F]ormat buffer" })
vim.keymap.set("n", "<C-f>", toggle_autoformat, { desc = "Toggle auto-[f]ormat" })
