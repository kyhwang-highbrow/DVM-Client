-------------------------------------
-- class ServerData_Collection
-------------------------------------
ServerData_Collection = class({
        m_serverData = 'ServerData',

        -- 드래곤 콜렉션 데이터(실제 도감 정보)
        m_mCollectionData = 'map',

        -- 드래곤 원종별 도감
        m_mDragonTypeCollectionData = 'map',
        -- {
        --   'pinkbell':true,
        --   'jaryong':true,
        --   'powerdragon':true
        -- }

        -- 콜렉션 포인트
        m_collectionPoint = 'number',
        m_collectionPointList = '',
        m_tamerTitle = 'string', -- 테이머 칭호 (콜랙션 포인트로 칭호와 자수정을 받을 수 있음)
        m_currCpointRewardFocusKey = 'number',

        m_lastChangeTimeStamp = 'timestamp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Collection:init(server_data)
    self.m_serverData = server_data
    self.m_mDragonTypeCollectionData = {}
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
        --if (v['test'] ~= 1) then
        if false then

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
        self:response_collectionInfo(ret)

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

    return ui_network
end

-------------------------------------
-- function response_collectionInfo
-------------------------------------
function ServerData_Collection:response_collectionInfo(ret)
    -- 유닛 버프 리스트 갱신
    g_dragonUnitData:setSelectedUnitID(ret['selected_unit'])
    g_dragonUnitData:organizeData(ret['unit'])

    self.m_mCollectionData = ret['book']

    do -- 드래곤 원종별 도감
        self.m_mDragonTypeCollectionData = {}
        if ret['dragon_type'] then
            for i,v in pairs(ret['dragon_type']) do
                self.m_mDragonTypeCollectionData[v] = true
            end
        end
    end

    self.m_collectionPoint = ret['cpoint']

    -- 콜랙션 포인트 항목 정보 리스트
    local to_number_list = {'cash_reward', 'req_point'}

    -- 드래곤 도감 테이블
    local table_dragon_collection = ret['table_dragon_collection'] or ret['collection_table'] -- 서버에서 넘겨주는 key값이 변경되었음 170403 sgkim
    if table_dragon_collection then
        table.toNumber(table_dragon_collection, to_number_list)
        self.m_collectionPointList = table.listToMap(table_dragon_collection, 'req_point')
    end

    -- 보상을 받았는지 여부
    if ret['cpoint_reward'] then
        -- 0은 추가
        table.insert(ret['cpoint_reward'], 0)
        for _,req_point in ipairs(ret['cpoint_reward']) do
            self.m_collectionPointList[req_point]['received'] = true
        end
    end

    self:refreshInfo()

    -- 마지막으로 데이터가 변경된 시간 갱신
    self:setLastChangeTimeStamp()
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
-- function isExistDragonType
-- @brief 도감에 표시 여부
-------------------------------------
function ServerData_Collection:isExistDragonType(dragon_type)
    return self.m_mDragonTypeCollectionData[dragon_type]
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

    do -- 드래곤 원종의 도감 정보
        local dragon_type = TableDragon():getValue(tonumber(did), 'type')
        self.m_mDragonTypeCollectionData[dragon_type] = true
    end

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
-- function refreshInfo
-- @breif
-------------------------------------
function ServerData_Collection:refreshInfo()
    do -- 현재 받은 보상 중에서 가장 높은 등급
        local curr_cp_info = nil
        for i,v in pairs(self.m_collectionPointList) do
            if (not curr_cp_info) and (v['req_point'] == 0) then
                curr_cp_info = v
            elseif v['received'] then
                if (not curr_cp_info) then
                    curr_cp_info = v
                elseif (curr_cp_info['req_point'] < v['req_point']) then
                    curr_cp_info = v
                end
            end
        end
        self.m_tamerTitle = curr_cp_info['t_desc']
    end

    do -- 현재 포커스
        local t_cp_info = nil
        for i,v in pairs(self.m_collectionPointList) do
            if (not t_cp_info) and (not v['received']) then
                t_cp_info = v
            elseif (not v['received']) and (v['req_point'] < t_cp_info['req_point']) then
                t_cp_info = v
            end
        end
        self.m_currCpointRewardFocusKey = t_cp_info['req_point']
    end
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

-------------------------------------
-- function getCollectionPoint
-------------------------------------
function ServerData_Collection:getCollectionPoint()
    return self.m_collectionPoint
end

-------------------------------------
-- function getCollectionPointList
-------------------------------------
function ServerData_Collection:getCollectionPointList()
    return self.m_collectionPointList
end

-------------------------------------
-- function getTamerTitle
-------------------------------------
function ServerData_Collection:getTamerTitle()
    return self.m_tamerTitle
end

-------------------------------------
-- function getCollectionPointInfo
-------------------------------------
function ServerData_Collection:getCollectionPointInfo(id)
    return self.m_collectionPointList[id]
end

-------------------------------------
-- function canGerCollectionPointReward
-------------------------------------
function ServerData_Collection:canGerCollectionPointReward(id)
    if (self.m_currCpointRewardFocusKey ~= id) then
        return false
    end

    local t_info = self:getCollectionPointInfo(id)
    if t_info['received'] then
        return false
    end

    if (self:getCollectionPoint() < t_info['req_point']) then
        return false
    end

    return true
end

-------------------------------------
-- function request_collectionPointReward
-------------------------------------
function ServerData_Collection:request_collectionPointReward(req_point, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)

        -- 받음으로 처리
        self.m_collectionPointList[req_point]['received'] = true

        self:refreshInfo()

        -- 마지막으로 데이터가 변경된 시간 갱신
        self:setLastChangeTimeStamp()

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/cpoint/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('req_point', req_point)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end