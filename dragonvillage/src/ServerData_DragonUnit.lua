-------------------------------------
-- class ServerData_DragonUnit
-------------------------------------
ServerData_DragonUnit = class({
        m_serverData = 'ServerData',
        m_mDragonUnitDataList = 'map',

        m_lastChangeTimeStamp = 'timestamp',

        m_unitServerData = 'list',
        m_selectedUnitID = 'number',
        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_DragonUnit:init(server_data)
    self.m_serverData = server_data
    self.m_bDirty = true
end

-------------------------------------
-- function organizeData
-- @brief 클라이언트에서 사용하기 위한 데이터 가공
-------------------------------------
function ServerData_DragonUnit:organizeData(finish_unit_id_list)
    self.m_unitServerData = (finish_unit_id_list or self.m_unitServerData)
    
    -- 테이블에서 리스트업
    self.m_mDragonUnitDataList = {}

    local table_dragon_unit = TableDragonUnit()

    for unit_id,v in pairs(table_dragon_unit.m_orgTable) do
        local strunct_dragon_unit = StructDragonUnit(unit_id)
        self.m_mDragonUnitDataList[unit_id] = strunct_dragon_unit

        if table.find(self.m_unitServerData, unit_id) then
            strunct_dragon_unit.m_rewardReceived = true
        else
            strunct_dragon_unit.m_rewardReceived = false
        end
    end

    self.m_bDirty = false
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function getDragonUnitData
-------------------------------------
function ServerData_DragonUnit:getDragonUnitData(unit_id)
    if self.m_bDirty then
        self:organizeData(nil)
    end

    return self.m_mDragonUnitDataList[unit_id]
end

-------------------------------------
-- function getDragonUnitList
-- @brief did가 포함된 리스트 리턴
-------------------------------------
function ServerData_DragonUnit:getDragonUnitList(did)
    if self.m_bDirty then
        self:organizeData(nil)
    end

    local t_ret = {}

    for i,v in pairs(self.m_mDragonUnitDataList) do
        if v:containsDid(did) then
            t_ret[i] = v
        end
    end

    return t_ret
end


-------------------------------------
-- function getDragonUnitIDList
-------------------------------------
function ServerData_DragonUnit:getDragonUnitIDList()
    if self.m_bDirty then
        self:organizeData(nil)
    end

    local t_dragon_unit = TableDragonUnit()

    local t_ret = {}

    for i,v in pairs(t_dragon_unit.m_orgTable) do
        if (i~=9001) then
            table.insert(t_ret, i)
        end
    end

    return t_ret
end

-------------------------------------
-- function request_unitReward
-------------------------------------
function ServerData_DragonUnit:request_unitReward(unit_id, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone_addedItems(ret)
        self:organizeData(ret['unit'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/unit/reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('unit', unit_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_unitSelect
-------------------------------------
function ServerData_DragonUnit:request_unitSelect(unit_id, finish_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        self:setSelectedUnitID(unit_id)
        self:organizeData(ret['unit'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/unit/select')
    ui_network:setParam('uid', uid)
    ui_network:setParam('unit', unit_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function setLastChangeTimeStamp
-- @breif 마지막으로 데이터가 변경된 시간 갱신
-------------------------------------
function ServerData_DragonUnit:setLastChangeTimeStamp()
    self.m_lastChangeTimeStamp = Timer:getServerTime()
end

-------------------------------------
-- function getLastChangeTimeStamp
-------------------------------------
function ServerData_DragonUnit:getLastChangeTimeStamp()
    return self.m_lastChangeTimeStamp
end

-------------------------------------
-- function checkChange
-------------------------------------
function ServerData_DragonUnit:checkChange(timestamp)
    if (self.m_lastChangeTimeStamp ~= timestamp) then
        return true
    end

    return false
end

-------------------------------------
-- function setDirty
-------------------------------------
function ServerData_DragonUnit:setDirty()
    self.m_bDirty = true
    self:setLastChangeTimeStamp()
end

-------------------------------------
-- function setSelectedUnitID
-------------------------------------
function ServerData_DragonUnit:setSelectedUnitID(unit_id)
    if (unit_id == 0) then
        self.m_selectedUnitID = nil
    else
        self.m_selectedUnitID = unit_id
    end
end

