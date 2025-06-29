local ob11_api = {}

-- 发送私聊消息
function ob11_api:send_private_msg(user_id, message, auto_escape)
    return self.send({
        action = "send_private_msg",
        params = {
            user_id = user_id,
            message = message,
            auto_escape = auto_escape
        }
    })
end

-- 发送群消息
function ob11_api:send_group_msg(group_id, message, auto_escape)
    return self.send({
        action = "send_group_msg",
        params = {
            group_id = group_id,
            message = message,
            auto_escape = auto_escape
        }
    })
end

-- 发送消息
function ob11_api:send_msg(message_type, user_id, group_id, message, auto_escape)
    local params = { message = message }
    if message_type then params.message_type = message_type end
    if user_id then params.user_id = user_id end
    if group_id then params.group_id = group_id end
    if auto_escape ~= nil then params.auto_escape = auto_escape end

    return self.send({
        action = "send_msg",
        params = params
    })
end

-- 撤回消息
function ob11_api:delete_msg(message_id)
    return self.send({
        action = "delete_msg",
        params = {
            message_id = message_id
        }
    })
end

-- 获取消息
function ob11_api:get_msg(message_id)
    return self.send({
        action = "get_msg",
        params = {
            message_id = message_id
        }
    })
end

-- 获取合并转发消息
function ob11_api:get_forward_msg(id)
    return self.send({
        action = "get_forward_msg",
        params = {
            id = id
        }
    })
end

-- 发送好友赞
function ob11_api:send_like(user_id, times)
    times = times or 1
    return self.send({
        action = "send_like",
        params = {
            user_id = user_id,
            times = times
        }
    })
end

-- 群组踢人
function ob11_api:set_group_kick(group_id, user_id, reject_add_request)
    reject_add_request = reject_add_request or false
    return self.send({
        action = "set_group_kick",
        params = {
            group_id = group_id,
            user_id = user_id,
            reject_add_request = reject_add_request
        }
    })
end

-- 群组单人禁言
function ob11_api:set_group_ban(group_id, user_id, duration)
    duration = duration or (30 * 60)
    return self.send({
        action = "set_group_ban",
        params = {
            group_id = group_id,
            user_id = user_id,
            duration = duration
        }
    })
end

-- 群组匿名用户禁言
function ob11_api:set_group_anonymous_ban(group_id, anonymous, flag, duration)
    duration = duration or (30 * 60)
    local params = {
        group_id = group_id,
        duration = duration
    }

    if anonymous then
        params.anonymous = anonymous
    elseif flag then
        params.anonymous_flag = flag
    end

    return self.send({
        action = "set_group_anonymous_ban",
        params = params
    })
end

-- 群组全员禁言
function ob11_api:set_group_whole_ban(group_id, enable)
    enable = enable or true
    return self.send({
        action = "set_group_whole_ban",
        params = {
            group_id = group_id,
            enable = enable
        }
    })
end

-- 群组设置管理员
function ob11_api:set_group_admin(group_id, user_id, enable)
    enable = enable or true
    return self.send({
        action = "set_group_admin",
        params = {
            group_id = group_id,
            user_id = user_id,
            enable = enable
        }
    })
end

-- 群组匿名设置
function ob11_api:set_group_anonymous(group_id, enable)
    enable = enable or true
    return self.send({
        action = "set_group_anonymous",
        params = {
            group_id = group_id,
            enable = enable
        }
    })
end

-- 设置群名片
function ob11_api:set_group_card(group_id, user_id, card)
    return self.send({
        action = "set_group_card",
        params = {
            group_id = group_id,
            user_id = user_id,
            card = card or ""
        }
    })
end

-- 设置群名
function ob11_api:set_group_name(group_id, group_name)
    return self.send({
        action = "set_group_name",
        params = {
            group_id = group_id,
            group_name = group_name
        }
    })
end

-- 退出群组
function ob11_api:set_group_leave(group_id, is_dismiss)
    is_dismiss = is_dismiss or false
    return self.send({
        action = "set_group_leave",
        params = {
            group_id = group_id,
            is_dismiss = is_dismiss
        }
    })
