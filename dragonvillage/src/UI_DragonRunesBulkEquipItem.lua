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
    local doid = self.m_doid
    local dragon_obj = g_dragonsData:getDragonDataFromUid(doid)

    -- 룬 카드 생성
    do
        for idx = 1, 6 do
            local roid = self.m_lRoidList[idx]
            
            if (roid ~= nil) then
                local rune_obj = g_runesData:getRuneObject(roid)
                local card = UI_RuneCard(rune_obj)
            
                vars['runeSlot' .. idx]:addChild(card.root)        
            end
        end
    end

    -- 스탯 표기
    do
        -- 전투력 
        local cp = comma_value(dragon_obj:getCombatPower())
        vars['cp_label']:setString(cp)

        -- 능력치 계산기
        local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(dragon_obj)

        local hp = status_calc:getFinalStatDisplay('hp')
        local atk = status_calc:getFinalStatDisplay('atk')
        local def = status_calc:getFinalStatDisplay('def')
        local aspd = status_calc:getFinalStatDisplay('aspd', use_percent)
        local cri_chance = status_calc:getFinalStatDisplay('cri_chance', use_percent)
        local cri_dmg = status_calc:getFinalStatDisplay('cri_dmg', use_percent)
        local hit_rate = status_calc:getFinalStatDisplay('hit_rate')
        local avoid = status_calc:getFinalStatDisplay('avoid')
        local cri_avoid = status_calc:getFinalStatDisplay('cri_avoid')
        local accuracy = status_calc:getFinalStatDisplay('accuracy')
        local resistance = status_calc:getFinalStatDisplay('resistance')
        
        vars['hp_label']:setString(hp)
        vars['atk_label']:setString(atk)
        vars['def_label']:setString(def)
        vars['aspd_label']:setString(aspd)
        vars['cri_chance_label']:setString(cri_chance)
        vars['cri_dmg_label']:setString(cri_dmg)
        vars['hit_rate_label']:setString(hit_rate)
        vars['avoid_label']:setString(avoid)
        vars['cri_avoid_label']:setString(cri_avoid)
        vars['accuracy_label']:setString(accuracy)
        vars['resistance_label']:setString(resistance)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonRunesBulkEquipItem:initButton()
    local vars = self.vars

end

-------------------------------------
-- function refresh
-- @brief 룬 카드 갱신, 스탯 갱신
-------------------------------------
function UI_DragonRunesBulkEquipItem:refresh()
    local vars = self.vars


end

-------------------------------------
-- function simulateRune
-- @brief 룬 한개 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateRune(roid)
    
end

-------------------------------------
-- function simulateDragonRune
-- @brief 특정 드래곤의 룬 장착
-------------------------------------
function UI_DragonRunesBulkEquipItem:simulateDragonRune(doid)

end
