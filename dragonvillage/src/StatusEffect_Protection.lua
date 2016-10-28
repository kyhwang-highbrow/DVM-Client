local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Protection
-------------------------------------
StatusEffect_Protection = class(PARENT, {
		m_StatusEffect_ProtectionHP = 'number', -- 실드로 보호될 데미지 량
        m_StatusEffect_ProtectionHPOrg = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Protection:init(file_name, body, ...)
    self:initState()
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
    self.m_StatusEffect_ProtectionHP = shield_hp
    self.m_StatusEffect_ProtectionHPOrg = shield_hp
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
	self:addState('disappear', StatusEffect_Protection.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) owner:release(); return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_Protection:update(dt)
    local ret = PARENT.update(self, dt)
	cclog(self.m_state)
	if (self.m_state == 'idle') then
		self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

		-- 1. 종료 : 시간 초과
		self.m_durationTimer = self.m_durationTimer - dt
		if (self.m_durationTimer < 0) then
			self:changeState('disappear')
			return
		end

		-- 2. 종료 : 캐릭터 사망
		if (not self.m_owner) or self.m_owner.m_bDead then
			self:changeState('disappear')
		end
	end

    return ret
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
function StatusEffect_Protection:onTrigger(char, damage)
	-- 1. 방어막 유지 여부 계산
    if (self.m_StatusEffect_ProtectionHP <= 0) then
        self:changeState('disappear')
        return false, damage
    end
	
	-- 2. 실드 에너지 데미지 적용
    self.m_StatusEffect_ProtectionHP = self.m_StatusEffect_ProtectionHP - damage

	-- 3. 데미지 계산 후 방어막 유지 여부 계산
    if (self.m_StatusEffect_ProtectionHP <= 0) then
        self:changeState('disappear')
        return false, damage + self.m_StatusEffect_ProtectionHP
    end

    self:changeState('hit')

    return true, 0
end
