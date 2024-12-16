--[[
    用于解析配置文件和命令行参数的模块
    设计上：
        1.本模块从arg_full.lua中获得一份完整的参数列表和其默认值
        2.  从命令行参数中解析出参数列表(若使用了命令行参数)
            从配置文件中读取参数列表(若使用了配置文件)
        3.以arg_full.lua中的参数列表为基准，将解析出的参数列表与默认值合并
        4.返回合并后的参数列表
    考虑到命令行参数的解析需要一份参数和选项对应的注册表，所以将这个注册表放在arg_full.lua中返回的config的cli_opts中
    命令行参数读取的实现使用argparse库

    思索了一下，目前好像不需要对命令行参数进行读取，因为我完全找不到在哪里塞命令行交互
--]]

local base = _G
local _M = {}

--local argparse = require("argparse")
local json = require("cjson")
local arg_full = require("mods.arg_full")

--[[
function _M.parse_cmdline()
    local parser = argparse()
    local config = arg_full.config
    for _, v in base.pairs(config.cli_opts) do
        parser:flag(v[1], v[2], v[3])
    end
    local args = parser:parse()
    return args
end
--]]

-- 递归地合并两个table到t2, t2中的值会覆盖t1中的值，即t1为默认值
local function merge_table(t1, t2)
    for k, v in base.pairs(t1) do
        if base.type(v) == "table" then
            if t2[k] == nil then
                t2[k] = {}
            end
            merge_table(v, t2[k])
        else
            t2[k] = v
        end
    end
end


function _M.parse_config(config_file)
    config_file = config_file
        or base.os.getenv("LUNABOT_CONFIG")
        or "config.lua"
        or "config.json"
    local parsed_config = {}
    -- 选择性地导入配置文件
    function CONFIG(config)
        merge_table(config, parsed_config)
    end

    if string.find(config_file, ".json$") then
        -- 若为json文件，则使用json库
        local f = base.io.open(config_file, "r")
        if not f then
            CONFIG({})
        else
            local config_str = f:read("*a")
            f:close()
            local config = json.decode(config_str)
            CONFIG(config)
        end
    else
        -- 若不为json文件，则使用lua的dofile函数
        if not pcall(function() dofile(config_file) end) then
            CONFIG({})
        end
    end
    CONFIG = nil
    return parsed_config
end

return _M
