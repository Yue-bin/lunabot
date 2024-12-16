local _M = {}
local base = _G

-- 日志相关
-- 搬了一点monlog
_M.loglevels = {
    [0] = "DEBUG",
    [1] = "INFO",
    [2] = "WARN",
    [3] = "ERROR",
    [4] = "FATAL",
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}
local loglevelmax = 4
local loglevelmin = 0

-- 默认日志级别
_M.LOG_LEVEL = _M.loglevels.INFO
-- LOG_LEVEL = loglevels.DEBUG

-- 日志输出流
-- 未初始化无法使用
_M.outputstream = nil

-- 设置日志级别
function _M:setlevel(level)
    self.LOG_LEVEL = level
end

-- 输出日志
-- outputstream默认为stderr
-- level默认为INFO
function _M:log(msg, level)
    level = level or _M.loglevels.INFO
    base.assert((level >= loglevelmin and level <= loglevelmax), "log level is invalid")
    if level >= _M.LOG_LEVEL then
        -- 使用outputstream输出日志
        self.outputstream:write(base.os.date("%Y.%m.%d-%H:%M:%S"), " [", _M.loglevels[level], "] ", msg, "\n")
    end
end

-- 初始化
local function init(stream)
    _M.outputstream = stream or base.io.stderr
    return _M
end

return {
    init = init,
    loglevels = _M.loglevels,
}
