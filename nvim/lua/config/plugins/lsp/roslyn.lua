local M = {}

function M.setup()
  require("roslyn").setup({
    -- Workaround: https://github.com/dotnet/roslyn/issues/82857
    filewatching = "off",
    silent = true,
  })
end

return M
