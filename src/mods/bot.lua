--[[
    bot实例
--]]

local _M = {}
local base = _G

local log = require("mods.log")

-- bot的环境变量，初始化为空
_M.std = ""
_M.proto = ""
_M.version = ""
_M.name = ""
_M.config = {}
_M.log = nil
_M.is_init = false



-- bot的初始化
function _M:init(host, port, token)
    local function CONFIG(config)
        -- 特别的，可以设成stdout,stderr来输出到标准输出流和标准错误流
        -- 设为nil则不输出日志(处理上是输出到/dev/null)
        if config.log_file == "stdout" then
            config.log_file = base.io.stdout
        elseif config.log_file == "stderr" then
            config.log_file = base.io.stderr
        elseif config.log_file == "nil" then
            config.log_file = base.io.open("/dev/null", "w")
        else
            -- bot日志文件，其中的{botname}会被替换成bot实例的名字(如果存在)
            ---@diagnostic disable-next-line: param-type-mismatch
            config.log_file = base.io.open(base.string.gsub(config.log_file, "{botname}", self.name), "a")
        end
        return config
    end
    self.config = CONFIG(self.config)
    ---@diagnostic disable-next-line: cast-local-type
    CONFIG = nil
    self.log = log.init(self.config.log_file)
    self.log:setlevel(self.config.log_level)
    self.log:log("bot " .. self.name .. " started")
    self.log:log("bot log level set to " .. self.log.LOG_LEVEL)
    self.log:log("bot init with host: " .. host .. " port: " .. port .. " token: " .. token, "DEBUG")
    self.host = host
    self.port = port
    self.token = token
    self:connect()
    self.is_init = true
end

-- 连接到实现端
function _M:connect()
    if self.proto == "websocket" then
    else
        base.error("unsupported protocol")
    end
end

return _M
