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

-- 局部变量
local config = {}
local g_log = nil
local is_init = false

-- helper functions
local table_has_val = function(t, val)
    for _, v in base.pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

local function check_std(std)
    return table_has_val(_M._SUPPORTED_STDS, std)
end

local function check_proto(proto)
    return table_has_val(_M._SUPPORTED_PROTOS, proto)
end

function _M.init(config_file)
    -- 读取配置文件
    config = arg_parser.parse_config(config_file)

    -- 初始化全局日志
    g_log = log.init(config.global.log_file)
    g_log:setlevel(config.global.log_level)
    g_log:log("lunabot started")
    g_log:log("global log level set to " .. g_log.LOG_LEVEL)
    is_init = true
end

-- bot工厂
--- 用于生成新的bot实例的工厂函数
-- 传入的泛型表包含以下字段
--  name bot实例的名字，或者uid之类的
--  std 使用的标准，默认为onebot-11
--  proto 使用的协议，默认为websocket
-- 返回值 bot lunabot实例
function _M.new(info)
    if is_init then
        g_log:log("creating new bot instance")
        g_log:log("bot name: " .. info.name .. "bot std: " .. info.std .. "bot proto: " .. info.proto, "DEBUG")
        if info.std and not check_std(info.std) then
            g_log:log("failed with error unsupported std", "ERROR")
            return nil, "unsupported std"
        end
        if info.proto and not check_proto(info.proto) then
            g_log:log("failed with error unsupported proto", "ERROR")
            return nil, "unsupported proto"
        end
        local bot_instance = {}
        base.setmetatable(bot_instance, { __index = bot })
        bot_instance.std = info.std or "onebot-11"
        bot_instance.proto = info.proto or "websocket"
        bot_instance.version = _M.VERSION
        bot_instance.name = info.name
        g_log:log("new bot instance " .. info.name .. " created")
        return bot_instance
    else
        return nil, "lunabot not initialized"
    end
end

-- 模块导出
return _M
