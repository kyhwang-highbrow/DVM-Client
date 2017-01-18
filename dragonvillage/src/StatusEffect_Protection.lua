local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Protection
-- @breif HP있는 실드 보호막 + resist 보호막
-------------------------------------
StatusEffect_Protection = class(PARENT, {
		m_StatusEffect_ProtectionHP = 'number', -- 실드로 보호될 데미지 량
        m_StatusEffect_ProtectionHPOrg = 'number',

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
-- function init_buff
-------------------------------------
function StatusEffect_Protection:init_buff(char, shield_hp)
    self.m_StatusEffect_ProtectionHP = shield_hp or 519
    self.m_StatusEffect_ProtectionHPOrg = shield_hp or 519
	self.m_triggerName = 'hit_shield'

    -- 콜백 함수 등록
    char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_Protection:initState()
	self:addState('start', StatusEffect_Protection.st_appear, 'appear', false)
    self:addState('idle', StatusEffect_Protection.st_idle, 'idle', true)
	self:addState('hit', StatusEffect_Protection.st_hit, 'hit', false)
	self:addState('end', StatusEffect_Protection.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) owner:release(); return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_Protection:update(dt)
	if DISPLAY_SHIELD_HP then	
		self.m_label:setString(string.format('%.1f / %.1f', self.m_StatusEffect_ProtectionHP, self.m_StatusEffect_ProtectionHPOrg))
	end
	if (self.m_state == 'idle') then
		-- 1. 종료 : 시간 초과
		self.m_durationTimer = self.m_durationTimer - dt
		if (self.m_durationTimer < 0) then
			self:changeState('end')
			return
		end

		-- 2. 종료 : 캐릭터 사망
		if (not self.m_owner) or self.m_owner.m_bDead then
			self:changeState('end')
		end
	end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_appear
-------------------------------------
function StatusEffect_Protection.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('idle') end)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Protection.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then

    end
end

-------------------------------------
-- function st_hit
-------------------------------------
function StatusEffect_Protection.st_hit(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('idle') end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function StatusEffect_Protection.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('dying') end)
    end
end

-------------------------------------
-- function onTrigger
-------------------------------------
function StatusEffect_Protection:onTrigger(t_event, char, damage)
	local damage = damage or 0

	-- 1. 방어막 유지 여부 계산
    if (self.m_StatusEffect_ProtectionHP <= 0) then
        self:changeState('end')
        return false, damage
    end

	-- 2. 실드 에너지 데미지 적용 // 
	self.m_StatusEffect_ProtectionHP = self.m_StatusEffect_ProtectionHP - damage

	-- 3. 데미지 계산 후 방어막 유지 여부 계산
    if (self.m_StatusEffect_ProtectionHP <= 0) then
        self:changeState('end')
        return false, damage + self.m_StatusEffect_ProtectionHP
    end

    self:changeState('hit')

    return true, 0
end
