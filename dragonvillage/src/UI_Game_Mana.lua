-------------------------------------
-- function initManaUI
-------------------------------------
function UI_Game:initManaUI()
	local vars = self.vars

    vars['manaLabel']:setString(0)

    for i = 1, MAX_MANA do
        local visual = vars['manaSlotVisual' .. i]
        visual:changeAni('mana_gg', false)
        visual:setAnimationPause(true)
        visual:setFrame(0)
    end

    self.m_bVisible_ManaUI = true
    self.m_posX_ManaUI = vars['manaVisual']:getPositionX()
    self.m_posY_ManaUI = vars['manaVisual']:getPositionY()
end

-------------------------------------
-- function setMana
-- @param updated_int : 정수값이 갱신되었는지 여부
-------------------------------------
function UI_Game:setMana(mana, updated_int, accel_value)
    local vars = self.vars

    local decimal_part = ((mana * 100) % 100) / 100
    local integer_part = math_floor(mana)
    local cur_mana_idx = integer_part + 1

    if (updated_int) then
        vars['manaLabel']:setString(integer_part)

        -- 마나 텍스트의 위치를 이동시킴
        do
            local slot_idx = math_min(integer_part, MAX_MANA)
            slot_idx = math_max(slot_idx, 1)

            local socket_x = vars['manaVisual'].m_node:getSocketPosX('ingame_panel_mana_slot_' .. slot_idx)
            local pos_x = vars['manaVisual']:getPositionX() + socket_x
            vars['manaSprite']:setPositionX(pos_x)
        end
    
        -- 가득찬 마나 연출
        for i = 1, integer_part do
            local visual = vars['manaSlotVisual' .. i]

            if (string.find(visual.m_currAnimation, 'mana_gg')) then
                visual:changeAni('mana_full_appear', false)
                visual:setAnimationPause(false)
                visual:addAniHandler(function()
                    visual:changeAni('mana_full_idle', true)
                end)
            end
        end
    
        -- 빈칸 마나
        for i = cur_mana_idx, MAX_MANA do
            local visual = vars['manaSlotVisual' .. i]
            visual:changeAni('mana_gg', false)
            visual:setAnimationPause(true)
            visual:setFrame(0)
        end
    end

    -- 현재 차고 있는 마나
    do
        local world = self.m_gameScene.m_gameWorld
        local accel_value = accel_value or 0
        local ani
        
        -- 가속 및 감속 여부에 따라 비주얼 변경
        if (accel_value > 0) then
            ani = 'mana_gg_buff'

            vars['manaConditionVisual']:setVisible(true)
            vars['manaConditionVisual']:changeAni('mana_condition_buff', true, true)

        elseif (accel_value < 0) then
            ani = 'mana_gg_debuff'

            vars['manaConditionVisual']:setVisible(true)
            vars['manaConditionVisual']:changeAni('mana_condition_debuff', true, true)
        else
            ani = 'mana_gg'

            vars['manaConditionVisual']:setVisible(false)
        end

        local i = cur_mana_idx
        local visual = vars['manaSlotVisual' .. i]
        if (visual) then
            local guage = math_floor(decimal_part * 100)
            
            visual:changeAni(ani, false)
            visual:setAnimationPause(true)
            visual:setFrame(guage)
        end
    end
end

-------------------------------------
-- function setManaZero
-------------------------------------
function UI_Game:setManaZero()
	if (self.vars['manaNotSprite']) then
    	self.vars['manaNotSprite']:setVisible(true)
	end
end
