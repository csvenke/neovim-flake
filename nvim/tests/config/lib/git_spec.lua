---@diagnostic disable: duplicate-set-field
local Worktree = require("config.lib.worktree")
local Git = require("config.lib.git")

describe("config.lib.git", function()
  describe("get_bare_worktree", function()
    it("returns nil for empty worktree list", function()
      local worktrees = {}
      local result = Git.get_bare_worktree(worktrees)

      assert.is_nil(result)
    end)

    it("returns the single worktree when list has only one entry", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
      }
      local result = Git.get_bare_worktree(worktrees)

      assert.are.equal("main", result.name)
    end)

    it("returns the bare worktree from a list with multiple entries", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
        Worktree.new({ name = "repo", bare = true }),
        Worktree.new({ name = "feature", bare = false }),
      }
      local result = Git.get_bare_worktree(worktrees)

      assert.are.equal("repo", result.name)
      assert.is_true(result.bare)
    end)

    it("returns nil when no bare worktree exists in list with multiple entries", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
        Worktree.new({ name = "feature", bare = false }),
      }
      local result = Git.get_bare_worktree(worktrees)

      assert.is_nil(result)
    end)
  end)

  describe("get_active_worktree", function()
    local original_getcwd

    before_each(function()
      original_getcwd = vim.fn.getcwd
    end)

    after_each(function()
      vim.fn.getcwd = original_getcwd
    end)

    it("returns nil for empty worktree list", function()
      local worktrees = {}
      local result = Git.get_active_worktree(worktrees)

      assert.is_nil(result)
    end)

    it("returns worktree matching current working directory", function()
      vim.fn.getcwd = function()
        return "/home/user/repos/feature"
      end

      local worktrees = {
        Worktree.new({ name = "main", path = "/home/user/repos/main" }),
        Worktree.new({ name = "feature", path = "/home/user/repos/feature" }),
        Worktree.new({ name = "hotfix", path = "/home/user/repos/hotfix" }),
      }
      local result = Git.get_active_worktree(worktrees)

      assert.are.equal("feature", result.name)
      assert.are.equal("/home/user/repos/feature", result.path)
    end)

    it("returns nil when no worktree matches current directory", function()
      vim.fn.getcwd = function()
        return "/home/user/other-project"
      end

      local worktrees = {
        Worktree.new({ name = "main", path = "/home/user/repos/main" }),
        Worktree.new({ name = "feature", path = "/home/user/repos/feature" }),
      }
      local result = Git.get_active_worktree(worktrees)

      assert.is_nil(result)
    end)
  end)
end)
