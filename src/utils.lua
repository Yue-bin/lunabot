local _M = {}

-- 用于写入一个表的元表的某个项而不影响原有元表
function _M.setmt(table, key, value)
    local mt = getmetatable(table)
    if mt then
        mt[key] = value
        setmetatable(table, mt)
    else
        setmetatable(table, { [key] = value })
    end
    return table
end

-- 用于支持多个__index元表堆叠形成的环境

-- 自动将env在排除冲突的情况下设为table的最外层__index元表
function _M.add_env_outside(table, env)
    local mt = getmetatable(table)
    if mt and mt.__index then
        _M.add_env_outside(mt.__index, env)
    else
        _M.setmt(table, "__index", env)
    end
    return table
end

-- 自动将env在排除冲突的情况下设为table的最内层__index元表
function _M.add_env_inside(table, env)
    local mt = getmetatable(table)
    if mt and mt.__index then
        -- 把原有的__index元表堆叠到env的最外层
        _M.add_env_outside(mt.__index, env)
        _M.setmt(table, "__index", mt)
    else
        _M.setmt(table, "__index", env)
    end
    return table
end

-- 用于创造一个表的只读代理
function _M.readonly(table)
    return setmetatable({}, {
        __index = table,
        __newindex = function(_, _, _)
            error("Don`t touch me here...")
        end,
        __len = function()
            return #table
        end,
        -- __metatable = false
    })
end

-- 此函数用于将模块包装为使用一次性init的延迟加载函数
-- 用于避免模块加载时缺少元表依赖
function _M.pack_to_init(mod, late_load)
    mod.init = function()
        for k, v in pairs(late_load) do
            mod[k] = v
        end
        mod.init = nil
    end
    return mod
end

return _M
