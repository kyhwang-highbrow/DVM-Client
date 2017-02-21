-------------------------------------
-- class ServerData_Collection
-------------------------------------
ServerData_Collection = class({
        m_serverData = 'ServerData',

    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Collection:init(server_data)
    self.m_serverData = server_data
end

-------------------------------------
-- function getCollectionList
-------------------------------------
function ServerData_Collection:getCollectionList(role_type, attr_type)
    local role_type = (role_type or 'all')
    local attr_type = (attr_type or 'all')

    local table_dragon = TableDragon()

    local l_ret = {}

    for i,v in pairs(table_dragon.m_orgTable) do
        if (v['test'] ~= 1) then

        elseif (role_type ~= 'all') and (role_type ~= v['role']) then

        elseif (attr_type ~= 'all') and (attr_type ~= v['attr']) then

        -- 위 조건들에 해당하지 않은 경우만 추가
        else
            local did = v['did']
            l_ret[did] = v
        end
    end

    return l_ret
end