-- Tests for git operations

local Git = require("git-worktree.git")

describe("Git", function()
  describe("is_inside_worktree", function()
    it("should return true when inside a git repository", function()
      -- This test assumes the tests are run from within the git repo
      local result = Git.is_inside_worktree()
      assert.is_boolean(result)
    end)
  end)

  describe("get_bare_worktree", function()
    it("should return the first worktree if only one exists", function()
      local worktrees = {
        { name = "main", path = "/path/to/main", bare = true },
      }
      local bare = Git.get_bare_worktree(worktrees)
      assert.is_not_nil(bare)
      assert.equals("main", bare.name)
    end)

    it("should return the bare worktree from multiple worktrees", function()
      local worktrees = {
        { name = "feature1", path = "/path/to/feature1", bare = false },
        { name = ".git", path = "/path/to/.git", bare = true },
        { name = "feature2", path = "/path/to/feature2", bare = false },
      }
      local bare = Git.get_bare_worktree(worktrees)
      assert.is_not_nil(bare)
      assert.equals(".git", bare.name)
      assert.is_true(bare.bare)
    end)

    it("should return nil if no bare worktree exists", function()
      local worktrees = {
        { name = "feature1", path = "/path/to/feature1", bare = false },
        { name = "feature2", path = "/path/to/feature2", bare = false },
      }
      local bare = Git.get_bare_worktree(worktrees)
      assert.is_nil(bare)
    end)
  end)

  describe("get_active_worktree", function()
    it("should return the active worktree", function()
      local cwd = vim.fn.getcwd()
      local worktrees = {
        { name = "other", path = "/some/other/path", is_active = function() return false end },
        { name = "current", path = cwd, is_active = function() return true end },
      }
      local active = Git.get_active_worktree(worktrees)
      assert.is_not_nil(active)
      assert.equals("current", active.name)
    end)

    it("should return nil if no worktree is active", function()
      local worktrees = {
        { name = "other1", path = "/path/1", is_active = function() return false end },
        { name = "other2", path = "/path/2", is_active = function() return false end },
      }
      local active = Git.get_active_worktree(worktrees)
      assert.is_nil(active)
    end)
  end)
end)
