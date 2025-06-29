--[[
    ws-reverse方式的连接模块
]]

local _M = {}

local http_server = require "http.server"
local http_headers = require "http.headers"
local websocket = require "http.websocket"
local socket = require "socket"
local json = require "cjson"

local _SERVER_INFO = {
    host = "",
    port = 0,
    path = "",
    heartbeat_timeout = 5,
    token = nil,
}

local _EVENT_TYPE = {
    "message",
    "meta_event",
    "notice",
    "request",
}

local timer = nil

local function onstream(server, stream)
    local req_headers = stream:get_headers()
    local method = req_headers:get(":method")
    local path = req_headers:get(":path")
    local authorization = req_headers:get("authorization")
    print(authorization)
    if method == "GET" and path == _SERVER_INFO.path then
        if authorization == "Bearer " .. _SERVER_INFO.token then
            -- 处理 WebSocket 握手
            local ws = websocket.new_from_stream(stream, req_headers)
            ws:accept() -- 接受 WebSocket 连接

            -- 在 WebSocket 上发送和接收消息
            local connection_alive = true
            while connection_alive do
                local msg, opcode = ws:receive()
                local msg_time = socket.gettime()
                local res = json.decode(msg)
                if not msg then
                    connection_alive = false
                    -- 在这里处理各种事件类型
                    if res and res.post_type == "heartbeat" then
                        timer.reset() -- 更新心跳时间
                        print("收到心跳包")
                    elseif res and res.post_type == "message" and res.message[1].data.text == "ping" then
                        print("发送消息: pong!")
                        ws:send(json.encode({
                            action = "send_private_msg",
                            params = {
                                user_id = res.user_id,
                                message = "pong!"
                            },
                            echo = 123
                        }))
                    end
                end
            end
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

local function onerror(server, err)
    print("服务器错误:", err)
    -- 这里可以添加错误处理逻辑
end

-- 创建 HTTP 服务器
local function create_server()
    local server = http_server.listen {
        host = _SERVER_INFO.host,
        port = _SERVER_INFO.port,
        onstream = onstream,
        onerror = onerror,
    }
    -- 加入超时处理
    if _SERVER_INFO.heartbeat_timeout > 0 then
        timer = require "mods.utils.timer".attach(server, _SERVER_INFO.heartbeat_timeout, function()
            print("心跳超时，关闭服务器")
            server:close()
        end)
    end
    return server
end

function _M.new(host, port, path, token, heartbeat_timeout)
    _SERVER_INFO.host = host
    _SERVER_INFO.port = port
    _SERVER_INFO.path = path
    _SERVER_INFO.token = token
    _SERVER_INFO.heartbeat_timeout = heartbeat_timeout
    return create_server()
end

return _M
