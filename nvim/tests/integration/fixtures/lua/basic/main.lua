-- luacheck: globals missing_value

local greeter = {
  message = function()
    return "Hello from lua_ls"
  end,
}

print(greeter.message())
print(missing_value)
