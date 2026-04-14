describe("config.lib.icons", function()
  local original_icons_module
  local original_devicons_loaded
  local original_devicons_preload

  before_each(function()
    original_icons_module = package.loaded["config.lib.icons"]
    original_devicons_loaded = package.loaded["nvim-web-devicons"]
    original_devicons_preload = package.preload["nvim-web-devicons"]

    package.loaded["config.lib.icons"] = nil
    package.loaded["nvim-web-devicons"] = nil
    package.preload["nvim-web-devicons"] = function()
      error("forced devicons load failure", 0)
    end
  end)

  after_each(function()
    package.loaded["config.lib.icons"] = original_icons_module
    package.loaded["nvim-web-devicons"] = original_devicons_loaded
    package.preload["nvim-web-devicons"] = original_devicons_preload
  end)

  it("returns string fallbacks when devicons are unavailable", function()
    local icons = require("config.lib.icons")
    local icon, highlight = icons.get_file_icon("init.lua")

    assert.are.equal("", icon)
    assert.are.equal("", highlight)
    assert.are.equal("string", type(icon))
    assert.are.equal("string", type(highlight))
  end)
end)
