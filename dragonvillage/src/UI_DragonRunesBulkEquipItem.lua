local PARENT = UI

-------------------------------------
-- class UI_DragonRunesBulkEquipItem
-------------------------------------
UI_DragonRunesBulkEquipItem = class(PARENT,{
        m_doid = 'string', 

        m_type = 'string', -- 시뮬레이션 전(before) or 시뮬레이션 후(after)
    
        m_lRoidList = 'list', -- 현재 장착된 룬 리스트
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipItem:init(doid, type)
    local vars = self:load('dragon_rune_popup_item_01.ui')

    self.m_doid = doid
    self.m_type = type

    -- 현재 장착된 룬 roid 리스트
    local l_roid_list = {}
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    
    for idx = 1, 6 do
        table.insert(l_roid_list, dragon_obj['runes'][tostring(idx)])
    end

    self.m_lRoidList = l_roid_list

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipItem:initUI()
    local vars = self.vars
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonRunesBulkEquipItem:refresh()
    local vars = self.vars

    for slot_idx = 1, 6 do
        self:refreshRuneCard(slot_idx)
    end

    -- 스탯 표기
    self:refreshStat()
end

-------------------------------------
-- function refreshRuneCard
-- @brief 해당 함수는 룬 카드 변경이 필요할 때만 호출
-------------------------------------
function UI_DragonRunesBulkEquipItem:refreshRuneCard(slot_idx)
    local vars = self.vars

    vars['runeSlot' .. slot_idx]:removeAllChildren()

    local roid = self.m_lRoidList[slot_idx]
            
    if (roid ~= nil) then
        local rune_obj = g_runesData:getRuneObject(roid)
        local card = UI_RuneCard(rune_obj)
        
        vars['runeSlot' .. slot_idx]:addChild(card.root)
        
        -- TODO : 시뮬레이션 전에 장착하고 있던 룬의 경우 까만 레이어 씌우기
        if (false) then
        
        end           
    end
end

-------------------------------------
-- function refreshStat
-- @brief type에 따라 스탯 표기 다름
-- type : before 인 경우 단순 스탯 표기
-- type : after 인 경우 스탯 + 변화 스탯 표기
-------------------------------------
function UI_DragonRunesBulkEquipItem:refreshStat()
    local vars = self.vars

    local type = self.m_type

    local doid = self.m_doid
    local before_dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    local before_status_calc = MakeDragonStatusCalculator_fromDragonDataTable(before_dragon_obj)    
    
    local after_dragon_obj
    local after_status_calc

    if (type == 'after') then
        after_dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

        for slot_idx = 1, 6 do
            local after_roid = self.m_lRoidList[slot_idx]
            after_dragon_obj['runes'][tostring(slot_idx)] = after_roid
        end

        after_status_calc = MakeDragonStatusCalculator_fromDragonDataTable(after_dragon_obj)    
    end

    -- 스탯 표기 정보 (스탯 key, 퍼센트 표기 여부)
    local l_stat_data_list = {
                                {'hp', false}, 
                                {'atk', false},
                                {'def', false},
                                {'aspd', true},
                                {'cri_chance', true},
                                {'cri_dmg', true},
                                {'hit_rate', false},
                                {'avoid', false},
                                {'cri_avoid', false},
                                {'accuracy', false},
                                {'resistance', false},
                            }

    for _, stat_data in ipairs(l_stat_data_list) do
        local stat_key = stat_data[1]
        local b_use_percent = stat_data[2]

        local before_stat_str = before_status_calc:getFinalStatDisplay(stat_key, b_use_percent)
        local before_stat = math_floor(before_status_calc:getFinalStat(stat_key))
        
        local after_stat_str = ''
        
         if (after_status_calc ~= nil) then
            local after_stat = math_floor(after_status_calc:getFinalStat(stat_key))
            local differ_stat = after_stat - before_stat
            
            if (differ_stat ~= 0) then
                after_stat_str = after_stat_str .. '('

                if (differ_stat >= 0) then
                    after_stat_str = after_stat_str .. '+'
                end

                after_stat_str = after_stat_str .. comma_value(differ_stat)

                if (b_use_percent == true) then
                    after_stat_str = after_stat_str .. '%'
                end

                after_stat_str = after_stat_str .. ')'
            end
        end

        vars[stat_key .. '_label']:setString(before_stat_str)
        vars[stat_key .. '_label2']:setString(after_stat_str)        
    end

    if (after_dragon_obj == nil) then
        vars['cp_label']:setString(comma_value(before_dragon_obj:getCombatPower()))
    
    else
        vars['cp_label']:setString(comma_value(after_dragon_obj:getCombatPower()))
    end
end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateRune(roid)
    local struct_rune = g_runesData:getRuneObject(roid)
    
    local slot_idx = struct_rune['slot']
    
    -- 이미 장착 중인 경우 장착 해제
    if (self.m_lRoidList[slot_idx] == roid) then
        self.m_lRoidList[slot_idx] = nil
    
    -- 장착 안한 룬인 경우 장착
    else
        self.m_lRoidList[slot_idx] = roid
    end

    self:refreshRuneCard(slot_idx)
    self:refreshStat()
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateDragonRune(doid)
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

    for slot_idx = 1, 6 do
        local roid = dragon_obj['runes'][tostring(slot_idx)]

        self.m_lRoidList[slot_idx] = roid
        self:refreshRuneCard(slot_idx)
    end

    self:refreshStat()
end
