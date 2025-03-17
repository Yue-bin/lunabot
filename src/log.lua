local _M = {}

-- 日志相关
-- 搬了一点monlog
local loglevels = {
    TRACE = -1,
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

-- 日志前缀
_M.prefix = ""

-- 设置日志级别
function _M:setlevel(level)
    level = string.upper(level)
    if loglevels[level] ~= nil then
        _M.LOG_LEVEL = level
    else
        error("log level \"" .. level .. "\" is invalid")
    end
end

-- 输出日志
-- outputstream默认为stderr
-- level默认为INFO
function _M:log(msg, level)
    level = level or "INFO"
    if loglevels[level] >= loglevels[_M.LOG_LEVEL] then
        local prefix = self.prefix ~= "" and "<" .. self.prefix .. "> " or ""
        -- 使用outputstream输出日志
        self.outputstream:write(os.date("%Y.%m.%d-%H:%M:%S"), " [", level, "] ", prefix, msg, "\n")
    end
end

-- 初始化
local function init(stream, prefix)
    _M.outputstream = stream or io.stderr
    _M.prefix = prefix or ""
    return _M
end

return {
    init = init,
}
