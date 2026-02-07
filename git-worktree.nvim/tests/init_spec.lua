-- Test initialization and configuration

local git_worktree = require("git-worktree")

describe("git-worktree", function()
  before_each(function()
    -- Reset to default state before each test
  end)

  describe("setup", function()
    it("should initialize without errors", function()
      assert.has_no.errors(function()
        git_worktree.setup({})
      end)
    end)

    it("should accept custom configuration", function()
      assert.has_no.errors(function()
        git_worktree.setup({
          notify = false,
          enable_direnv = false,
          copy_shared = false,
        })
      end)
    end)

    it("should accept keymap configuration", function()
      assert.has_no.errors(function()
        git_worktree.setup({
          keymaps = {
            switch = "<leader>gt",
            add = "<leader>ga",
            remove = "<leader>gr",
          },
        })
      end)
    end)

    it("should accept nil/false to disable keymaps", function()
      assert.has_no.errors(function()
        git_worktree.setup({
          keymaps = {
            switch = nil,
            add = false,
            remove = nil,
          },
        })
      end)
    end)
  end)
end)
