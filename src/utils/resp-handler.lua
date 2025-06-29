local _M = {}

local resp_table = setmetatable({}, { __mode = "v" })

function _M.add_resp(uuid, resp)
    resp_table[uuid] = resp
end

function _M.get_resp(uuid, clean_cache)
    clean_cache = clean_cache or false
    local resp = resp_table[uuid]
    if clean_cache then
        resp_table[uuid] = nil -- 清除已获取的响应
    end
    return resp
end

return _M
