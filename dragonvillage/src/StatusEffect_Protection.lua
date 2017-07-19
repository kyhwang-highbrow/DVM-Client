local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Protection
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Protection = class(PARENT, {
		m_shieldHP = 'number', -- 실드로 보호될 데미지 량
        m_shieldHPOrg = 'number',

		m_label = 'cc.Label',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Protection:init(file_name, body, ...)
	self.m_shieldHP = 0
    self.m_shieldHPOrg = 0

	do
        local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 2, cc.size(250, 100), 1, 1)
        label:setPosition(0, -100)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_rootNode:addChild(label)
        self.m_label = label
    end
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_Protection:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    self:addTrigger('hit_shield', self:getTriggerFunction())
end

-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_Protection:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_Protection:update(dt)
	-- @TEST 보호막 체력량 표시
	if g_constant:get('DEBUG', 'DISPLAY_SHIELD_HP') then	
		self.m_label:setString(string.format('%.1f / %.1f', self.m_shieldHP, self.m_shieldHPOrg))
	end
    
    return PARENT.update(self, dt)
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect_Protection:onApplyOverlab(unit)
    local t_status_effect = self.m_statusEffectTable
    local adj_value = t_status_effect['val_1'] * (unit:getValue() / 100)
	local shield_hp = self.m_owner.m_maxHp * (adj_value / 100)

    -- 해당 정보를 임시 저장
    unit:setParam('shield_hp', shield_hp)

    -- 보호막 가산
    self.m_shieldHP = self.m_shieldHP + shield_hp
    self.m_shieldHPOrg = self.m_shieldHPOrg + shield_hp
end


-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect_Protection:onUnapplyOverlab(unit)
    -- 보호막 감산
    local shield_hp = unit:getParam('shield_hp')

    self.m_shieldHPOrg = self.m_shieldHPOrg - shield_hp
    self.m_shieldHP = math_min(self.m_shieldHP, self.m_shieldHPOrg)
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Protection:getTriggerFunction()
	local trigger_func = function(t_event)
		local damage = t_event['damage']

		if (self.m_shieldHP > damage) then
			-- 데미지를 전부 방어하고 hit effect
			self.m_shieldHP = self.m_shieldHP - damage
			damage = 0
			
            self.m_animator:changeAni('hit', false)
            self:addAniHandler(function()
                self.m_animator:changeAni('idle', true)
            end)
		else
			-- 데미지를 일부만 방어하고 end
			damage = damage - self.m_shieldHP
			self.m_shieldHP = 0
			self:changeState('end')
		end

		t_event['damage'] = damage
		t_event['is_handled'] = true
	end

	return trigger_func
end
