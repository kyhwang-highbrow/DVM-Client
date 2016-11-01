--

LocalServer = {}

LocalServer['user_local_server'] = false

LocalServer['/get_patch_info'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'
    t_ret['cur_patch_ver'] = 0
    t_ret['list'] = {}

    success_cb(t_ret)
end


LocalServer['/login'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'
    t_ret['user'] = g_serverData:get('user')
    t_ret['dragons'] = g_serverData:get('dragons')

    success_cb(t_ret)
end

LocalServer['/users/get_deck'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'
    t_ret['deck'] = g_serverData:get('deck')

    success_cb(t_ret)
end

LocalServer['/users/set_deck'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'

    local l_deck = g_deckData:getDeck(t_data['deckno'])
    --ccdump(l_deck)

    success_cb(t_ret)
end









-------------------------------------
-- function CalcDragonExp
-- @brief
-------------------------------------
function CalcDragonExp(t_dragon_data, add_exp)
    local t_ret_data = {}

    local curr_lv = t_dragon_data['lv']
    local curr_exp = t_dragon_data['exp']

    t_ret_data['prev_lv'] = t_dragon_data['lv']
    t_ret_data['prev_exp'] = t_dragon_data['exp']

    local table_exp = TABLE:get('exp_dragon')

    -- 최대레벨 여부
    local is_max_level = false

    -- 실제 증가된 경험치
    local org_add_exp = add_exp
    local real_add_exp = 0

    -- 최대 레벨
    local max_level = dragonMaxLevel(t_dragon_data['evolution'])

    while true do
        local t_exp = table_exp[curr_lv]

        -- 최대 레벨일 경우
        if (t_exp['exp_d'] == 0) or (max_level <= curr_lv) then
            is_max_level = true
            break
        end

        -- 경험치가 없을 경우
        if (add_exp <= 0) then
            break
        end

        local prev_exp = curr_exp
        curr_exp = (curr_exp + add_exp)

        if (t_exp['exp_d'] <= curr_exp) then
            add_exp = curr_exp - t_exp['exp_d']
            curr_lv = curr_lv + 1
            curr_exp = 0
            real_add_exp = real_add_exp + (t_exp['exp_d'] - prev_exp)
        else
            real_add_exp = real_add_exp + add_exp
            add_exp = 0
        end
    end    

    local t_exp = table_exp[curr_lv]

    t_dragon_data['lv'] = curr_lv
    t_dragon_data['exp'] = curr_exp

    t_ret_data['curr_lv'] = t_dragon_data['lv']
    t_ret_data['curr_exp'] = t_dragon_data['exp']
    t_ret_data['curr_max_exp'] = t_exp['exp_d']
    t_ret_data['is_max_level'] = is_max_level
    t_ret_data['add_lv'] = (t_ret_data['curr_lv'] - t_ret_data['prev_lv'])
    t_ret_data['add_exp'] = real_add_exp

    return t_ret_data
end