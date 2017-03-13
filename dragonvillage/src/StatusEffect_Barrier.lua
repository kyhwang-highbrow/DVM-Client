local PARENT = StatusEffect_Trigger

-------------------------------------
-- class StatusEffect_Barrier
-- @brief 방어 횟수가 있는 보호막 
-- @TODO 리소스 확인 및 테스트 필요
-------------------------------------
StatusEffect_Barrier = class(PARENT, {
		m_defCount = 'num',
		m_maxDefCount = 'num',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_Barrier:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect_Barrier:init_top(file_name)
	-- top을 찍지 않는다
end

-------------------------------------
-- function init_buff
-------------------------------------
function StatusEffect_Barrier:init_buff(owner, def_count)
	self.m_defCount = def_count
	self.m_maxDefCount = def_count
	self.m_triggerName = 'hit_shield'
    
	-- 콜백 함수 등록
    char:addListener(self.m_triggerName, self)
end

-------------------------------------
-- function initState
-----------------/--------------------
function StatusEffect_Barrier:initState()
	self:addState('start', StatusEffect_Barrier.st_appear, 'appear', false)
    self:addState('idle', StatusEffect_Barrier.st_idle, 'idle', true)
	self:addState('hit', StatusEffect_Barrier.st_hit, 'hit', false)
	self:addState('end', StatusEffect_Barrier.st_disappear, 'disappear', false)
    self:addState('dying', function(owner, dt) owner:release(); return true end, nil, nil, 10)
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect_Barrier:update(dt)
	-- @TEST 배리어 남은 횟수 표시
	if g_constant:get('DEBUG', 'DISPLAY_SHIELD_HP') then	
		self.m_label:setString(string.format('%d / %d 회', self.m_defCount, self.m_maxDefCount))
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
function StatusEffect_Barrier.st_appear(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('idle') end)
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect_Barrier.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then

    end
end

-------------------------------------
-- function st_hit
-------------------------------------
function StatusEffect_Barrier.st_hit(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('idle') end)
    end
end

-------------------------------------
-- function st_disappear
-------------------------------------
function StatusEffect_Barrier.st_disappear(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:addAniHandler(function() owner:changeState('dying') end)
    end
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_Barrier:getTriggerFunction()
	local trigger_func = function()
		self.m_defCount = self.m_defCount - 1
	
		if (self.m_defCount <= 0) then
			self:changeState('end')
		else
			self:changeState('hit')
		end
	end

	return trigger_func
end