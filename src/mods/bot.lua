--[[
    bot实例
--]]

local _M = {}
local base = _G

-- bot的环境变量，初始化为空
_M.std = ""
_M.proto = ""
_M.version = ""
_M.name = ""

local log = require("log")

