local PARENT = Entity

-------------------------------------
-- class StatusEffect
-------------------------------------
StatusEffect = class(PARENT, {
        m_statusEffectTable = 'table',
        m_statusEffectName = 'string',
        m_overlabClass = 'class',
        
		m_owner = 'Character',		-- 피시전자 & 상태효과의 대상
		
        m_lStatus = 'list', -- key:능력치명, value:수치
        m_lStatusAbs = 'list', -- key:능력치명, value:수치

        m_lUnit = 'table',  -- 해당 상태효과에 추가된 StatusEffectUnit의 리스트
        m_mUnit = 'table',  -- 시전자의 char_id값을 키값으로 StatusEffectUnit의 리스트를 가지는 맵

        m_bDead = 'boolean',
        m_bApply = 'boolean',
        m_bDirtyPos = 'bollean',
        m_bHarmful = 'boolean',
        m_bAbs = 'boolean',     -- 절대값

        m_bInfinity = 'boolean', -- 타이머없이 계속 유지되는지 여부
        m_latestTimer = 'number',

        m_overlabCnt = 'number',
        m_maxOverlab = 'number', -- 0:중복 가능, 1:중복 불가능, 중첩 불가능, 지속 시간 초기화, 2이상:숫자만큼 중첩 가능, 지속 시간 초기화

        m_topEffect = 'Animator',

		m_type = 'status type',
        m_category = 'status category',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect:init(file_name, body)
    self.m_overlabClass = StatusEffectUnit

	self.m_lStatus = {}
    self.m_lStatusAbs = {}

    self.m_lUnit = {}
    self.m_mUnit = {}

    self.m_bDead = false
    self.m_bApply = false
    self.m_bDirtyPos = true
    self.m_bHarmful = false

    self.m_bInfinity = false
    self.m_latestTimer = 0

    self.m_overlabCnt = 0
    self.m_maxOverlab = 0

	self:init_top(file_name)
	self:initState()
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect:initFromTable(t_status_effect, target_char)
    self.m_statusEffectTable = t_status_effect
    self.m_statusEffectName = self.m_statusEffectName or t_status_effect['name']
    self.m_type = t_status_effect['type']
    self.m_category = t_status_effect['category']
    self.m_maxOverlab = t_status_effect['overlab']
    self.m_owner = target_char
    self.m_bHarmful = StatusEffectHelper:isHarmful(t_status_effect['type'])
    self.m_bAbs = (t_status_effect['abs_switch'] and (t_status_effect['abs_switch'] == 1) or false)

    -- status 배율 지정
    do
        for _, type in ipairs(L_STATUS_TYPE) do
            local value = t_status_effect[type] or 0
            if (value ~= 0) then
                self:insertStatus(type, value, self.m_bAbs)
            end
        end
    end
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
-- function initState
-------------------------------------
function StatusEffect:initState()
    self:addState('start', StatusEffect.st_start, 'center_start', false)
    self:addState('idle', StatusEffect.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function setName
-------------------------------------
function StatusEffect:setName(name)
    self.m_statusEffectName = name
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect:setOverlabClass(overlab_class)
    self.m_overlabClass = overlab_class
end

-------------------------------------
-- function release
-------------------------------------
function StatusEffect:release()
    -- 모든 효과 해제
    self:unapplyAll()

    self:setDead()

    PARENT.release(self)
end

-------------------------------------
-- function setDead
-------------------------------------
function StatusEffect:setDead()
    if (self.m_bDead) then return end

    -- 대상이 들고 있는 상태효과 리스트에서 제거
	self.m_owner:removeStatusEffect(self)

    self.m_bDead = true
end

-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 중첩에 상관없이 한번만 적용되어야하는 효과 적용
        owner:apply()
		
		-- 힐 사운드
		if (StatusEffectHelper:isHelpful(owner.m_type)) then
			SoundMgr:playEffect('SFX', 'sfx_buff_get')
		end

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

    if (owner.m_overlabCnt <= 0) then
        owner:changeState('end')
    end
end

-------------------------------------
-- function st_end 
-------------------------------------
function StatusEffect.st_end(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 모든 효과 해제
		owner:unapplyAll()
		
        -- 에니메이션이 0프레임일 경우 즉시 상태를 변경
        local duration = owner.m_animator:getDuration()
        if (duration == 0) then
            owner:setDead()
            owner:changeState('dying')
        else
            owner:addAniHandler(function()
                owner:setDead()
                owner:changeState('dying')
            end)
        end
    end
end

-------------------------------------
-- function update
-------------------------------------
function StatusEffect:update(dt)
    if (self.m_bApply) then
        -- 대상자의 디법 유지 시간 관련 스텟을 실시간으로 적용
        local modified_dt

        if (self.m_bHarmful) then
            if (self.m_owner:isImmuneSE()) then
                -- 즉시 해제
                modified_dt = 9999
            else
                local debuff_time = self.m_owner:getStat('debuff_time')
                debuff_time = math_max(debuff_time, -100)

                modified_dt = dt / (1 + (debuff_time / 100))
            end
        else
            modified_dt = dt
        end

        -- 개별 update
        for _, list in pairs(self.m_mUnit) do
            local t_remove = {}

            for i, unit in ipairs(list) do
                if (unit:update(dt, modified_dt)) then
                    table.insert(t_remove, 1, i)
                    self:unapplyOverlab(unit)
                end
            end

            for i, v in ipairs(t_remove) do
                table.remove(list, v)

                local idx = table.find(self.m_lUnit, v)
                table.remove(self.m_lUnit, idx)
            end
        end
            
        if (self.m_overlabCnt <= 0) then
            self:changeState('end')
        end
    end

    local ret = PARENT.update(self, dt)

    -- 위치 갱신이 필요한지 확인
    self:checkPosDirty()

    -- 위치 변경 처리
    if self.m_bDirtyPos then
        self:updatePos()
    end

    -- 타이머
    self:updateLatestTimer(dt)

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
-- function updateLatestTimer
-------------------------------------
function StatusEffect:updateLatestTimer(dt)
    if (self:isInfinity()) then return end

    self.m_latestTimer = self.m_latestTimer - dt
end

-------------------------------------
-- function insertStatus
-------------------------------------
function StatusEffect:insertStatus(type, value, is_abs)
    local is_abs = is_abs

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
-- function apply
-- @brief 해당 상태 효과가 시작시 한번만 적용되어야하는 효과를 적용
-------------------------------------
function StatusEffect:apply()
    if (self.m_bApply) then return false end

    local t_status_effect = self.m_statusEffectTable

    -- groggy 옵션이 있다면 stun 상태로 바꾼다. 이외의 부가적인 효과는 개별적으로 구현
	if (t_status_effect and t_status_effect['groggy'] == 'true') then
		self.m_owner:addGroggy(self.m_statusEffectName)
	end

    self.m_bApply = true

    self:onStart()

    return true
end

-------------------------------------
-- function onStart
-- @brief 해당 상태 효과가 시작시 호출
-------------------------------------
function StatusEffect:onStart()
end

-------------------------------------
-- function unapply
-- @brief 해당 상태 효과가 종료시 한번만 해제되어야하는 효과를 해제c
-------------------------------------
function StatusEffect:unapply()
    if (not self.m_bApply) then return false end
    
    -- groggy 옵션이 있다면 해제
    local t_status_effect = self.m_statusEffectTable
    if (t_status_effect and t_status_effect['groggy'] == 'true') then
        self.m_owner:removeGroggy(self.m_statusEffectName)
    end
	
	self.m_bApply = false

    self:onEnd()

    return true
end

-------------------------------------
-- function onEnd
-- @brief 해당 상태 효과가 종료시 호출
-------------------------------------
function StatusEffect:onEnd()
end

-------------------------------------
-- function applyOverlab
-- @brief 중첩될때마다 적용되어야하는 효과를 적용
-------------------------------------
function StatusEffect:applyOverlab(unit)
    local b = unit:onApply(self.m_lStatus, self.m_lStatusAbs)

    self.m_overlabCnt = (self.m_overlabCnt + 1)

    self:onApplyOverlab(unit)
            
    return b
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect:onApplyOverlab(unit)
end

-------------------------------------
-- function unapplyOverlab
-- @brief 중첩될때마다 적용되어야하는 효과를 해제
-------------------------------------
function StatusEffect:unapplyOverlab(unit)
    local b = unit:onUnapply(self.m_lStatus, self.m_lStatusAbs)

    self.m_overlabCnt = (self.m_overlabCnt - 1)

    self:onUnapplyOverlab(unit)
            
    return b
end

-------------------------------------
-- function onUnapplyOverlab
-- @brief 해당 상태효과가 중첩 해제될시마다 호출
-------------------------------------
function StatusEffect:onUnapplyOverlab(unit)
end

-------------------------------------
-- function unapplyAll
-------------------------------------
function StatusEffect:unapplyAll()
    -- 기본 효과 해제
    do
        self:unapply()
    end
    
    -- 중첩 효과 해제
    do
        for _, unit in pairs(self.m_lUnit) do
            self:unapplyOverlab(unit)
        end

        self.m_lUnit = {}
        self.m_mUnit = {}
        self.m_overlabCnt = 0

        -- @EVENT : 스탯 변화 적용(최대 체력)
		self.m_owner:dispatch('stat_changed')
    end
end

-------------------------------------
-- function addOverlabUnit
-------------------------------------
function StatusEffect:addOverlabUnit(caster, skill_id, value, source, duration)
    local char_id = caster:getCharId()
    local skill_id = skill_id or 999999

    if (self.m_state == 'end' or self.m_state == 'dying') then
        self:changeState('start')
    end

    local new_unit = self.m_overlabClass(self:getTypeName(), self.m_owner, caster, skill_id, value, source, duration)
    
    local t_status_effect = self.m_statusEffectTable
    
    -- 갱신(삭제 후 새로 추가하는 방식으로 처리함. 리스트의 가장 뒤로 보내야하기 때문)
    if (self.m_mUnit[char_id]) then
        if (t_status_effect['overlab_option'] ~= 1) then
            for i, unit in ipairs(self.m_mUnit[char_id]) do
                if (unit.m_skillId == skill_id) then
                    -- 주체와 스킬id가 같을 경우 삭제 후 추가 시킴
                    local unit = table.remove(self.m_mUnit[char_id], i)
                    self:unapplyOverlab(unit)

                    local idx = table.find(self.m_lUnit, unit)
                    table.remove(self.m_lUnit, idx)
                
                    break
                end
            end
        end
    else
        self.m_mUnit[char_id] = {}
    end

    -- 중첩 정보 추가
    table.insert(self.m_mUnit[char_id], new_unit)
    table.insert(self.m_lUnit, new_unit)
    
    -- 중첩시 효과 적용
    self:applyOverlab(new_unit)
    
    -- 최대 중첩 횟수를 넘을 경우 젤 앞의 unit을 삭제
    if (self.m_maxOverlab > 0 and self.m_overlabCnt > self.m_maxOverlab) then
        local unit = table.remove(self.m_mUnit[char_id], 1)
        self:unapplyOverlab(unit)

        local idx = table.find(self.m_lUnit, unit)
        table.remove(self.m_lUnit, idx)
    end

    -- @EVENT : 스탯 변화 적용(최대 체력)
	self.m_owner:dispatch('stat_changed')

    -- 해당 상태효과의 종료시간을 구해서 저장
    local latestTime = self:calcLatestTime()
    self.m_bInfinity = (latestTime == -1)
    self.m_latestTimer = latestTime
end

-------------------------------------
-- function calcLatestTime
-- @brief 해당 상태효과의 종료시간을 얻는다
-------------------------------------
function StatusEffect:calcLatestTime()
    local latestTimer = 0

    for _, unit in pairs(self.m_lUnit) do
        if (unit.m_durationTimer ~= -1) then
            latestTimer = math_max(latestTimer, unit.m_durationTimer)
        else
            latestTimer = -1
            return latestTimer
        end
    end

    return latestTimer
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function StatusEffect:changeState(state, forced)
    if (self.m_state == state and isExistValue(self.m_state, 'end', 'dying')) then return false end

    local ret = PARENT.changeState(self, state, forced)

    if (ret) and (state ~= 'dying') and (self.m_topEffect) then
        local animation_name = string.gsub(self.m_tStateAni[state], 'center', 'top')
        self.m_topEffect:changeAni(animation_name, self.m_tStateAniLoop[state])
    end

    return ret
end

-------------------------------------
-- function setTemporaryPause
-------------------------------------
function StatusEffect:setTemporaryPause(pause)
    if (PARENT.setTemporaryPause(self, pause)) then
        if (pause) then
            if (self.m_animator) then
                self.m_animator:setVisible(false)
            end
        else
            if (self.m_animator) then
                self.m_animator:setVisible(true)
            end
        end

        return true
    end

    return false
end





-------------------------------------
-- function getTypeName
-------------------------------------
function StatusEffect:getTypeName()
    return self.m_statusEffectName
end

-------------------------------------
-- function isInfinity
-------------------------------------
function StatusEffect:isInfinity()
    return self.m_bInfinity
end

-------------------------------------
-- function getLatestTimer
-------------------------------------
function StatusEffect:getLatestTimer()
    return self.m_latestTimer
end

-------------------------------------
-- function getOverlabUnitList
-------------------------------------
function StatusEffect:getOverlabUnitList()
    return self.m_lUnit
end