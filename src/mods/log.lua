local _M = {}
local base = _G

-- 日志相关
-- 搬了一点monlog
local loglevels = {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}

-- 默认日志级别
_M.LOG_LEVEL = "INFO"
-- LOG_LEVEL = "DEBUG"

-- 日志输出流
-- 未初始化无法使用
_M.outputstream = nil

local table_has_key = function(t, key)
    for k, _ in base.pairs(t) do
        if k == key then
            return true
        end
    end
    return false
end

-- 设置日志级别
function _M:setlevel(level)
    if table_has_key(loglevels, level) then
        _M.LOG_LEVEL = level
    else
        base.error("log level is invalid")
    end
end

-- 输出日志
-- outputstream默认为stderr
-- level默认为INFO
function _M:log(msg, level)
    level = level or "INFO"
    if loglevels[level] >= loglevels[_M.LOG_LEVEL] then
        -- 使用outputstream输出日志
        self.outputstream:write(base.os.date("%Y.%m.%d-%H:%M:%S"), " [", level, "] ", msg, "\n")
    end
end

-- 初始化
local function init(stream)
    _M.outputstream = stream or base.io.stderr
    return _M
end

return {
    init = init,
}
