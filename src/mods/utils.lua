--[[
    一些各种各样应该与具体模块解耦的helper function
--]]
local _M = {}

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
