--- lunabot
-- @module lunabot

local base = _G
local _M = {}

local pl_app = require("pl.app")
pl_app.require_here()

local log = require("mods.log")
local arg_parser = require("mods.arg.arg_parser")
local bot = require("mods.bot")
local utils = require("mods.utils")

--- 版本信息
-- @ VERSION 版本号
_M.VERSION = "0.1.0"

-- 全局变量

-- 局部变量
local config = {}
local g_log = nil
local is_init = false

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
        g_log:log("bot name: " .. info.name .. " std: " .. info.std .. " proto: " .. info.proto, "DEBUG")
        info.std = info.std or "onebot-11"
        info.proto = info.proto or "ws-reverse"
        local bot_instance = {}
        base.setmetatable(bot_instance, { __index = bot })
        bot_instance.std = info.std
        bot_instance.proto = info.proto
        bot_instance.version = _M.VERSION
        bot_instance.name = info.name
        bot_instance.config = config.bot
        g_log:log("new bot instance " .. info.name .. " created")
        return bot_instance
    else
        return nil, "lunabot not initialized"
    end
end

-- 模块导出
return function(config_file)
    -- 读取配置文件
    config = arg_parser.parse_config(config_file)

    -- 初始化全局日志
    g_log = log.init(config.global.log_file)
    g_log:setlevel(config.global.log_level)
    g_log:log("lunabot started")
    g_log:log("global log level set to " .. g_log.LOG_LEVEL)
    is_init = true
    return _M
end
