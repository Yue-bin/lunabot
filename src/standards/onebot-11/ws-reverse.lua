--[[
    ws-reverse方式的连接模块
]]

local _M = {}

local http_server = require "http.server"
local http_headers = require "http.headers"
local websocket = require "http.websocket"
local uuid = require "uuid"
local json = require "cjson"

local resp_handler = require "utils.resp-handler"
local utils = require "utils"

local _SERVER_INFO = {
    host = "",
    port = 0,
    path = "",
    heartbeat_timeout = 5,
    token = nil,
}

local _EVENT_TYPE = {
    message = "message",
    meta = "meta_event",
    notice = "notice",
    request = "request",
}

local _CALLBACKS = {
    onmessage = function(msg) end,
    onmeta = function(msg) end,
    onnotice = function(msg) end,
    onrequest = function(msg) end,
    onresp = function(msg) end,
}

local timer = nil
local ws = nil

local function onstream(server, stream)
    local req_headers = stream:get_headers()
    local method = req_headers:get(":method")
    local path = req_headers:get(":path")
    local authorization = req_headers:get("authorization")
    print(authorization)
    if method == "GET" and path == _SERVER_INFO.path then
        if authorization == "Bearer " .. _SERVER_INFO.token then
            -- 处理 WebSocket 握手
            ws = websocket.new_from_stream(stream, req_headers)
            ws:accept() -- 接受 WebSocket 连接

            -- 在 WebSocket 上发送和接收消息
            local connection_alive = true
            while connection_alive do
                -- 处理消息并进行最基本的验证
                local msg, opcode = ws:receive()
                if not msg then
                    connection_alive = false
                end
                local res = json.decode(msg)
                if not res then
                    print("接收到无效的消息:", msg)
                    break
                end

                -- 检查action返回
                if res.echo then
                    resp_handler.add_resp(res.echo, res)
                    _CALLBACKS.onresp(res)
                    goto continue_loop
                end

                print("接收到消息:", msg)
                if not utils.table_has_val(_EVENT_TYPE, res.post_type) then
                    print("接收到未知的事件类型:", res.post_type)
                    goto continue_loop
                end

                -- 在这里处理各种事件类型
                print("收到事件类型:", res.post_type)
                if res and res.post_type == _EVENT_TYPE.meta then
                    -- 处理心跳包
                    if timer and res.post_type == _EVENT_TYPE.meta and res.meta_event_type == "heartbeat" then
                        timer.reset()
                        print("收到心跳包")
                    end
                    _CALLBACKS.onmeta(res)
                elseif res and res.post_type == _EVENT_TYPE.message then
                    _CALLBACKS.onmessage(res)
                elseif res and res.post_type == _EVENT_TYPE.notice then
                    _CALLBACKS.onnotice(res)
                elseif res and res.post_type == _EVENT_TYPE.request then
                    _CALLBACKS.onrequest(res)
                end
                ::continue_loop::
            end
            print("WebSocket 连接已关闭")
            ws:close()
        else
            -- 对非 WebSocket 请求发送错误
            local res_headers = http_headers.new()
            res_headers:append(":status", "401")
            stream:write_headers(res_headers, true)
        end
    else
        -- 对非 WebSocket 请求发送错误
        local res_headers = http_headers.new()
        res_headers:append(":status", "400")
        stream:write_headers(res_headers, true)
    end
end
local onstream_wrap = function(server, stream)
    local ok, err = pcall(onstream, server, stream)
    if not ok then
        print("处理流时发生错误:", err)
        -- 这里可以添加错误处理逻辑
        local res_headers = http_headers.new()
        res_headers:append(":status", "500")
        stream:write_headers(res_headers, true)
    end
end
local function onerror(server, err)
    print("服务器错误:", err)
    -- 这里可以添加错误处理逻辑
end

-- 用户可以执行的操作
local actions = {}

function actions.send(msg)
    if not ws then
        print("WebSocket 连接未建立，无法发送消息")
        return
    end
    local msg_uuid = uuid.v4()
    msg.echo = msg.echo or msg_uuid
    print("发送消息:", json.encode(msg))
    ws:send(json.encode(msg))
    return msg_uuid
end

-- 创建 HTTP 服务器
local function create_server()
    local server = http_server.listen {
        host = _SERVER_INFO.host,
        port = _SERVER_INFO.port,
        onstream = onstream_wrap,
        onerror = onerror,
    }
    -- 加入超时处理
    if _SERVER_INFO.heartbeat_timeout > 0 then
        timer = require "utils.timer".attach(server.cq, _SERVER_INFO.heartbeat_timeout, function()
            print("心跳超时，关闭服务器")
            server:close()
        end)
    end
    return server
end

function _M.new(host, port, path, token, heartbeat_timeout, callbacks)
    _SERVER_INFO.host = host
    _SERVER_INFO.port = port
    _SERVER_INFO.path = path
    _SERVER_INFO.token = token
    _SERVER_INFO.heartbeat_timeout = heartbeat_timeout
    _CALLBACKS = callbacks
    uuid.set_rng(uuid.rng.urandom())
    return {
        server = create_server(),
        actions = actions,
    }
end

return _M
