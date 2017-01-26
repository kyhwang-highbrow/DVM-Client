-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',
        m_tableRune = 'TableRune',
        m_tableRuneExp = 'TableRuneExp',
    })

local l_rune_slot_name = {}
l_rune_slot_name[1] = 'bellaria'
l_rune_slot_name[2] = 'tutamen'
l_rune_slot_name[3] = 'cimelium'

local l_rune_slot_idx = {}
for i,v in pairs(l_rune_slot_name) do
    l_rune_slot_idx[v] = i
end

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
    self.m_tableRune = TableRune()
    self.m_tableRuneExp = TableRuneExp()
end


-------------------------------------
-- function getRuneData
-------------------------------------
function ServerData_Runes:getRuneData(roid, with_set_data)
    local l_runes = self.m_serverData:getRef('runes')

    for _,v in pairs(l_runes) do
        if (roid == v['id']) then

            if with_set_data then
                local doid = v['odoid']
                local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
                if t_dragon_data then
                    v['rune_set'] = t_dragon_data['rune_set']
                end
            end

            return clone(v)
        end
    end

    return nil
end

-------------------------------------
-- function applyRuneData_list
-- @brief 서버에서 넘어오는 룬 정보 갱신
-------------------------------------
function ServerData_Runes:applyRuneData_list(l_rune_data)
    g_serverData:lockSaveData()
    for i,v in pairs(l_rune_data) do
        local t_rune_data = v
        self:applyRuneData(t_rune_data)
    end
    g_serverData:unlockSaveData()
end

-------------------------------------
-- function applyRuneData
-- @brief 서버에서 넘어오는 룬 정보 갱신
-------------------------------------
function ServerData_Runes:applyRuneData(t_rune_data)
    local idx = nil

    -- 보유중인 룬에서 t_rune_data정보가 있는지 확인
    local l_runes = self.m_serverData:getRef('runes')

    if l_runes then
        local roid = t_rune_data['id']
        for i,v in pairs(l_runes) do
            if (roid == v['id']) then
                idx = i
                break
            end
        end

        if (idx == nil) then
            idx = #l_runes + 1
        end
    else
        idx = 1
    end

    t_rune_data['information'] = self:makeRuneInfomation(t_rune_data)

    -- 기존에 있는 룬데이터이면 갱신
    self.m_serverData:applyServerData(t_rune_data, 'runes', idx)
end

-------------------------------------
-- function deleteRuneData_list
-- @brief 서버에서 넘어오는 룬 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData_list(l_rune_roid)
    g_serverData:lockSaveData()
    for i,v in pairs(l_rune_roid) do
        local roid = v
        self:deleteRuneData(roid)
    end
    g_serverData:unlockSaveData()
end

-------------------------------------
-- function deleteRuneData
-- @brief 서버에서 넘어오는 룬 삭제
-------------------------------------
function ServerData_Runes:deleteRuneData(roid)
    -- 보유중인 룬에서 t_rune_data정보가 있는지 확인
    local l_runes = self.m_serverData:getRef('runes')

    local idx = nil
    if l_runes then
        for i,v in pairs(l_runes) do
            if (roid == v['id']) then
                idx = i
                break
            end
        end
    end

    if idx then
        self.m_serverData:applyServerData(nil, 'runes', idx)
    end
end

-------------------------------------
-- function makeRuneInfomation
-- @brief
-------------------------------------
function ServerData_Runes:makeRuneInfomation(t_rune_data)
    local table_rune = TableRune()

    local rid = t_rune_data['rid']
    local mopt_1_type = t_rune_data['mopt']['1']
    local mopt_2_type = t_rune_data['mopt']['2']
    local rarity = t_rune_data['rarity']
    local lv = t_rune_data['lv']

    local full_name, alphabet_idx = table_rune:getRuneFullName(rid, mopt_1_type, mopt_2_type, rarity, lv)

    local t_rune_infomation = {}
    t_rune_infomation['rid'] = rid
    t_rune_infomation['full_name'] = full_name
    t_rune_infomation['alphabet_idx'] = alphabet_idx
    t_rune_infomation['lv'] = lv

    -- 최대 레벨 여부
    local max_level = self.m_tableRuneExp:getRuneMaxLevel(t_rune_data['grade'])
    --t_rune_infomation['max_lv'] = max_level
    t_rune_infomation['is_max_lv'] = (max_level <= lv)

    t_rune_infomation['status'] = self:makeRuneStatus(t_rune_data)

    return t_rune_infomation
