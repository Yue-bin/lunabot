local socket = require "socket"
local cqueues = require "cqueues"
local condition = require "cqueues.condition" -- 引入条件变量模块
local assert = assert

local _M = {}

function _M.attach(cq, timeout, callback)
    assert(cqueues.type(cq), "invalid cqueues instance")
    assert(timeout > 0, "timeout must be positive number")
    assert(type(callback) == "function", "callback must be function")

    local timer = {
        timeout = timeout,
        callback = callback,
        last_time = socket.gettime(),
        active = true,
        cv = condition.new() -- 使用 condition.new() 创建条件变量
    }

    timer.co = cq:wrap(function()
        while timer.active do
            local now = socket.gettime()
            local elapsed = now - timer.last_time

            if elapsed >= timer.timeout then
                pcall(timer.callback)
                timer.active = false
                return
            end

            local remaining = timer.timeout - elapsed
            timer.cv:wait(remaining) -- 条件变量等待
        end
    end)

    function timer.reset()
        if not timer.active then return false end
        timer.last_time = socket.gettime()
        timer.cv:signal() -- 使用 signal() 唤醒
        return true
    end

    function timer.cancel()
        if not timer.active then return false end
        timer.active = false
        timer.cv:signal() -- 使用 signal() 唤醒
        return true
    end

    function timer.status()
        if not timer.active then
            return false, 0
        end
        return true, socket.gettime() - timer.last_time
    end

    return timer
end

return _M
