--[[
    onebot-11 的导出模块
]]

local _M = {}

local utils = require("utils")

_M._SUPPORTED_PROTOS = {
    "ws",
    "ws-reverse",
    "http",
}

function _M.new(info)
    if not info then
        return nil, "did you forget sth?"
    end
    if not info.proto then
        return nil, "no proto specified"
    end
    if utils.table_has_val(_M._SUPPORTED_PROTOS, info.proto) then
        return nil, "unsupported proto"
    end
    if not (info.host and info.port) then
        return nil, "no host and port specified"
    end
    local proto = require("standards.onebot-11." .. info.proto)
    return proto.new(
        info.host,
        info.port,
        info.path,
        info.token,
        info.heartbeat_timeout or 5
    )
end

return _M
