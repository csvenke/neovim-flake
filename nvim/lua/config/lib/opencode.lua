local M = {}

---Run opencode with a message and pass the text reply to the callback.
---@param opts { message: string, agent?: string, model?: string, args?: string[] }
---@param callback fun(reply: string|nil, err?: string)
function M.run(opts, callback)
  local argv = { "opencode2", "run", "--format", "json", "--auto" }
  if opts.agent then
    vim.list_extend(argv, { "--agent", opts.agent })
  end
  if opts.model then
    vim.list_extend(argv, { "-m", opts.model })
  end
  vim.list_extend(argv, opts.args or {})
  table.insert(argv, opts.message)

  vim.system(
    argv,
    { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        callback(nil, "opencode failed: " .. (res.stderr or ""))
        return
      end
      local reply = ""
      for line in (res.stdout or ""):gmatch("[^\n]+") do
        local ok, event = pcall(vim.json.decode, line)
        if ok and event.type == "text" and event.part and event.part.text then
          -- The model may emit intermediate narration (e.g. "I'll check the
          -- staged diff…") as separate text parts; the final part is the answer.
          reply = event.part.text
        end
      end
      reply = vim.trim(reply)
      if reply == "" then
        callback(nil, "opencode returned an empty reply")
        return
      end
      callback(reply)
    end)
  )
end

return M
