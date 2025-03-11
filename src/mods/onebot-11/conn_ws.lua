--[[
    这里是一个websocket的连接模块
    用于连接到实现端
--]]

local _M = {}
local base = _G



local ws = require("http.websocket")

function _M.new(host, port, token)
    ws.new_from_uri("ws://" .. host .. ":" .. port)
    ws:connect()
    
end

return _M
