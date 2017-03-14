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

    do
        local t_deck = {}
        t_deck['deckname'] = t_request['deckname']
        t_deck['deck'] = {}
        t_deck['deck']['1'] = t_request['edoid1']
        t_deck['deck']['2'] = t_request['edoid2']
        t_deck['deck']['3'] = t_request['edoid3']
        t_deck['deck']['4'] = t_request['edoid4']
        t_deck['deck']['5'] = t_request['edoid5']
        t_deck['deck']['6'] = t_request['edoid6']
        t_deck['deck']['7'] = t_request['edoid7']
        t_deck['deck']['8'] = t_request['edoid8']
        t_deck['deck']['9'] = t_request['edoid9']
        t_ret['deck'] = t_deck
    end

    success_cb(t_ret)
end

LocalServer['/dragons/update'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'

    success_cb(t_ret)
end

LocalServer['/users/set_leader_dragon'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'

    success_cb(t_ret)
end


LocalServer['/game/stage/start'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'

    success_cb(t_ret)
end

LocalServer['/game/stage/finish'] = function(t_request)
    local t_data = t_request['data']

    local success_cb = t_request['success']

    local fail_cb = t_request['fail']

    local t_ret = {}
    t_ret['status'] = 0
    t_ret['message'] = 'success'

    success_cb(t_ret)
end