end

-------------------------------------
-- function makeRuneStatus
-- @brief
-------------------------------------
function ServerData_Runes:makeRuneStatus(t_rune_data)
    local grade = t_rune_data['grade']
    local lv = t_rune_data['lv']
    local rarity = t_rune_data['rarity']

    local l_mopt = {}
    local l_sopt = {}

    local table_rune_status = TableRuneStatus()

    -- 메인 옵션
    for i,v in pairs(t_rune_data['mopt']) do
        i = tonumber(i)
        local category = v
        if (category and category~='') then
            l_mopt[i] = table_rune_status:getMainOptionStatus(grade, category, lv)
        end
    end

    -- 서브 옵션
    for i,v in pairs(t_rune_data['sopt']) do
        i = tonumber(i)
        local category = v
        if (category and category~='') then
            l_sopt[i] = table_rune_status:getSubOptionStatus(grade, category, rarity)
        end
    end

    local t_rune_status = {}
    t_rune_status['mopt'] = l_mopt
    t_rune_status['sopt'] = l_sopt

    return t_rune_status
end

-------------------------------------
-- function getRuneInfomation
-- @brief rune object id로 룬의 정보 분석
-------------------------------------
function ServerData_Runes:getRuneInfomation(roid)
    local t_rune_data = self:getRuneData(roid)
    local t_rune_infomation = t_rune_data['information']
    return t_rune_infomation, t_rune_data
end

-------------------------------------
-- function getUnequippedRuneList
-- @brief 장착되지 않은 룬 리스트
-- @paran type string : 'nil = all', 'bellaria', 'tutamen', 'cimelium'
-------------------------------------
function ServerData_Runes:getUnequippedRuneList(slot_type)
    if (not slot_type) then
        slot_type = 'all'
    end

    local l_runes = self.m_serverData:getRef('runes')

    local l_ret = {}

    for i,v in pairs(l_runes) do
        -- 이 룬을 장착한 드래곤이 없을 경우
        if (not v['odoid']) or (v['odoid'] == '') then
            -- 슬롯 확인
            if (slot_type == 'all') or (v['type'] == slot_type) then
                local roid = v['id']
                l_ret[roid] = clone(v)
            end
        end
    end

    return l_ret
end

-------------------------------------
-- function getRuneEnchantMaterials
-- @brief 룬 강화 재료 리스트 리턴
-------------------------------------
function ServerData_Runes:getRuneEnchantMaterials(enchant_roid)
    if (not slot_type) then
        slot_type = 'all'
    end

    local l_runes = self.m_serverData:getRef('runes')

    local l_ret = {}

    for i,v in pairs(l_runes) do
        -- 이 룬을 장착한 드래곤이 없을 경우
        if (not v['odoid']) or (v['odoid'] == '') then
            local roid = v['id']

            -- 강화 대상 룬은 제외
            if (enchant_roid ~= roid) then
                l_ret[roid] = clone(v)
            end
        end
    end

    return l_ret
end

