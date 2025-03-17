local _M = {}

local utils = require("utils")
local http_server = require "http.server"
local http_headers = require "http.headers"
local websocket = require "http.websocket"
local socket = require "socket"
local json = require "cjson"
local cqueues = require "cqueues"

local logger = require("log").init(io.stderr, _ENV.config.name)
logger:log("bot instance created, name is " .. _ENV.config.name)

_M.socket_loop = http_server.listen {
    host = _ENV.config.socket.host,
    port = _ENV.config.socket.port,
    onstream = function(server, stream) -- 处理请求流
        local req_headers = stream:get_headers()
        local method = req_headers:get(":method")
        local path = req_headers:get(":path")
        local authorization = req_headers:get("authorization")
        print(authorization)
        if method == "GET" and path == _ENV.config.socket.path then
            if authorization == "Bearer " .. _ENV.config.socket.token then
                -- 处理 WebSocket 握手
                local ws = websocket.new_from_stream(stream, req_headers)
                ws:accept()                             -- 接受 WebSocket 连接
                local last_heartbeat = socket.gettime() -- 记录最后心跳时间
                local connection_alive = true

                -- 在 WebSocket 上发送和接收消息
                while connection_alive do
                    local msg, opcode = ws:receive()
                    local msg_time = socket.gettime()
                    local res = json.decode(msg)
                    if not msg then
                        connection_alive = false
                        break
                    elseif res and res.post_type == "meta_event" and res.meta_event_type == "heartbeat" then
                        print("收到心跳包")
                        local this_heartbeat = msg_time
                        if this_heartbeat - last_heartbeat > _ENV.config.socket.heartbeat_timeout then
                            print("心跳超时，关闭连接")
                            connection_alive = false
                            break
                        else
                            last_heartbeat = this_heartbeat
                        end
                    elseif msg_time - last_heartbeat > _ENV.config.socket.heartbeat_timeout then
                        print("心跳超时，关闭连接")
                        connection_alive = false
                        break
                    else
                        -- 这样不行，连接断开不应该依赖于连接本身的消息
                    end
                    print("收到消息:", msg)
                    if res and res.post_type == "heartbeat" then
                        last_heartbeat = socket.gettime() -- 更新心跳时间
                        print("收到心跳包")
                    elseif res and res.post_type == "message" and res.message[1].data.text == "你好" then
                        print("发送消息: pong!")
                        ws:send(json.encode({
                            action = "send_private_msg",
                            params = {
                                user_id = res.user_id,
                                message = res.sender.nickname .. "你好呀"
                            },
                            echo = 123
                        }))
                    end
                end
                ws:close()
            else
                -- 对无鉴权请求发送错误
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
    end,
}

_M.is_running = false

_M.main_loop = cqueues.new()
_M.main_loop:wrap(function()
    print("main_loop start")
    while _M.is_running do
        -- 通过cqueues.poll监听子控制器的文件描述符和事件
        local ready = { cqueues.poll(_M.socket_loop) }
        if #ready > 0 then
            -- 子控制器有事件时，执行其事件循环
            _M.socket_loop:step(0) -- 立即处理事件（非阻塞）
        end
        print("step")
    end
end)


return utils.setmt(_M, "__name", _ENV.config.name)
