require("nvim-ts-autotag").setup({})

require("nvim-treesitter").setup()

local indent_exclude = {
  "cs",
}

local group = vim.api.nvim_create_augroup("user-treesitter-hooks", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)

    if ok and not vim.tbl_contains(indent_exclude, args.match) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
