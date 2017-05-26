local PARENT = StatusEffect_Trigger

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
	-- 보호막은 트리거 쿨타임을 적용하지 않는다.
	self.m_statusEffectInterval = 0

    self:initState()
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
-- function init_top
-------------------------------------
function StatusEffect_Protection:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function init_trigger
-------------------------------------
function StatusEffect_Protection:init_trigger(char, shield_hp)
	PARENT.init_trigger(self, char, 'hit_shield', nil)
	
	self.m_shieldHP = shield_hp or 519
    self.m_shieldHPOrg = shield_hp or 519
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Protection:initState()
    PARENT.initState(self)

	self:addState('start', PARENT.st_start, 'appear', false)
    self:addState('idle', PARENT.st_idle, 'idle', true)
	self:addState('end', PARENT.st_end, 'disappear', false)
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
