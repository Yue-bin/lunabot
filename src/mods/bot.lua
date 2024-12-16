--[[
    bot实例
--]]

local _M = {}
local base = _G

local log = require("mods.log")

-- bot的环境变量，初始化为空
_M.std = ""
_M.proto = ""
_M.version = ""
_M.name = ""
_M.is_init = false

-- bot的初始化
function _M:init(host, port, token)
    self.host = host
    self.port = port
    self.token = token
    self.is_init = true
end

return _M
