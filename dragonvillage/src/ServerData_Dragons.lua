-------------------------------------
-- class ServerData_Dragons
-------------------------------------
ServerData_Dragons = class({
        m_serverData = 'ServerData',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Dragons:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
end

-------------------------------------
-- function get
-------------------------------------
function ServerData_Dragons:get(key)
    return self.m_serverData:get('dragons', key)
end

-------------------------------------
-- function getDragonsList
-------------------------------------
function ServerData_Dragons:getDragonsList()
    local l_dragons = self.m_serverData:get('dragons')

    local l_ret = {}
    for _,v in pairs(l_dragons) do
        local unique_id = v['id']
        l_ret[unique_id] = clone(v)
    end

    return l_ret
end

-------------------------------------
-- function getDragonDataFromUid
-- @brief unique id로 드래곤 정보를 얻음
-------------------------------------
function ServerData_Dragons:getDragonDataFromUid(unique_id)
    local l_dragons = self.m_serverData:get('dragons')

    for _,v in pairs(l_dragons) do
        if (unique_id == v['id']) then
            return clone(v)
        end
    end

    return nil
end


T_DRAGON_SORT = {}

T_DRAGON_SORT['normal'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['did'] > t_data_b['did']) then
        return true
    elseif (t_data_a['did'] < t_data_b['did']) then
        return false
    end

    return false
end

T_DRAGON_SORT['lv'] = function(a, b)
    local t_data_a = a['data']
    local t_data_b = b['data']
    
    if (t_data_a['lv'] > t_data_b['lv']) then
        return true
    elseif (t_data_a['lv'] < t_data_b['lv']) then
        return false
    end

    

    return false
end