local PARENT = Entity

-------------------------------------
-- class StatusEffect
-------------------------------------
StatusEffect = class(PARENT, {
        m_statusEffectName = 'string',
        
		m_owner = 'Character',		-- 피시전자 & 상태효과의 대상
		m_caster = 'Character',		-- 시전자

        m_lStatus = 'list', -- key:능력치명, value:수치
        m_lStatusAbs = 'list', -- key:능력치명, value:수치

        m_bApply = 'boolean',
        m_bReset = 'boolean',
        m_bDirtyPos = 'bollean',

        m_duration = 'number',  -- 지속 시간. 값이 -1일 경우 무제한
        m_durationTimer = 'number',
        m_overlabCnt = 'number',
        m_maxOverlab = 'number', -- 0:중복 가능, 1:중복 불가능, 중첩 불가능, 지속 시간 초기화, 2이상:숫자만큼 중첩 가능, 지속 시간 초기화

        m_topEffect = 'Animator',
        m_subData = 'none',

		m_type = 'status type',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect:init(file_name, body)
	self.m_lStatus = {}
    self.m_lStatusAbs = {}

    self.m_bApply = false
    self.m_bReset = false
    self.m_bDirtyPos = true

    self.m_duration = -1
    self.m_durationTimer = 0
    self.m_overlabCnt = 0
    self.m_maxOverlab = 0

	self:init_top(file_name)
	self:initState()
end

-------------------------------------
-- function init_top
-- @TODO 탑 위치 가져오기
-------------------------------------
function StatusEffect:init_top(file_name)
    self.m_topEffect = MakeAnimator(file_name)
    self.m_topEffect:setPosition(0, 80)
    self.m_rootNode:addChild(self.m_topEffect.m_node)
end

-------------------------------------
-- function setTargetChar
-------------------------------------
function StatusEffect:setTargetChar(target_char)
    self.m_owner = target_char
end

-------------------------------------
-- function setCasterChar
-------------------------------------
function StatusEffect:setCasterChar(char)
    self.m_caster = char
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- status effect 적용
		owner:statusEffectApply()
		
		-- status effect 시작 된 후에 부가적인 효과 설정
		owner:onStart_StatusEffect()
        
		-- 에니메이션이 0프레임일 경우 즉시 상태를 변경
        local duration = owner.m_animator:getDuration()
        if (duration == 0) then
            owner:changeState('idle')
        else
            owner:addAniHandler(function()
                owner:changeState('idle')
            end)
        end
    end
end

-------------------------------------
-- function st_idle
-------------------------------------
function StatusEffect.st_idle(owner, dt)
    if (owner.m_stateTimer == 0) then
    end
end

-------------------------------------
-- function st_end 
-------------------------------------
function StatusEffect.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- onstart 에서 설정한 부가 효과 해제
		owner:onEnd_StatusEffect()
		
		-- status effect 해제
		owner:statusEffectReset()
		
		owner:addAniHandler(function()
			owner:changeState('dying')
		end)
    end
end

-------------------------------------
-- function onStart_StatusEffect
-------------------------------------
function StatusEffect:onStart_StatusEffect()
end

-------------------------------------
-- function onEnd_StatusEffect
-------------------------------------
function StatusEffect:onEnd_StatusEffect()
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect:update(dt)
    if (self.m_bApply and (self.m_bReset == false)) then
        if (self.m_owner.m_bDead == true) then
            self:changeState('end')
        elseif (self.m_duration ~= -1) then
            self.m_durationTimer = (self.m_durationTimer - dt)

            if (self.m_durationTimer <= 0) then
                self.m_durationTimer = 0
                self:changeState('end')
            end
        end
    end

    local ret = Entity.update(self, dt)

    -- 위치 갱신이 필요한지 확인
    self:checkPosDirty()

    -- 위치 변경 처리
    if self.m_bDirtyPos then
        self:updatePos()
    end

    return ret
end

-------------------------------------
-- function checkPosDirty
-------------------------------------
function StatusEffect:checkPosDirty()
    if (self.pos.x ~= self.m_owner.pos.x) or (self.pos.y ~= self.m_owner.pos.y) then
        self.m_bDirtyPos = true
    end
end

-------------------------------------
-- function updatePos
-------------------------------------
function StatusEffect:updatePos()
    self:setPosition(self.m_owner.pos.x, self.m_owner.pos.y)
    self.m_bDirtyPos = false
end


-------------------------------------
-- function insertStatus
-------------------------------------
function StatusEffect:insertStatus(type, value, is_abs)
    -- 절대값 적용
    if is_abs then
        if (not self.m_lStatusAbs[type]) then
            self.m_lStatusAbs[type] = 0
        end
        self.m_lStatusAbs[type] = self.m_lStatusAbs[type] + value

    -- %값으로 적용
    else
        if (not self.m_lStatus[type]) then
            self.m_lStatus[type] = 0
        end
        self.m_lStatus[type] = self.m_lStatus[type] + value
    end
end

-------------------------------------
-- function statusEffectApply
-------------------------------------
function StatusEffect:statusEffectApply()
    if (self.m_bApply == true) then
        return false
    end

    self:statusEffectApply_()

    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]

    if (t_status_effect['overlab'] > 0) then
        self.m_owner.m_tOverlabStatusEffect[self.m_statusEffectName] = self
    end
	
	-- groggy 옵션이 있다면 stun 상태로 바꾼다. 이외의 부가적인 효과는 개별적으로 구현
	if (t_status_effect['groggy'] == 'true') then 
		self.m_owner:changeState('stun')
	end

    -- character에 status_effect 저장
	self.m_owner:insertStatusEffect(self)

    self.m_bApply = true

    return true
end

-------------------------------------
-- function statusEffectApply_
-------------------------------------
function StatusEffect:statusEffectApply_()
    local tar_char = self.m_owner
    
    -- %능력치 적용
    for key,value in pairs(self.m_lStatus) do
        tar_char.m_statusCalc:addBuffMulti(key, value)
    end

    -- 절대값 능력치 적용
    for key,value in pairs(self.m_lStatusAbs) do
        tar_char.m_statusCalc:addBuffAdd(key, value)
    end
    
    self.m_overlabCnt = (self.m_overlabCnt + 1)
end

-------------------------------------
-- function statusEffectReset
-------------------------------------
function StatusEffect:statusEffectReset()
    if (self.m_bApply == false) then
        return false
    end

    if (self.m_bReset == true) then
        return false
    end

    while (self.m_overlabCnt > 0) do
        self:statusEffectReset_()
    end

    if (0 < self.m_maxOverlab) then
        self.m_owner.m_tOverlabStatusEffect[self.m_statusEffectName] = nil
    end
	
	-- 스턴이었다면 스턴 해제
	if self.m_owner and self.m_owner.m_state == 'stun' then
		self.m_owner:changeState('stun_esc')
	end

	-- 대상이 들고 있는 상태효과 리스트에서 제거
	self.m_owner:removeStatusEffect(self)
    
    self.m_bReset = true

    return true
end

-------------------------------------
-- function statusEffectReset_
-------------------------------------
function StatusEffect:statusEffectReset_()
    local tar_char = self.m_owner
    
    -- %능력치 원상 복귀
    for key,value in pairs(self.m_lStatus) do
        tar_char.m_statusCalc:addBuffMulti(key, -value)
    end

    -- 절대값 능력치 원상 복귀
    for key,value in pairs(self.m_lStatusAbs) do
        tar_char.m_statusCalc:addBuffAdd(key, -value)
    end

    self.m_overlabCnt = (self.m_overlabCnt - 1)
end

-------------------------------------
-- function statusEffectOverlab
-------------------------------------
function StatusEffect:statusEffectOverlab()
    if (self.m_state == 'end' or self.m_state == 'dying') then
        self:changeState('start')
    end

    -- 지속 시간 초기화
    self.m_durationTimer = self.m_duration

    -- 중첩에 의한 능력치 증가
    if (self.m_overlabCnt < self.m_maxOverlab) then
        self:statusEffectApply_()
    end
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function StatusEffect:changeState(state, forced)
    local ret = PARENT.changeState(self, state, forced)

    if (ret == true) and (state ~= 'dying') and (self.m_topEffect) then
        local animation_name = string.gsub(self.m_tStateAni[state], 'center', 'top')
        self.m_topEffect:changeAni(animation_name, self.m_tStateAniLoop[state])
    end

    return ret
end








-------------------------------------
-- function getTypeName
-------------------------------------
function StatusEffect:getTypeName()
    return self.m_statusEffectName
end