--- lunabot
-- @module lunabot

local base = _G
local _M = {}

local log = require("mods.log")

--初始化全局日志
local g_log = log.init()

--- 版本信息
-- @ VERSION 版本号
_M.VERSION = "0.1.0"

-- 全局变量
_M._SUPPORTED_STDS = {
    "onebot-11",
}

_M._SUPPORTED_PROTOS = {
    "websocket",
}

-- helper functions
local table_has_key = function(t, key)
    for k, _ in base.pairs(t) do
        if k == key then
            return true
        end
    end
    return false
end

local function check_std(std)
    return table_has_key(_M._SUPPORTED_STDS, std)
end

local function check_proto(proto)
    return table_has_key(_M._SUPPORTED_PROTOS, proto)
end

-- bot工厂
--- 用于生成新的bot实例的工厂函数
-- @string std 使用的标准，默认为onebot-11
-- @string proto 使用的协议，默认为websocket
-- @return bot lunabot实例
function _M.new(std, proto)
    local bot = {}
    if not check_std(std) then
        return nil, "unsupported std"
    end
    if not check_proto(proto) then
        return nil, "unsupported proto"
    end
    bot.std = std or "onebot-11"
    bot.proto = proto or "websocket"
    bot.version = _M.VERSION
    return bot
end

-- 模块导出
return _M