end

-- 设置群组专属头衔
function ob11_api:set_group_special_title(group_id, user_id, special_title, duration)
    duration = duration or -1
    return self.send({
        action = "set_group_special_title",
        params = {
            group_id = group_id,
            user_id = user_id,
            special_title = special_title or "",
            duration = duration
        }
    })
end

-- 处理加好友请求
function ob11_api:set_friend_add_request(flag, approve, remark)
    return self.send({
        action = "set_friend_add_request",
        params = {
            flag = flag,
            approve = approve or true,
            remark = remark or ""
        }
    })
end

-- 处理加群请求
function ob11_api:set_group_add_request(flag, sub_type, approve, reason)
    return self.send({
        action = "set_group_add_request",
        params = {
            flag = flag,
            sub_type = sub_type,
            approve = approve or true,
            reason = reason or ""
        }
    })
end

-- 获取登录号信息
function ob11_api:get_login_info()
    return self.send({
        action = "get_login_info"
    })
end

-- 获取陌生人信息
function ob11_api:get_stranger_info(user_id, no_cache)
    no_cache = no_cache or false
    return self.send({
        action = "get_stranger_info",
        params = {
            user_id = user_id,
            no_cache = no_cache
        }
    })
end

-- 获取好友列表
function ob11_api:get_friend_list()
    return self.send({
        action = "get_friend_list"
    })
end

-- 获取群信息
function ob11_api:get_group_info(group_id, no_cache)
    no_cache = no_cache or false
    return self.send({
        action = "get_group_info",
        params = {
            group_id = group_id,
            no_cache = no_cache
        }
    })
end

-- 获取群列表
function ob11_api:get_group_list()
    return self.send({
        action = "get_group_list"
    })
end

-- 获取群成员信息
function ob11_api:get_group_member_info(group_id, user_id, no_cache)
    no_cache = no_cache or false
    return self.send({
        action = "get_group_member_info",
        params = {
            group_id = group_id,
            user_id = user_id,
            no_cache = no_cache
        }
    })
end

-- 获取群成员列表
function ob11_api:get_group_member_list(group_id)
    return self.send({
        action = "get_group_member_list",
        params = {
            group_id = group_id
        }
    })
end

-- 获取群荣誉信息
function ob11_api:get_group_honor_info(group_id, honor_type)
    return self.send({
        action = "get_group_honor_info",
        params = {
            group_id = group_id,
            type = honor_type
        }
    })
end

-- 获取Cookies
function ob11_api:get_cookies(domain)
    domain = domain or ""
    return self.send({
        action = "get_cookies",
        params = {
            domain = domain
        }
    })
end

-- 获取CSRF Token
function ob11_api:get_csrf_token()
    return self.send({
        action = "get_csrf_token"
    })
end

-- 获取QQ凭证
function ob11_api:get_credentials(domain)
    domain = domain or ""
    return self.send({
        action = "get_credentials",
        params = {
            domain = domain
        }
    })
end

-- 获取语音文件
function ob11_api:get_record(file, out_format)
    return self.send({
        action = "get_record",
        params = {
            file = file,
            out_format = out_format
        }
    })
end

-- 获取图片文件
function ob11_api:get_image(file)
    return self.send({
        action = "get_image",
        params = {
            file = file
        }
    })
end

-- 检查是否可以发送图片
function ob11_api:can_send_image()
    return self.send({
        action = "can_send_image"
    })
end

-- 检查是否可以发送语音
function ob11_api:can_send_record()
    return self.send({
        action = "can_send_record"
    })
end

-- 获取运行状态
function ob11_api:get_status()
    return self.send({
        action = "get_status"
    })
end

-- 获取版本信息
function ob11_api:get_version_info()
    return self.send({
        action = "get_version_info"
    })
end

-- 重启OneBot实现
function ob11_api:set_restart(delay)
    delay = delay or 0
    return self.send({
        action = "set_restart",
        params = {
            delay = delay
        }
    })
end

-- 清理缓存
function ob11_api:clean_cache()
    return self.send({
        action = "clean_cache"
    })
end

return ob11_api
