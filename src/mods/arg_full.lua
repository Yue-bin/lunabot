---@diagnostic disable: undefined-global

-- 配置文件和命令行参数的默认值以及命令行参数注册表
return {

    global = {
        log_file = "lunabot.log",
        log_level = log.loglevels.DEBUG,
    },
    bot = {
        log_file = "{botname}.log",
        log_level = log.loglevels.DEBUG,
    },

    -- 命令行参数注册表
    --[[
    cli_opts = {
        {

        }
    },
    --]]
}
