---@diagnostic disable: undefined-global
CONFIG {
    global = {
        -- 全局日志文件
        -- 特别的，可以设成stdout,stderr来输出到标准输出流和标准错误流
        -- 设为nil则不输出日志(处理上是输出到/dev/null)
        log_file = "lunabot.log",
        -- 日志级别
        log_level = "DEBUG",
    },

    -- bot实例配置
    bot = {
        -- bot日志文件，其中的{botname}会被替换成bot实例的名字(如果存在)
        log_file = "{botname}.log",
        -- 日志级别
        log_level = "DEBUG",
    }
}
