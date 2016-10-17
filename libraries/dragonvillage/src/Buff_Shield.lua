local PARENT = Entity
-------------------------------------
-- class Buff_Shield
-------------------------------------
Buff_Shield = class(PARENT, IEventListener:getCloneTable(), {
        m_owner = 'Character',
        m_Buff_ShieldHP = 'number', -- 실드로 보호될 데미지 량
        m_Buff_ShieldHPOrg = 'number',
		m_duration2 = 'number',
		m_durationTimer2 = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Buff_Shield:init(file_name, body, ...)
    self:initState()
end


-------------------------------------
-- function init_buff
-------------------------------------
function Buff_Shield:init_buff(owner, shield_hp, duration)
    self.m_owner = owner

    -- 기존 실드 삭제 (실드는 무조건 1개만 있다고 가정)
    for i,v in pairs(owner.m_lEventListener) do
        if isInstanceOf(v, Buff_Shield) then
            v:changeState('dying')
            table.remove(owner.m_lEventListener, i)
            break
        end
    end

    self.m_Buff_ShieldHP = shield_hp
    self.m_Buff_ShieldHPOrg = shield_hp
	self.m_duration2 = duration
	self.m_durationTimer2 = 0
    self:setPosition(owner.pos.x, owner.pos.y)

    -- 콜백 함수 등록
    self.m_owner:addListener('hit_shield', self)

    self:changeState('appear')
end

-------------------------------------
-- function initState
-------------------------------------
function Buff_Shield:initState()
	self:addState('appear', Buff_Shield.st_appear, 'appear', false)
    self:addState('idle', Buff_Shield.st_idle, 'idle', true)
	self:addState('hit', Buff_Shield.st_hit, 'hit', false)
	self:addState('disappear', Buff_Shield.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) owner:release(); return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function Buff_Shield:update(dt)
    local ret = PARENT.update(self, dt)

	if (self.m_state == 'idle') then
		self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)

		-- 1. 종료 : 시간 초과
		self.m_durationTimer2 = self.m_durationTimer2 + dt
		if (self.m_durationTimer2 > self.m_duration2) then
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
function Buff_Shield.st_appear(owner, dt)
	if (owner.m_stateTimer > owner.m_animator:getDuration()) then
		owner:changeState('idle')
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function Buff_Shield.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
		
    end
end

-------------------------------------
-- function st_hit
-------------------------------------
function Buff_Shield.st_hit(owner, dt)
	if (owner.m_stateTimer == 0 ) then
		owner.m_animator:addAniHandler(function() owner:changeState('idle') end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function Buff_Shield.st_disappear(owner, dt)
	if (owner.m_stateTimer > owner.m_animator:getDuration()) then
		owner:changeState('dying')
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function Buff_Shield:onEvent(event_name, ...)
    if (event_name == 'hit_shield') then
        return self:undergoAttackCB(...)
    end
end

-------------------------------------
-- function undergoAttackCB
-------------------------------------
function Buff_Shield:undergoAttackCB(char, damage)
	-- 1. 방어막 유지 여부 계산
    if (self.m_Buff_ShieldHP <= 0) then
        self:changeState('disappear')
        return false, damage
    end
	
	-- 2. 실드 에너지 데미지 적용
    self.m_Buff_ShieldHP = self.m_Buff_ShieldHP - damage

	-- 3. 데미지 계산 후 방어막 유지 여부 계산
    if (self.m_Buff_ShieldHP <= 0) then
        self:changeState('disappear')
        return false, damage + self.m_Buff_ShieldHP
    end

    self:changeState('hit')

    return true, 0
end

-------------------------------------
-- function release
-------------------------------------
function Buff_Shield:release()
	self.m_owner:removeListener('hit_shield', self)
	PARENT.release(self)
end