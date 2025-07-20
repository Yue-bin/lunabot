local queue_pool = {}

local cqueues = require("cqueues")
local utils = require("utils")

-- 添加子队列
function queue_pool:add(child)
    assert(cqueues.type(child), "invalid cqueues instance")
    table.insert(self.children, child)
end

-- 移除子队列
function queue_pool:remove(child)
    assert(cqueues.type(child), "invalid cqueues instance")
    for i, v in ipairs(self.children) do
        if v == child then
            table.remove(self.children, i)
            return true
        end
    end
    return false -- 如果没有找到子队列，则返回 false
end

local function run_childs(children)
    local active = {}
    for _, child in ipairs(children) do
        if not child:empty() then
            table.insert(active, child)
        end
    end

    if #active == 0 then return end

    local ready = { cqueues.poll(table.unpack(active)) }
    for _, child in ipairs(ready) do
        child:step(0)
    end
end

local function main_loop(pool)
    run_childs(pool.children)
end

local function new()
    local pool = {
        children = {},          -- 子队列列表
        parent = cqueues.new(), -- 父队列
    }
    pool.parent:wrap(function()
        while true do
            main_loop(pool)
        end
    end)
    return utils.add_env_outside(utils.add_env_inside(pool, queue_pool), pool.parent)
end

return { new }
