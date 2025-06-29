local socket = require "socket"
local cqueues = require "cqueues"
local assert = assert

local _M = {}

-- 将超时管理器附加到现有 cqueues 对象
function _M.attach(cq, timeout, callback)
    assert(type(cq) == "table" and cq.wrap, "invalid cqueues instance")
    assert(timeout > 0, "timeout must be positive number")
    assert(type(callback) == "function", "callback must be function")

    local timer = {
        timeout = timeout,
        callback = callback,
        last_time = socket.gettime(),
        active = true,
        cv = cqueues.condvar()
    }

    -- 创建控制协程并加入队列
    timer.co = cq:wrap(function()
        while timer.active do
            local now = socket.gettime()
            local elapsed = now - timer.last_time

            if elapsed >= timer.timeout then
                pcall(timer.callback)
                timer.active = false
                return
            end

            -- 等待剩余时间或外部信号
            local remaining = timer.timeout - elapsed
            timer.cv:wait(remaining)
        end
    end)

    -- 重置函数
    function timer.reset()
        if not timer.active then return false end
        timer.last_time = socket.gettime()
        timer.cv:signal() -- 唤醒协程更新计时
        return true
    end

    -- 取消函数
    function timer.cancel()
        if not timer.active then return false end
        timer.active = false
        timer.cv:signal()
        return true
    end

    -- 状态查询
    function timer.status()
        if not timer.active then
            return false, 0
        end
        return true, socket.gettime() - timer.last_time
    end

    -- 返回控制器对象
    return timer
end

return _M
