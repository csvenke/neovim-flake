local notify = require("config.lib.notify")

describe("config.lib.notify", function()
  local calls
  local original_notify = vim.notify

  local function mock_notify(return_value)
    return function(msg, level, opts)
      table.insert(calls, { msg = msg, level = level, opts = opts })
      return return_value
    end
  end

  before_each(function()
    calls = {}
  end)

  after_each(function()
    vim.notify = original_notify
  end)

  describe("with_title", function()
    it("notifies with the bound title and INFO level by default", function()
      vim.notify = mock_notify()

      notify.with_title("Test")("hello")

      assert.are.equal(1, #calls)
      assert.are.equal("hello", calls[1].msg)
      assert.are.equal(vim.log.levels.INFO, calls[1].level)
      assert.are.same({ title = "Test" }, calls[1].opts)
    end)

    it("uses the given level", function()
      vim.notify = mock_notify()

      notify.with_title("Test")("oops", vim.log.levels.WARN)

      assert.are.equal(vim.log.levels.WARN, calls[1].level)
    end)
  end)

  describe("progress", function()
    it("shows a progress notification that never times out", function()
      vim.notify = mock_notify()

      notify.progress("Test", "Working...")

      assert.are.equal(1, #calls)
      assert.are.equal("Working...", calls[1].msg)
      assert.are.equal(vim.log.levels.INFO, calls[1].level)
      assert.are.same({ title = "Test", timeout = false }, calls[1].opts)
    end)

    it("done() replaces the progress notification with stem .. DONE", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...").done()

      assert.are.equal(2, #calls)
      assert.are.equal("Working... DONE", calls[2].msg)
      assert.are.equal(vim.log.levels.INFO, calls[2].level)
      assert.are.same({ title = "Test", replace = 42, timeout = 5000 }, calls[2].opts)
    end)

    it("done() accepts a custom message and level", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...").done("Working... cancelled", vim.log.levels.WARN)

      assert.are.equal("Working... cancelled", calls[2].msg)
      assert.are.equal(vim.log.levels.WARN, calls[2].level)
    end)

    it("fail() replaces with ERROR level by default", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...").fail("it broke")

      assert.are.equal("it broke", calls[2].msg)
      assert.are.equal(vim.log.levels.ERROR, calls[2].level)
    end)

    it("update() replaces with an arbitrary message", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...").update("Still working...")

      assert.are.equal("Still working...", calls[2].msg)
      assert.are.equal(vim.log.levels.INFO, calls[2].level)
      assert.are.same({ title = "Test", replace = 42, timeout = 5000 }, calls[2].opts)
    end)

    it("honors a custom timeout for terminal notifications", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...", { timeout = 1000 }).done()

      assert.are.equal(1000, calls[2].opts.timeout)
    end)

    it("honors timeout = false for terminal notifications", function()
      vim.notify = mock_notify({ id = 42 })

      notify.progress("Test", "Working...", { timeout = false }).done()

      assert.is_false(calls[2].opts.timeout)
    end)

    it("does not set replace when the initial notification has no id", function()
      vim.notify = mock_notify()

      notify.progress("Test", "Working...").done()

      assert.is_nil(calls[2].opts.replace)
    end)
  end)
end)
