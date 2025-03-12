-- 此模块为lunabot工厂模块，用于创建lunabot实例和存储一些常量

local _M = {}


require("pl.app").require_here("src")
local utils = require("utils")
_M.logger = require("log").init()

_M.VERSION = "0.1.0"
_M.NAME = "lunabot"

function _M.new(config)
    local bot_ins = { config = config }
    setmetatable(bot_ins, { __index = _M })
    _M.logger:log("luna is here~")
    return bot_ins
end

return utils.setmt(
    utils.readonly(_M),
    "__name",
    "lunabot")
