---@diagnostic disable: duplicate-set-field
local Worktree = require("config.lib.worktree")

describe("config.runtime.git", function()
  local git
  local path
  local workspace
  local original_getcwd
  local original_wait
  local original_is_directory
  local original_change_current_directory

  before_each(function()
    package.loaded["config.runtime.git"] = nil
    package.loaded["config.runtime.workspace"] = nil

    original_getcwd = vim.fn.getcwd
    original_wait = vim.wait

    path = require("config.lib.path")
    workspace = require("config.runtime.workspace")
    original_is_directory = path.is_directory
    original_change_current_directory = workspace.change_current_directory

    git = require("config.runtime.git")
  end)

  after_each(function()
    vim.fn.getcwd = original_getcwd
    vim.wait = original_wait
    path.is_directory = original_is_directory
    workspace.change_current_directory = original_change_current_directory
  end)

  describe("get_bare_worktree", function()
    it("returns nil for empty worktree list", function()
      local worktrees = {}
      local result = git.get_bare_worktree(worktrees)

      assert.is_nil(result)
    end)

    it("returns the single worktree when list has only one entry", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
      }
      local result = git.get_bare_worktree(worktrees)

      assert.are.equal("main", result.name)
    end)

    it("returns the bare worktree from a list with multiple entries", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
        Worktree.new({ name = "repo", bare = true }),
        Worktree.new({ name = "feature", bare = false }),
      }
      local result = git.get_bare_worktree(worktrees)

      assert.are.equal("repo", result.name)
      assert.is_true(result.bare)
    end)

    it("returns nil when no bare worktree exists in list with multiple entries", function()
      local worktrees = {
        Worktree.new({ name = "main", bare = false }),
        Worktree.new({ name = "feature", bare = false }),
      }
      local result = git.get_bare_worktree(worktrees)

      assert.is_nil(result)
    end)
  end)

  describe("get_active_worktree", function()
    it("returns nil for empty worktree list", function()
      local worktrees = {}
      local result = git.get_active_worktree(worktrees)

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
      local result = git.get_active_worktree(worktrees)

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
      local result = git.get_active_worktree(worktrees)

      assert.is_nil(result)
    end)
  end)

  describe("worktree_switch", function()
    it("delegates active workspace switching to the runtime workspace module", function()
      local switched_to
      local active = false
      local worktree = Worktree.new({ name = "feature", path = "/repo/feature" })

      path.is_directory = function(pathname)
        return pathname == "/repo/feature"
      end
      workspace.change_current_directory = function(pathname)
        switched_to = pathname
        active = true
      end
      worktree.is_active = function()
        return active
      end
      vim.wait = function(_, predicate)
        return predicate()
      end

      local result, err = git.worktree_switch(worktree)

      assert.are.equal(worktree, result)
      assert.is_nil(err)
      assert.are.equal("/repo/feature", switched_to)
    end)

    it("soft-fails when the worktree path does not exist", function()
      local worktree = Worktree.new({ name = "missing", path = "/repo/missing" })

      path.is_directory = function()
        return false
      end

      local result, err = git.worktree_switch(worktree)

      assert.is_nil(result)
      assert.are.equal("Can't switch to worktree that does not exist", err)
    end)
  end)
end)
