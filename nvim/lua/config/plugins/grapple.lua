local group = vim.api.nvim_create_augroup("user-grapple-hooks", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = group,
  callback = function()
    local grapple = require("grapple")

    ---@param msg string
    local function notify(msg)
      vim.notify(msg, vim.log.levels.INFO, {
        title = "Grapple",
      })
    end

    ---@param index number
    local function select_if_exists(index)
      if grapple.exists({ index = index }) then
        grapple.select({ index = index })
      end
    end

    local function toggle_buffer_tag()
      local buffer = vim.api.nvim_get_current_buf()
      if grapple.exists({ buffer = buffer }) then
        grapple.untag()
        notify("Tag removed")
      else
        grapple.tag()
        notify("Tag added")
      end
    end

    grapple.setup({
      scope = "cwd",
      tag_title = function()
        return "Tags"
      end,
      statusline = {
        icon = "󰓹",
      },
      win_opts = {
        footer = "",
      },
    })

    vim.keymap.set("n", "<M-a>", function()
      toggle_buffer_tag()
    end, { desc = "Toggle buffer tag" })

    vim.keymap.set("n", "<M-e>", function()
      grapple.toggle_tags()
    end, { desc = "Open tag window" })

    vim.keymap.set("n", "<M-1>", function()
      select_if_exists(1)
    end, { desc = "Select tag [1]" })

    vim.keymap.set("n", "<M-2>", function()
      select_if_exists(2)
    end, { desc = "Select tag [2]" })

    vim.keymap.set("n", "<M-3>", function()
      select_if_exists(3)
    end, { desc = "Select tag [3]" })

    vim.keymap.set("n", "<M-4>", function()
      select_if_exists(4)
    end, { desc = "Select tag [4]" })

    vim.keymap.set("n", "<M-5>", function()
      select_if_exists(5)
    end, { desc = "Select tag [5]" })
  end,
})
