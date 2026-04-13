vim.loader.enable()

require("vim._core.ui2").enable({
  msg = {
    targets = {
      emsg = "msg",
      echoerr = "msg",
      lua_error = "msg",
      rpc_error = "msg",
    },
    msg = {
      timeout = 1200,
    },
  },
})

require("config")
