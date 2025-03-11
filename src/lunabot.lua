local _M = {}

require("pl.app").require_here("src")
_M.logger = require("log").init()

_M.VERSION = "0.1.0"
_M.NAME = "lunabot"

function _M.new(info)
    local bot = { info = info }
    setmetatable(bot, { __index = _M })
    _M.logger:log("luna is here~")
    return bot
end

function _M:run()
    self.logger:log("luna is running!")
    local http_server = require "http.server"
    local http_headers = require "http.headers"
    local websocket = require "http.websocket"
    local socket = require "socket"
    local json = require "cjson"

    -- 创建 HTTP 服务器
    local server = http_server.listen {
        host = self.info.host,
        port = self.info.port,
        onstream = function(server, stream) -- 处理请求流
            local req_headers = stream:get_headers()
            local method = req_headers:get(":method")
            local path = req_headers:get(":path")
            local authorization = req_headers:get("authorization")
            print(authorization)
            if method == "GET" and path == self.info.path then
                if authorization == "Bearer " .. self.info.token then
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
                            if this_heartbeat - last_heartbeat > self.info.heartbeat_timeout then
                                print("心跳超时，关闭连接")
                                connection_alive = false
                                break
                            else
                                last_heartbeat = this_heartbeat
                            end
                        elseif msg_time - last_heartbeat > self.info.heartbeat_timeout then
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
        end,
    }

    print("WebSocket 服务器启动于 ws://" .. self.info.host .. ":" .. self.info.port .. self.info.path)
    assert(server:loop())
end

return _M
