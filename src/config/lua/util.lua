local M = {}

function M.make_map_buffer(buffer)
  return function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc })
  end
end

--- @param name string
function M.make_code_action(name)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { name },
        diagnostics = {},
      },
    })
  end
end

return M
