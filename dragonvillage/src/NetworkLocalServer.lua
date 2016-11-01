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