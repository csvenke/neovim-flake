-- Tests for Worktree class

local Worktree = require("git-worktree.worktree")

describe("Worktree", function()
  describe("new", function()
    it("should create a worktree with default values", function()
      local wt = Worktree.new({})
      assert.equals("", wt.name)
      assert.equals("", wt.path)
      assert.equals("0000000000000000000000000000000000000000", wt.sha)
      assert.equals("0000000", wt.short_sha)
      assert.is_nil(wt.branch)
      assert.is_false(wt.bare)
      assert.is_false(wt.detached)
      assert.is_false(wt.locked)
      assert.is_false(wt.prunable)
      assert.equals("", wt.display)
    end)

    it("should create a worktree with provided values", function()
      local wt = Worktree.new({
        name = "feature-branch",
        path = "/home/user/project/feature-branch",
        sha = "abc123def456",
        short_sha = "abc123d",
        branch = "feature-branch",
        bare = false,
        detached = false,
        locked = false,
        prunable = false,
      })
      assert.equals("feature-branch", wt.name)
      assert.equals("/home/user/project/feature-branch", wt.path)
      assert.equals("abc123def456", wt.sha)
      assert.equals("abc123d", wt.short_sha)
      assert.equals("feature-branch", wt.branch)
      assert.is_false(wt.bare)
      assert.is_false(wt.detached)
      assert.is_false(wt.locked)
      assert.is_false(wt.prunable)
    end)
  end)

  describe("from_entry", function()
    it("should parse a basic worktree entry", function()
      local entry = [[worktree /home/user/project/main
HEAD abc123def456789abc123def456789abc123def
branch refs/heads/main]]

      local wt = Worktree.from_entry(entry)
      assert.equals("main", wt.name)
      assert.equals("/home/user/project/main", wt.path)
      assert.equals("abc123def456789abc123def456789abc123def", wt.sha)
      assert.equals("abc123d", wt.short_sha)
      assert.equals("main", wt.branch)
      assert.is_false(wt.bare)
      assert.is_false(wt.detached)
    end)

    it("should parse a bare worktree entry", function()
      local entry = [[worktree /home/user/project/.git
HEAD abc123def456789abc123def456789abc123def
bare]]

      local wt = Worktree.from_entry(entry)
      assert.equals(".git", wt.name)
      assert.equals("/home/user/project/.git", wt.path)
      assert.is_true(wt.bare)
      assert.is_nil(wt.branch)
    end)

    it("should parse a detached worktree entry", function()
      local entry = [[worktree /home/user/project/detached
HEAD abc123def456789abc123def456789abc123def
detached]]

      local wt = Worktree.from_entry(entry)
      assert.equals("detached", wt.name)
      assert.is_true(wt.detached)
      assert.is_nil(wt.branch)
    end)

    it("should parse a locked worktree entry", function()
      local entry = [[worktree /home/user/project/locked
HEAD abc123def456789abc123def456789abc123def
branch refs/heads/locked
locked]]

      local wt = Worktree.from_entry(entry)
      assert.equals("locked", wt.name)
      assert.equals("locked", wt.branch)
      assert.is_true(wt.locked)
    end)

    it("should parse a prunable worktree entry", function()
      local entry = [[worktree /home/user/project/prunable
HEAD abc123def456789abc123def456789abc123def
branch refs/heads/prunable
prunable]]

      local wt = Worktree.from_entry(entry)
      assert.equals("prunable", wt.name)
      assert.is_true(wt.prunable)
    end)
  end)

  describe("to_display_string", function()
    it("should format worktree for display", function()
      local wt = Worktree.new({
        name = "main",
        path = "/home/user/project/main",
        short_sha = "abc123d",
        branch = "main",
      })

      local display = wt:to_display_string(10, 10, { worktree = "" })
      assert.is_string(display)
      assert.is_truthy(display:find("main"))
      assert.is_truthy(display:find("abc123d"))
    end)

    it("should show detached HEAD", function()
      local wt = Worktree.new({
        name = "test",
        path = "/home/user/project/test",
        short_sha = "def4567",
        detached = true,
      })

      local display = wt:to_display_string(10, 20, { worktree = "" })
      assert.is_truthy(display:find("detached HEAD"))
    end)

    it("should show locked status", function()
      local wt = Worktree.new({
        name = "locked",
        path = "/home/user/project/locked",
        short_sha = "abc1234",
        branch = "locked",
        locked = true,
      })

      local display = wt:to_display_string(10, 10, { worktree = "" })
      assert.is_truthy(display:find("locked"))
    end)

    it("should show prunable status", function()
      local wt = Worktree.new({
        name = "old",
        path = "/home/user/project/old",
        short_sha = "xyz7890",
        branch = "old",
        prunable = true,
      })

      local display = wt:to_display_string(10, 10, { worktree = "" })
      assert.is_truthy(display:find("prunable"))
    end)
  end)

  describe("is_active", function()
    it("should return true when path matches cwd", function()
      local wt = Worktree.new({
        name = "current",
        path = vim.fn.getcwd(),
      })
      assert.is_true(wt:is_active())
    end)

    it("should return false when path does not match cwd", function()
      local wt = Worktree.new({
        name = "other",
        path = "/some/other/path",
      })
      assert.is_false(wt:is_active())
    end)
  end)
end)