-------------------------------------
-- function requestRuneEquip
-- @brief 룬 장착
-------------------------------------
function ServerData_Runes:requestRuneEquip(doid, roid, cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)


        if (ret['dragon']) then
            g_dragonsData:applyDragonData(ret['dragon'])
        end


        if (ret['modified_runes']) then
            g_runesData:applyRuneData_list(ret['modified_runes'])
        end
        

        if cb_func then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/runes/equip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('roid', roid)
    ui_network:setParam('act', 'exchange') -- 'overwrite'는 덮어쓰기
    ui_network:setRevocable(true) -- 통신 실패 시 재시도 여부
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function requestRuneUnequip
-- @brief 룬 해제
-------------------------------------
function ServerData_Runes:requestRuneUnequip(doid, roid, slot, cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        if (ret['dragon']) then
            g_dragonsData:applyDragonData(ret['dragon'])
        end

        if (ret['modified_runes']) then
            g_runesData:applyRuneData_list(ret['modified_runes'])
        end

        -- @TODO sgkim 'modified_rune'으로 변경할 것
        if (ret['rune']) then
            g_runesData:applyRuneData(ret['rune'])
        end

        if cb_func then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/runes/unequip')
    ui_network:setParam('uid', uid)
    ui_network:setParam('doid', doid)
    ui_network:setParam('roid', roid)
    ui_network:setParam('slot', slot)
    ui_network:setRevocable(true) -- 통신 실패 시 재시도 여부
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function getSlotName
-- @brief
-------------------------------------
function ServerData_Runes:getSlotName(slot_idx)
    if (not l_rune_slot_name[slot_idx]) then
        error('slot_idx : ' .. slot_idx)
    end

    return l_rune_slot_name[slot_idx]
end

-------------------------------------
-- function getSlotIdx
-- @brief
-------------------------------------
function ServerData_Runes:getSlotIdx(slot_type)
    if (not l_rune_slot_idx[slot_type]) then
        error('slot_type : ' .. slot_type)
    end

    return l_rune_slot_idx[slot_type]
end



-------------------------------------
-- function requestRuneEnchant
-- @brief
-------------------------------------
function ServerData_Runes:requestRuneEnchant(roid, src_roids, cb_func)
    local uid = g_userData:get('uid')

    -- 성공 시 콜백
    local function success_cb(ret)
        g_serverData:networkCommonRespone(ret)

        
        if (ret['deleted_rune_oid']) then -- @TODO sgkim 'deleted_rune_oids' or 'deleted_runes_oid' 으로 변경할 것
            g_runesData:deleteRuneData_list(ret['deleted_rune_oid'])
        end

        if (ret['rune']) then -- @TODO sgkim 'modified_rune'으로 변경할 것
            g_runesData:applyRuneData(ret['rune'])
        end

        if cb_func then
            cb_func(ret)
        end
    end

    local ui_network = UI_Network()
    ui_network:setUrl('/runes/enchant')
    ui_network:setParam('uid', uid)
    ui_network:setParam('roid', roid)
    ui_network:setParam('src_roids', src_roids)
    ui_network:setRevocable(true) -- 통신 실패 시 재시도 여부
    ui_network:setSuccessCB(function(ret) success_cb(ret) end)
    ui_network:request()
end

-------------------------------------
-- function makeRuneSetData_usingRoid
-- @brief
-------------------------------------
function ServerData_Runes:makeRuneSetData_usingRoid(roid_1, roid_2, roid_3)
    local t_rune_data_1 = self:getRuneData(roid_1)
    local t_rune_data_2 = self:getRuneData(roid_2)
    local t_rune_data_3 = self:getRuneData(roid_3)
    return self:makeRuneSetData(t_rune_data_1, t_rune_data_2, t_rune_data_3)
end

-------------------------------------
-- function makeRuneSetData
-- @brief
-------------------------------------
function ServerData_Runes:makeRuneSetData(t_rune_data_1, t_rune_data_2, t_rune_data_3)
    local l_rune_data_list = {}

    -- 룬이 존재하는지 체크
    if (not t_rune_data_1) then
        return nil
    end
    table.insert(l_rune_data_list, t_rune_data_1)

    if (not t_rune_data_2) then
        return nil
    end
    table.insert(l_rune_data_list, t_rune_data_2)

    if (not t_rune_data_3) then
        return nil
    end
    table.insert(l_rune_data_list, t_rune_data_3)

    -- 룬들 검증
    local set_color = nil
    local m_rune_slot = {}
    local min_grade = nil
    for i,v in ipairs(l_rune_data_list) do
        local rid = v['rid']
        local color = self.m_tableRune:getValue(rid, 'set_color')

        -- 동일한 세트 종류인지 체크
        if (not set_color) then
            set_color = color
        elseif (set_color ~= color) then
            return nil
        end

        -- 각 슬롯에 하나씩 있는지 체크
        local slot_type = v['type']
        if (not m_rune_slot[slot_type]) then
            m_rune_slot[slot_type] = true
        else
            return nil
        end

        -- 적용되는 등급 체크
        local grade = v['grade']
        if (not min_grade) then
            min_grade = grade
        else
            min_grade = math_min(grade, min_grade)
        end
    end

    -- 룬 세트 정보 얻어옴
    local t_rune_set = TableRuneSet:makeRuneSetData(set_color, min_grade)
    
    return t_rune_set
end