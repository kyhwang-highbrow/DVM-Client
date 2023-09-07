local PARENT = UI

-------------------------------------
-- class UI_DragonRunesBulkEquipItem
-------------------------------------
UI_DragonRunesBulkEquipItem = class(PARENT,{
        m_ownerUI = 'UI_DragonRunesBulkEquip',

        m_doid = 'string', 

        m_type = 'string', -- 시뮬레이션 전(before) or 시뮬레이션 후(after)
    
        m_lRoidList = 'list', -- 현재 장착된 룬 리스트

        m_mNumberLabel = 'map',
        m_mNumberDeltaLabel = 'map',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonRunesBulkEquipItem:init(owner_ui, doid, type)
    local vars = self:load('dragon_rune_popup_item_01.ui')

    self.m_ownerUI = owner_ui
    self.m_doid = doid
    self.m_type = type

    -- 현재 장착된 룬 roid 리스트
    local l_roid_list = {}
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    
    for idx = 1, 6 do
        l_roid_list[idx] = dragon_obj['runes'][tostring(idx)]
    end

    self.m_lRoidList = l_roid_list
    self.m_mNumberLabel = {}
    self.m_mNumberDeltaLabel = {}

    self:initUI()

    self:initButton()

    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonRunesBulkEquipItem:initUI()
    local vars = self.vars
    
    local b_is_equipped = (self.m_type == 'before')
    vars['useRuneMenu']:setVisible(b_is_equipped)

    -- 스탯 표기 정보 (스탯 key, 퍼센트 표기 여부)
    local l_stat_data_list = {
                                {'cp', false},
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

    local function tween_cb(number, label)
        local str = comma_value(math_floor(number)) .. '%'
        label:setString(str)
    end

    local function delta_tween_cb_percent(number, label)
        local real_number = math_floor(number)
        
        local str = comma_value(math_abs(real_number)) .. '%'

        if (real_number > 0) then
            str = '▲' .. str
            label:setColor(cc.c4b(0, 255, 0))
            label:setString(str)

        elseif (real_number < 0) then
            str = '▼' .. str
            label:setColor(cc.c4b(255, 0, 0))
            label:setString(str)
        end
    end

    local function delta_tween_cb(number, label)
        local real_number = math_floor(number)
        
        local str = comma_value(math_abs(real_number))
        
        if (real_number > 0) then
            str = '▲' .. str
            label:setColor(cc.c4b(0, 255, 0))
            label:setString(str)
        
        elseif (real_number < 0) then
            str = '▼' .. str
            label:setColor(cc.c4b(255, 0, 0))
            label:setString(str)
        end
    end

    local function delta_tween_finish_cb(number, label)
        local real_number = math_floor(number)

        if (real_number == 0) then
            label:setString('')
        end        
    end

    -- 스탯 증감 표기를 위한 numberLabel 설정
    for _, stat_data in ipairs(l_stat_data_list) do
        local stat_key = stat_data[1]
        local b_use_percent = stat_data[2]
        
        self.m_mNumberLabel[stat_key] = NumberLabel(vars[stat_key .. '_label'], 0, 0.3)

        if (b_use_percent) then
            self.m_mNumberLabel[stat_key]:setTweenCallback(tween_cb)
        end

        if (stat_key ~= 'cp') then
            self.m_mNumberDeltaLabel[stat_key] = NumberLabel(vars[stat_key .. '_label2'], 0, 0.3)

            if (b_use_percent) then
                self.m_mNumberDeltaLabel[stat_key]:setTweenCallback(delta_tween_cb_percent)
                self.m_mNumberDeltaLabel[stat_key]:setTweenFinishCallback(delta_tween_finish_cb)
            else
                self.m_mNumberDeltaLabel[stat_key]:setTweenCallback(delta_tween_cb)
                self.m_mNumberDeltaLabel[stat_key]:setTweenFinishCallback(delta_tween_finish_cb)
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipItem:initButton()
    local vars = self.vars

    for slot_idx = 1, 6 do
        vars['runeSlotBtn' .. slot_idx]:registerScriptTapHandler(function() self:click_emptyRuneCard(slot_idx) end)
    end

    local type = self.m_type
    if (type == 'after') then
        vars['refreshBtn']:setVisible(true)
        vars['refreshBtn']:registerScriptTapHandler(function() self:click_refreshBtn() end)
    end
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
    -- 세트 표시
    self:refreshRuneSet()

end

-------------------------------------
-- function resetRoidList
-------------------------------------
function UI_DragonRunesBulkEquipItem:resetRoidList(b_no_tween)
    local doid = self.m_doid
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
    local type = self.m_type

    for idx = 1, 6 do
        self.m_lRoidList[idx] = dragon_obj['runes'][tostring(idx)]
    end


    for slot_idx = 1, 6 do
        self:refreshRuneCard(slot_idx)
        
        -- 기존에 만약 체크되어있을수도 있으니 체크 해제
        if (type == 'after') then
            self.m_ownerUI:refreshRuneCheck(slot_idx, self.m_lRoidList[slot_idx])
        end
    end
    self:refreshStat(b_no_tween)
    self:refreshRuneSet()
end

-------------------------------------
-- function refreshRuneCard
-- @brief 해당 함수는 룬 카드 변경이 필요할 때만 호출
-------------------------------------
function UI_DragonRunesBulkEquipItem:refreshRuneCard(slot_idx)
    local vars = self.vars

    vars['runeSlot' .. slot_idx]:removeAllChildren()

    local roid = self.m_lRoidList[slot_idx] or ''
            
    if (roid ~= '') then
        local rune_obj = g_runesData:getRuneObject(roid)
        local card = UI_RuneCard(rune_obj)
        
        card.vars['clickBtn']:registerScriptTapHandler(function() self:click_runeCard(roid) end)
        cca.uiReactionSlow(card.root)

        vars['runeSlot' .. slot_idx]:removeAllChildren()
        vars['runeSlot' .. slot_idx]:addChild(card.root)
    end

    if (self.m_type == 'after') then
        local doid = self.m_doid
        local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)
        
        local before_roid = dragon_obj['runes'][tostring(slot_idx)] or ''
        local after_roid = roid or ''

        local b_is_same_rune = (before_roid == after_roid)
        vars['deselectSprite' .. slot_idx]:setVisible(b_is_same_rune)
    end
end

-------------------------------------
-- function refreshStat
-- @brief type에 따라 스탯 표기 다름
-- type : before 인 경우 단순 스탯 표기
-- type : after 인 경우 스탯 + 변화 스탯 표기
-------------------------------------
function UI_DragonRunesBulkEquipItem:refreshStat(b_no_tween)
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

        local before_stat = math_floor(before_status_calc:getFinalStat(stat_key))
        
        local final_stat
        local delta_stat
        
        if (after_status_calc ~= nil) then
            final_stat = after_status_calc:getFinalStat(stat_key)
            local after_stat = math_floor(after_status_calc:getFinalStat(stat_key))
            delta_stat = (after_stat - before_stat)
        else
            final_stat = before_stat
            delta_stat = 0
        end

        self.m_mNumberLabel[stat_key]:setNumber(final_stat, b_no_twin)
        self.m_mNumberDeltaLabel[stat_key]:setNumber(delta_stat, b_no_twin)
    end

    if (after_dragon_obj == nil) then
        self.m_mNumberLabel['cp']:setNumber(before_dragon_obj:getCombatPower(), b_no_tween)
    
    else
        self.m_mNumberLabel['cp']:setNumber(after_dragon_obj:getCombatPower(), b_no_tween)
    end
end

-------------------------------------
-- function refreshRuneSet
-- @brief 룬 세트 효과 리프레시
-------------------------------------
function UI_DragonRunesBulkEquipItem:refreshRuneSet()
    local vars = self.vars

    local type = self.m_type
    local doid = self.m_doid
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

    if (type == 'after') then
         for slot_idx = 1, 6 do
            local after_roid = self.m_lRoidList[slot_idx]
            dragon_obj['runes'][tostring(slot_idx)] = after_roid
        end
    end

    local rune_set_obj = dragon_obj:getStructRuneSetObject()
    local active_set_list = rune_set_obj:getActiveRuneSetList()

    -- 애니 재생 가능한 룬 갯수 설정 (2세트 5개 착용시 처음 슬롯부터 4개까지만)
    local function get_need_equip(set_id)
        local need_equip = 0
        for _, v in ipairs(active_set_list) do
            if (v == set_id) then
                need_equip = need_equip + TableRuneSet:getRuneSetNeedEquip(set_id)
            end
        end

        return need_equip
    end

    -- 해당룬 세트 효과 활성화 되있다면 애니 재생
    local t_equip = {}
    local function show_set_effect(slot_id, set_id)
        for _, v in ipairs(active_set_list) do
            local visual = vars['runeVisual'..slot_id]
            if (v == set_id) then
                if (t_equip[set_id]) then
                    t_equip[set_id] = t_equip[set_id] + 1
                else
                    t_equip[set_id] = 1
                end

                local need_equip = get_need_equip(set_id)
                if (t_equip[set_id] <= need_equip) then
                    local ani_name = TableRuneSet:getRuneSetVisualName(slot_id, set_id)
                    visual:setVisible(true)
                    visual:changeAni(ani_name, true)
                end
                break
            end
        end
    end

    for i = 1, 6 do
        vars['runeVisual'..i]:setVisible(false)

        local roid = dragon_obj['runes'][tostring(i)] or ''
        
        if (roid ~= '') then
            local rune_obj = g_runesData:getRuneObject(roid)
            local set_id = rune_obj['set_id']
            show_set_effect(i, set_id)
        end
    end
end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateRune(slot_idx, roid)
    self.m_ownerUI:refreshRuneCheck(slot_idx, roid)
    self.m_lRoidList[slot_idx] = roid
    self:refreshRuneCard(slot_idx)
    self:refreshStat()
    self:refreshRuneSet()
end

-------------------------------------
-- function simulatePresetRune
-- @brief 프리셋룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulatePresetRune(l_runes)
    self.m_lRoidList = l_runes

    for slot_idx = 1, 6 do        
        self:refreshRuneCard(slot_idx)
    end

    self:refreshStat()
    self:refreshRuneSet()
end

-------------------------------------
-- function focusSlotIndex
-- @brief 룬 슬롯 빛나게
-------------------------------------
function UI_DragonRunesBulkEquipItem:focusSlotIndex(focus_slot_idx)
    local vars = self.vars

    for slot_idx = 1, 6 do
        local lua_name = 'selectSprite' .. slot_idx
        vars[lua_name]:setVisible((slot_idx == focus_slot_idx))
        
        -- 깜빡임 액션
        vars[lua_name]:stopAllActions()
        vars[lua_name]:runAction(cca.flash())
    end
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateDragonRune(doid)
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

    for slot_idx = 1, 6 do
        local roid = dragon_obj['runes'][tostring(slot_idx)]
        self.m_ownerUI:refreshRuneCheck(slot_idx, roid)
        self.m_lRoidList[slot_idx] = roid
        self:refreshRuneCard(slot_idx)
    end

    self:refreshStat()
    self:refreshRuneSet()
end

-------------------------------------
-- function click_runeCard
-- @brief before인 경우 시뮬레이터에 해당 룬 장착
-- @brief after인 경우 해당 룬 시뮬레이터 장착 해제 
-------------------------------------
function UI_DragonRunesBulkEquipItem:click_runeCard(roid)
    local type = self.m_type
    local struct_rune = g_runesData:getRuneObject(roid)
    local slot_idx = struct_rune['slot']

    -- before인 경우 시뮬레이터에 기존 룬 장착
    if (type == 'before') then
        self.m_ownerUI:simulateRune(slot_idx, roid)

    -- after인 경우 
    else
        -- 해당 룬 슬롯 인덱스에 포커싱되있던 경우 장착 해제
        if (slot_idx == self.m_ownerUI:getRuneSlot()) then
            self.m_ownerUI:simulateRune(slot_idx, nil)
        
        -- 해당 룬 슬롯 포커싱 안되있었다면 포커싱
        else
            self.m_ownerUI:changeRuneSlot(slot_idx)
        end
    end
end

-------------------------------------
-- function click_refreshBtn
-------------------------------------
function UI_DragonRunesBulkEquipItem:click_refreshBtn()
    local b_no_tween = false
    self:resetRoidList(b_no_tween) 
    self.m_ownerUI:refreshPrice()
end


-------------------------------------
-- function click_emptyRuneCard
-- @brief 비어있는 룬 칸을 누르면 룬 리스트를 해당 룬 번호로 옮겨주기
-------------------------------------
function UI_DragonRunesBulkEquipItem:click_emptyRuneCard(slot_idx)
    self.m_ownerUI:changeRuneSlot(slot_idx)
end