-------------------------------------
-- class ServerData_Runes
-------------------------------------
ServerData_Runes = class({
        m_serverData = 'ServerData',

        m_tableRuneExp = 'TableRuneExp',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Runes:init(server_data)
    self.m_serverData = server_data
    self.m_tableRuneExp = TableRuneExp()
end


-------------------------------------
-- function getRuneData
-------------------------------------
function ServerData_Runes:getRuneData(roid)
    local l_runes = self.m_serverData:getRef('runes')

    for _,v in pairs(l_runes) do
        if (roid == v['id']) then
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
    if (slot_idx == 1) then
        return 'bellaria'
    elseif (slot_idx == 2) then
        return 'tutamen'
    elseif (slot_idx == 3) then
        return 'cimelium'
    else
        error('slot_idx : ' .. slot_idx)
    end
end