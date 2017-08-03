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
end

-------------------------------------
-- function setMana
-- @param updated_int : 정수값이 갱신되었는지 여부
-------------------------------------
function UI_Game:setMana(mana, updated_int)
    local vars = self.vars

    local decimal_part = ((mana * 100) % 100) / 100
    local integer_part = math_floor(mana)
    local cur_mana_idx = integer_part + 1

    if (updated_int) then
        vars['manaLabel']:setString(integer_part)

        -- 마나 텍스트의 위치를 이동시킴
        do
            local slot_idx = math_min(cur_mana_idx, MAX_MANA)
            local socket_x = vars['manaVisual'].m_node:getSocketPosX('ingame_panel_mana_slot_' .. slot_idx)
            local pos_x = vars['manaVisual']:getPositionX() + socket_x
            vars['manaSprite']:setPositionX(pos_x)
        end
    
        -- 가득찬 마나 연출
        for i = 1, integer_part do
            local visual = vars['manaSlotVisual' .. i]

            if (visual.m_currAnimation == 'mana_gg') then
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
        local i = cur_mana_idx
        local visual = vars['manaSlotVisual' .. i]
        if (visual) then
            local guage = math_floor(decimal_part * 100)
            visual:setFrame(guage)
        end
    end
end