local Worktree = require("config.lib.worktree")

describe("config.lib.worktree", function()
  describe("from_entry", function()
    it("parses worktree path and derives name from last path segment", function()
      local entry = [[worktree /home/user/repo/main
HEAD abc123def456789012345678901234567890abcd
branch refs/heads/main]]
      local wt = Worktree.from_entry(entry)

      assert.are.equal("/home/user/repo/main", wt.path)
      assert.are.equal("main", wt.name)
    end)

    it("parses commit sha and provides shortened version", function()
      local entry = [[worktree /home/user/repo/main
HEAD abc123def456789012345678901234567890abcd
branch refs/heads/main]]
      local wt = Worktree.from_entry(entry)

      assert.are.equal("abc123def456789012345678901234567890abcd", wt.sha)
      assert.are.equal("abc123d", wt.short_sha)
    end)

    it("strips refs/heads/ prefix from branch name", function()
      local entry = [[worktree /home/user/repo/feature
HEAD abc123def456789012345678901234567890abcd
branch refs/heads/feature/my-feature]]
      local wt = Worktree.from_entry(entry)

      assert.are.equal("feature/my-feature", wt.branch)
    end)

    it("detects bare worktree", function()
      local entry = [[worktree /home/user/repo
bare]]
      local wt = Worktree.from_entry(entry)

      assert.is_true(wt.bare)
    end)

    it("detects detached HEAD state", function()
      local entry = [[worktree /home/user/repo/detached-wt
HEAD abc123def456789012345678901234567890abcd
detached]]
      local wt = Worktree.from_entry(entry)

      assert.is_true(wt.detached)
      assert.is_nil(wt.branch)
    end)

    it("detects locked and prunable states", function()
      local entry = [[worktree /home/user/repo/stale-wt
HEAD abc123def456789012345678901234567890abcd
detached
locked
prunable]]
      local wt = Worktree.from_entry(entry)

      assert.is_true(wt.locked)
      assert.is_true(wt.prunable)
    end)

    it("handles paths containing spaces", function()
      local entry = [[worktree /home/user/my repo/feature branch
HEAD abc123def456789012345678901234567890abcd
branch refs/heads/main]]
      local wt = Worktree.from_entry(entry)

      assert.are.equal("/home/user/my repo/feature branch", wt.path)
      assert.are.equal("feature branch", wt.name)
    end)
  end)

  describe("to_display_string", function()
    it("includes name, sha, and branch in output", function()
      local wt = Worktree.new({
        name = "main",
        short_sha = "abc123d",
        branch = "main",
      })
      local display = wt:to_display_string(10, 12)

      assert.is_truthy(display:find("main", 1, true))
      assert.is_truthy(display:find("abc123d", 1, true))
    end)

    it("shows detached HEAD indicator when detached", function()
      local wt = Worktree.new({
        name = "wt",
        short_sha = "abc123d",
        detached = true,
      })
      local display = wt:to_display_string(10, 20)

      assert.is_truthy(display:find("detached HEAD", 1, true))
    end)

    it("shows locked indicator when locked", function()
      local wt = Worktree.new({
        name = "wt",
        short_sha = "abc123d",
        branch = "feature",
        locked = true,
      })
      local display = wt:to_display_string(10, 12)

      assert.is_truthy(display:find("locked", 1, true))
    end)

    it("shows prunable indicator when prunable", function()
      local wt = Worktree.new({
        name = "wt",
        short_sha = "abc123d",
        branch = "feature",
        prunable = true,
      })
      local display = wt:to_display_string(10, 12)

      assert.is_truthy(display:find("prunable", 1, true))
    end)
  end)
end)
