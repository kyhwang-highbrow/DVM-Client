local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_Protection
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Protection = class(PARENT, {
		m_shieldHP = 'number', -- 실드로 보호될 데미지 량
        m_shieldHPOrg = 'number',

        m_shieldCount = 'number',   -- 데미지 무효화 횟수
        m_shieldCountOrg = 'number',

        m_bUseCount = 'boolean',    -- 횟수로 방어하는지 여부

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

    self.m_shieldCount = 0
    self.m_shieldCountOrg = 0

    self.m_bUseCount = false
    self.m_animator:setIgnoreLowEndMode(true)
	do
        local label = cc.Label:createWithTTF('', Translate:getFontPath(), 20, 2, cc.size(250, 100), 1, 1)
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

    self.m_bUseCount = self:isCountShield()

    self:addTrigger('hit_barrier', self:getTriggerFunction())
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
    if (self.m_bUseCount) then
        local shield_count = unit:getValue()

        -- 해당 정보를 임시 저장
        unit:setParam('shield_count', shield_count)

        -- 보호막 가산
        self.m_shieldCount = self.m_shieldCount + shield_count
        self.m_shieldCountOrg = self.m_shieldCountOrg + shield_count
    else
        local t_status_effect = self.m_statusEffectTable
        local adj_value = t_status_effect['val_1'] * (unit:getValue() / 100)
        local shield_hp = unit:getStandardStat() * (adj_value / 100)

	    
        -- 해당 정보를 임시 저장
        unit:setParam('shield_hp', shield_hp)

        -- 보호막 가산
        self.m_shieldHP = self.m_shieldHP + shield_hp
        self.m_shieldHPOrg = self.m_shieldHPOrg + shield_hp
    end
end


-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect_Protection:onUnapplyOverlab(unit)
    -- 보호막 감산
    if (self.m_bUseCount) then
        local shield_count = unit:getParam('shield_count')

        self.m_shieldCountOrg = self.m_shieldCountOrg - shield_count
        self.m_shieldCount = math_min(self.m_shieldCount, self.m_shieldCountOrg)
    else
        local t_status_effect = self.m_statusEffectTable
        local adj_value = t_status_effect['val_1'] * (unit:getValue() / 100)
        local shield_hp = unit:getStandardStat() * (adj_value / 100)

        self.m_shieldHPOrg = math_max(self.m_shieldHPOrg - shield_hp, 0)
        self.m_shieldHP = math_min(self.m_shieldHP, self.m_shieldHPOrg)
    end
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Protection:getTriggerFunction()
	local trigger_func = function(t_event)
        local damage = t_event['damage']

        if (self.m_bUseCount) then
            self.m_shieldCount = self.m_shieldCount - 1
            damage = 0

            if (self.m_shieldCount <= 0) then
                self:changeState('end')
            end
        else
            if (self.m_shieldHP > damage) then
			    -- 데미지를 전부 방어하고 hit effect
			    self.m_shieldHP = self.m_shieldHP - damage
			    damage = 0
		    else
			    -- 데미지를 일부만 방어하고 end
			    damage = damage - self.m_shieldHP
			    self.m_shieldHP = 0
			    self:changeState('end')
		    end
        end

        t_event['damage'] = damage
		t_event['is_handled'] = true
	end

	return trigger_func
end

-------------------------------------
-- function isCountShield
-------------------------------------
function StatusEffect_Protection:isCountShield()
    local t_status_effect = self.m_statusEffectTable

    if (type(t_status_effect['val_1']) ~= 'string') then
        return false
    end

    return (t_status_effect['val_1'] == 'hit_abs')
end