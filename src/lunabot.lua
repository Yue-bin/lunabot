-- 此模块为lunabot工厂模块，用于创建lunabot实例和存储一些常量

local _M = {}


require("pl.app").require_here("src")
local utils = require("utils")
_M.logger = require("log").init()

_M.VERSION = "0.1.0"
_M.NAME = "lunabot"

function _M.new(config)
    _M.logger:log("luna is here~")
    local env = {
        logger = _M.logger,
        VERSION = _M.VERSION,
        NAME = _M.NAME,
        config = config,
    }
    local bot_ins = loadfile("src/bot.lua", "t", utils.add_env_outside(env, _ENV))()
    -- 继承除了new之外的所有属性
    --[[
    setmetatable(bot_ins, {
        __index = env,
    })
    bot_ins:init()
    --]]
    --[[
    utils.add_env_outside(bot_ins, {
        logger = _M.logger,
        VERSION = _M.VERSION,
        NAME = _M.NAME,
        config = config,
    })
    --]]
    return bot_ins
end

return utils.setmt(
    utils.readonly(_M),
    "__name",
    "lunabot")
