-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
        m_mRuneObjects = 'map',
        m_runeCount = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
    self.m_mRuneObjects = {}
    self.m_runeCount = 0
end

-------------------------------------
-- function request_runesInfo
-- @breif
-------------------------------------
function ServerData_Runes:request_runesInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 룬 강화 테이블
        TABLE:setServerTable('table_rune_enhance', ret['table_rune_enhance'])

        -- 룬 등급 테이블
        TABLE:setServerTable('table_rune_grade', ret['table_rune_grade'])

        -- 룬 메인 옵션 능력치 테이블
        TABLE:setServerTable('table_rune_mopt_status', ret['table_rune_mopt_status'])

        -- 보유 중인 룬 정보를 받아옴
        self:applyRuneData_list(ret['runes'])

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/info')
    ui_network:setParam('uid', uid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_runesEquip
-- @breif
-------------------------------------
function ServerData_Runes:request_runesEquip(doid, roid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)

        if ret['deleted_rune_oid'] then
            self:deleteRuneData(ret['deleted_rune_oid'])
        end

        if ret['modified_rune'] then
            self:applyRuneData(ret['modified_rune'])
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['dragon'] then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        -- @ MASTER ROAD
        local t_data = {road_key = 'r_eq'}
        g_masterRoadData:updateMasterRoad(t_data)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/equip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('roid', roid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runesUnequip
-- @breif
-------------------------------------
function ServerData_Runes:request_runesUnequip(doid, slot, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if ret['modified_rune'] then
            self:applyRuneData(ret['modified_rune'])
        end
        
        -- 반드시 룬을 먼저 갱신하고 dragon을 갱신할 것
        if ret['modified_dragon'] then
            g_dragonsData:applyDragonData(ret['modified_dragon'])
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/unequip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('slot', slot)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeLevelup
-- @breif
-------------------------------------
function ServerData_Runes:request_runeLevelup(owner_doid, roid, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- 공통 응답 처리 (골드 갱신을 위해)
        g_serverData:networkCommonRespone(ret)

        if ret['modified_rune'] then
            ret['lvup_success'] = true
            ret['modified_rune']['owner_doid'] = owner_doid
            self:applyRuneData(ret['modified_rune'])
        else
            ret['lvup_success'] = false
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/runes/levelup')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setMethod('POST')
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function request_runeSell
-- @brief
-------------------------------------
function ServerData_Runes:request_runeSell(roid, finish_cb)
    local rune_oids = roid
    local evolution_stones = nil
    local fruits = nil
    local tickets = nil

    g_inventoryData:request_itemSell(rune_oids, evolution_stones, fruits, tickets, finish_cb)
end


-------------------------------------
-- function applyRuneData
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData(t_rune_data)
    local roid = t_rune_data['id']

    -- 추가일 경우 count 증가
    if (not self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount + 1)
    end

    -- 룬 정보의 관리를 위해 StructRuneObject클래스로 래핑하여 사용
    self.m_mRuneObjects[roid] = StructRuneObject(t_rune_data)
end

-------------------------------------
-- function applyRuneData_list
-- @breif 룬 오브젝트 적용 (추가, 갱신)
-------------------------------------
function ServerData_Runes:applyRuneData_list(l_rune_data)
    for i,v in pairs(l_rune_data) do
        self:applyRuneData(v)
    end
end

-------------------------------------
-- function deleteRuneData
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData(roid)
    -- 삭제일 경우 count 감소
    if (self.m_mRuneObjects[roid]) then
        self.m_runeCount = (self.m_runeCount - 1)
        self.m_mRuneObjects[roid] = nil
    end
end

-------------------------------------
-- function deleteRuneData_list
-- @breif 룬 오브젝트 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData_list(l_roid)
    for i,v in pairs(l_roid) do
        self:deleteRuneData(v)
    end
end


-------------------------------------
-- function getUnequippedRuneList
-- @brief 장착되지 않은 룬 리스트
-------------------------------------
function ServerData_Runes:getUnequippedRuneList(slot_idx)
    if (not slot_idx) then
        -- 전체
        slot_idx = 0
    end

    local l_ret = {}

    for i,v in pairs(self.m_mRuneObjects) do
        -- 슬롯 확인
        if (slot_idx ~= 0) and (v['slot'] ~= slot_idx) then
        -- 장착 여부 확인
        elseif v:isEquippedRune() then
        else
            local roid = v['roid']
            l_ret[roid] = clone(v)
        end
    end

    return l_ret
end

-------------------------------------
-- function getFilteredRuneList
-- @brief 필터링된 룬 리스트
-------------------------------------
function ServerData_Runes:getFilteredRuneList(unequipped, slot, set_id)
    if (slot == 0) then
        slot = nil
    end

    if (set_id == 0) then
        set_id = nil
    end
    

    local l_ret = {}

    
    for i,v in pairs(self.m_mRuneObjects) do
        -- 슬롯 필터
        if slot and (slot ~= v['slot']) then
        -- 세트 필터
        elseif set_id and (set_id ~= v['set_id']) then
        -- 장착 여부 필터
        elseif unequipped and (v:isEquippedRune()) then

        -- 리스트에 추가
        else
            l_ret[i] = v
        end
    end
    

    return l_ret
end

-------------------------------------
-- function getRuneObject
-- @breif
-------------------------------------
function ServerData_Runes:getRuneObject(roid)
    if (not self.m_mRuneObjects[roid]) then
        cclog('# 보유하지 않은 룬 검색 : ' .. roid)
        ccdebug()
    end

    return self.m_mRuneObjects[roid]
end

-------------------------------------
-- function applyEquippedRuneInfo
-- @breif
-------------------------------------
function ServerData_Runes:applyEquippedRuneInfo(roid, doid)
    local rune_object = self:getRuneObject(roid)
    if (not rune_object) then
        return
    end
    rune_object:setOwnerDragon(doid)
end


-------------------------------------
-- function getUnequippedRuneCount
-- @breif
-------------------------------------
function ServerData_Runes:getUnequippedRuneCount()
    local unequipped = true
    local l_runes = self:getFilteredRuneList(unequipped)
    local count = table.count(l_runes)
    return count
end