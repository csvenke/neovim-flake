local text = require("config.lib.text")

describe("config.lib.text", function()
  describe("pad_right", function()
    it("pads string to specified width", function()
      assert.are.equal("foo   ", text.pad_right("foo", 6))
    end)

    it("returns string unchanged when already at width", function()
      assert.are.equal("foo", text.pad_right("foo", 3))
    end)

    it("returns string unchanged when longer than width", function()
      assert.are.equal("foobar", text.pad_right("foobar", 3))
    end)

    it("handles empty string", function()
      assert.are.equal("   ", text.pad_right("", 3))
    end)

    it("handles zero width", function()
      assert.are.equal("foo", text.pad_right("foo", 0))
    end)
  end)

  describe("pad_left", function()
    it("pads string to specified width", function()
      assert.are.equal("   foo", text.pad_left("foo", 6))
    end)

    it("returns string unchanged when already at width", function()
      assert.are.equal("foo", text.pad_left("foo", 3))
    end)

    it("returns string unchanged when longer than width", function()
      assert.are.equal("foobar", text.pad_left("foobar", 3))
    end)

    it("handles empty string", function()
      assert.are.equal("   ", text.pad_left("", 3))
    end)

    it("handles zero width", function()
      assert.are.equal("foo", text.pad_left("foo", 0))
    end)
  end)
end)
