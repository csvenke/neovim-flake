describe("config.lib.osc7", function()
  local osc7 = require("config.lib.osc7")

  describe("build", function()
    it("wraps a plain path in an OSC 7 sequence", function()
      assert.are.equal("\27]7;file:///home/user/repo\27\\", osc7.build("/home/user/repo"))
    end)

    it("keeps unreserved characters", function()
      assert.are.equal("\27]7;file:///a-b_c.d~e\27\\", osc7.build("/a-b_c.d~e"))
    end)

    it("encodes spaces and percent signs", function()
      assert.are.equal("\27]7;file:///my%20dir/100%25\27\\", osc7.build("/my dir/100%"))
    end)

    it("encodes non-ASCII bytes", function()
      assert.are.equal("\27]7;file:///caf%C3%A9\27\\", osc7.build("/café"))
    end)
  end)
end)
