--- lunabot
-- @module lunabot

local base = _G
local _M = {}

local log = require("mods.log")
local arg_parser = require("mods.arg_parser")
local bot = require("mods.bot")

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

-- 读取配置文件
local config = arg_parser.parse_config()

-- 初始化全局日志
local g_log = log.init(config.global.log_file)
g_log:setlevel(config.global.log_level)

function _M.set_config(filename)
    config = arg_parser.parse_config(filename)
end

-- bot工厂
--- 用于生成新的bot实例的工厂函数
-- 传入的泛型表包含以下字段
--  name bot实例的名字，或者uid之类的
--  std 使用的标准，默认为onebot-11
--  proto 使用的协议，默认为websocket
-- 返回值 bot lunabot实例
function _M.new(info)
    if info.std and not check_std(info.std) then
        return nil, "unsupported std"
    end
    if info.proto and not check_proto(info.proto) then
        return nil, "unsupported proto"
    end
    local bot_instance = bot.new(info)
    bot_instance.std = info.std or "onebot-11"
    bot_instance.proto = info.proto or "websocket"
    bot_instance.version = _M.VERSION
    bot_instance.name = info.name
    return bot_instance
end

-- 模块导出
return _M
