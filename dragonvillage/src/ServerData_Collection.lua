-------------------------------------
-- class ServerData_Collection
-------------------------------------
ServerData_Collection = class({
        m_serverData = 'ServerData',
        m_mCollectionData = 'map',
        m_lastChangeTimeStamp = 'timestamp', 
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

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

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
function ServerData_Collection:openCollectionPopup(close_cb)
    local function cb()
        local ui = UI_Collection()
        ui:setCloseCB(close_cb)
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

-------------------------------------
-- function getRelationPoint
-- @brief 인연포인트
-------------------------------------
function ServerData_Collection:getRelationPoint(did)
    local did_str = tostring(did)
    local t_data = self.m_mCollectionData[did_str]
    if (not t_data) then
        return 0
    end

    return t_data['relation'] or 0
end

-------------------------------------
-- function applyRelationPoints
-- @brief 인연포인트
-------------------------------------
function ServerData_Collection:applyRelationPoints(relation_point_map)
    if (not self.m_mCollectionData) then
        self.m_mCollectionData = {}
    end

    for i,v in pairs(relation_point_map) do
        if (not self.m_mCollectionData[i]) then
            self.m_mCollectionData[i] = {}
        end

        self.m_mCollectionData[i]['relation'] = v
    end

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function setDragonCollection
-- @brief 도감에 드래곤 등록
-------------------------------------
function ServerData_Collection:setDragonCollection(did)
    local did = tostring(did)
    if (not self.m_mCollectionData) then
        self.m_mCollectionData = {}
    end

    if (not self.m_mCollectionData[did]) then
        self.m_mCollectionData[did] = {}
    end

    self.m_mCollectionData[did]['exist'] = true

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function request_useRelationPoint
-------------------------------------
function ServerData_Collection:request_useRelationPoint(did, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/relation')
    ui_network:setParam('uid', uid)
    ui_network:setParam('did', did)
    ui_network:setParam('cnt', 1)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function setLastChangeTimeStamp
-- @breif 마지막으로 데이터가 변경된 시간 갱신
-------------------------------------
function ServerData_Collection:setLastChangeTimeStamp()
    self.m_lastChangeTimeStamp = Timer:getServerTime()
end

-------------------------------------
-- function getLastChangeTimeStamp
-------------------------------------
function ServerData_Collection:getLastChangeTimeStamp()
    return self.m_lastChangeTimeStamp
end

-------------------------------------
-- function checkChange
-------------------------------------
function ServerData_Collection:checkChange(timestamp)
    if (self.m_lastChangeTimeStamp ~= timestamp) then
        return true
    end

    return false
end