local Path = require("config.lib.path")

describe("config.lib.path", function()
  local paths = {}

  local function remember(path)
    table.insert(paths, path)
    return path
  end

  after_each(function()
    for _, path in ipairs(paths) do
      pcall(vim.fn.delete, path, "rf")
    end
    paths = {}
  end)

  it("distinguishes files from directories", function()
    local directory = remember(vim.fn.tempname())
    local file = directory .. "/sample.txt"

    vim.fn.mkdir(directory, "p")
    vim.fn.writefile({ "hello" }, file)

    assert.is_true(Path.is_directory(directory))
    assert.is_false(Path.is_file(directory))
    assert.is_true(Path.is_file(file))
    assert.is_false(Path.is_directory(file))
  end)

  it("copies directory contents into an existing destination", function()
    local source = remember(vim.fn.tempname())
    local destination = remember(vim.fn.tempname())
    local copied_file = destination .. "/nested/file.txt"

    vim.fn.mkdir(source .. "/nested", "p")
    vim.fn.mkdir(destination, "p")
    vim.fn.writefile({ "copied" }, source .. "/nested/file.txt")

    Path.copy_directory(source, destination)
    vim.wait(1000, function()
      return Path.is_file(copied_file)
    end)

    assert.are.same({ "copied" }, vim.fn.readfile(copied_file))
  end)
end)
