local _M = {}
local base = _G

-- 用于写入一个表的元表的某个项而不影响原有元表
function _M.setmt(table, key, value)
    local mt = base.getmetatable(table)
    if mt then
        mt[key] = value
        base.setmetatable(table, mt)
    else
        base.setmetatable(table, { [key] = value })
    end
    return table
end

-- 用于支持多个__index元表堆叠形成的环境

-- 自动将env在排除冲突的情况下设为table的最外层__index元表
function _M.add_env_outside(table, env)
    local mt = base.getmetatable(table)
    if mt and mt.__index then
        _M.add_env_outside(mt.__index, env)
    else
        _M.setmt(table, "__index", env)
    end
    return table
end

-- 自动将env在排除冲突的情况下设为table的最内层__index元表
function _M.add_env_inside(table, env)
    local mt = base.getmetatable(table)
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
    return base.setmetatable({}, {
        __index = table,
        __newindex = function(_, _, _)
            base.error("Don`t touch me here...")
        end,
        __len = function()
            return #table
        end,
        -- __metatable = false
    })
end

function _M.table_has_val(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function _M.table_has_key(t, key)
    for k, _ in pairs(t) do
        if k == key then
            return true
        end
    end
    return false
end

return _M
