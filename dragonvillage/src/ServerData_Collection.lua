-------------------------------------
-- class ServerData_Collection
-------------------------------------
ServerData_Collection = class({
        m_serverData = 'ServerData',
        m_mCollectionData = 'map',
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

-------------------------------------
-- function request_collectionInfo
-------------------------------------
function ServerData_Collection:request_collectionInfo(finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self.m_mCollectionData = ret['book']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/book/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function openCollectionPopup
-------------------------------------
function ServerData_Collection:openCollectionPopup()
    local function cb()
        UI_Collection()
    end

    self:request_collectionInfo(cb)
end

-------------------------------------
-- function isExist
-- @brief 도감에 표시 여부
-------------------------------------
function ServerData_Collection:isExist(did)
    local did_str = tostring(did)
    local t_data = self.m_mCollectionData[did_str]
    if (not t_data) then
        return false
    end

    return t_data['exist']
end