local PARENT = Entity

-------------------------------------
-- class StatusEffect
-------------------------------------
StatusEffect = class(PARENT, {
        m_statusEffectName = 'string',
        
		m_owner = 'Character',		-- 피시전자 & 상태효과의 대상
		
        m_lStatus = 'list', -- key:능력치명, value:수치
        m_lStatusAbs = 'list', -- key:능력치명, value:수치

        m_mUnit = 'table',  -- 시전자의 char_id값을 키값으로 StatusEffectUnit의 리스트를 가지는 맵

        m_bApply = 'boolean',
        m_bReset = 'boolean',
        m_bDirtyPos = 'bollean',
        m_bHarmful = 'boolean',

        m_overlabCnt = 'number',
        m_maxOverlab = 'number', -- 0:중복 가능, 1:중복 불가능, 중첩 불가능, 지속 시간 초기화, 2이상:숫자만큼 중첩 가능, 지속 시간 초기화

        m_topEffect = 'Animator',

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

    self.m_mUnit = {}

    self.m_bApply = false
    self.m_bReset = false
    self.m_bDirtyPos = true
    self.m_bHarmful = false

    self.m_overlabCnt = 0
    self.m_maxOverlab = 0

	self:init_top(file_name)
	self:initState()
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect:initFromTable(t_status_effect, target_char)
    self.m_statusEffectName = t_status_effect['name']
    self.m_type = t_status_effect['type']
    self.m_maxOverlab = t_status_effect['overlab']
    self.m_owner = target_char
    self.m_bHarmful = StatusEffectHelper:isHarmful(t_status_effect['type'])

    -- status 배율 지정
    do
        local is_abs = (t_status_effect['abs_switch'] and (t_status_effect['abs_switch'] == 1) or false)

        for _, type in ipairs(L_STATUS_TYPE) do
            local value = t_status_effect[type] or 0
            if (value ~= 0) then
                self:insertStatus(type, value, is_abs)
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
-- function release
-------------------------------------
function StatusEffect:release()
    PARENT.release(self)

    self:resetAll()
end

-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 공통 효과 적용
		owner:applyCommon()
		
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
		owner:resetAll()
		
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
    if (self.m_bApply and not self.m_bReset) then
        if (self.m_owner.m_bDead) then
            self:changeState('end')

        else
            -- 대상자의 디법 유지 시간 관련 스텟을 실시간으로 계산
            local modified_dt

            if (self.m_bHarmful) then
                local rate = 1 / (1 + (self.m_owner:getStat('debuff_time') / 100))
                modified_dt = dt * rate
            else
                modified_dt = dt
            end
            --

            -- 개별 update
            for _, list in pairs(self.m_mUnit) do
                local t_remove = {}

                for i, unit in ipairs(list) do
                    if (unit:update(modified_dt)) then
                        table.insert(t_remove, 1, i)
                        self:resetStatus(unit)
                    end
                end

                for i, v in ipairs(t_remove) do
                    table.remove(list, v)
                end
            end
            
            if (self.m_overlabCnt <= 0) then
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
-- function applyCommon
-- @brief 중첩처리해야하는 것(Status)를 제외한 공통 효과를 적용
-------------------------------------
function StatusEffect:applyCommon()
    if (self.m_bApply) then return false end

    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]

    -- groggy 옵션이 있다면 stun 상태로 바꾼다. 이외의 부가적인 효과는 개별적으로 구현
	if (t_status_effect['groggy'] == 'true') then
		self.m_owner:addGroggy(self.m_statusEffectName)
	end

    -- 타켓에게 status_effect 저장
	self.m_owner:insertStatusEffect(self)

    self.m_bApply = true

    return true
end

-------------------------------------
-- function applyStatus
-------------------------------------
function StatusEffect:applyStatus(unit)
    local b = unit:apply(self.m_lStatus, self.m_lStatusAbs)

    self.m_overlabCnt = (self.m_overlabCnt + 1)
        
    if (b) then
        -- @EVENT : 스탯 변화 적용(최대 체력)
		self.m_owner:dispatch('stat_changed')
	end
end

-------------------------------------
-- function resetAll
-------------------------------------
function StatusEffect:resetAll()
    -- Common 해제
    self:resetCommon()

    -- Status 해제
    self:resetStatusAll()
end

-------------------------------------
-- function resetCommon
-------------------------------------
function StatusEffect:resetCommon()
    if (not self.m_bApply) then return false end
    if (self.m_bReset) then return false end

    -- groggy 옵션이 있다면 해제
    local t_status_effect = TABLE:get('status_effect')[self.m_statusEffectName]
    if (t_status_effect['groggy'] == 'true') then
        self.m_owner:removeGroggy(self.m_statusEffectName)
    end
	
	-- 대상이 들고 있는 상태효과 리스트에서 제거
	self.m_owner:removeStatusEffect(self)

    self.m_bReset = true

    return true
end

-------------------------------------
-- function resetStatusAll
-------------------------------------
function StatusEffect:resetStatusAll()
    local bUpdated = false

    for _, list in pairs(self.m_mUnit) do
        for _, unit in ipairs(list) do
            if (unit:reset(self.m_lStatus, self.m_lStatusAbs)) then
                bUpdated = true
            end
        end
    end

    self.m_mUnit = {}
    self.m_overlabCnt = 0

    if (bUpdated) then
        -- @EVENT : 스탯 변화 적용(최대 체력)
		self.m_owner:dispatch('stat_changed')
    end
end

-------------------------------------
-- function resetStatus
-------------------------------------
function StatusEffect:resetStatus(unit)
    local b = unit:reset(self.m_lStatus, self.m_lStatusAbs)

    self.m_overlabCnt = (self.m_overlabCnt - 1)
        
    if (b) then
        -- @EVENT : 스탯 변화 적용(최대 체력)
		self.m_owner:dispatch('stat_changed')
	end
end

-------------------------------------
-- function addUnit
-------------------------------------
function StatusEffect:addUnit(caster, skill_id, value, duration)
    local skill_id = skill_id or 999999

    if (self.m_state == 'end' or self.m_state == 'dying') then
        self:changeState('start')
    end

    local new_unit = StatusEffectUnit(self:getTypeName(), self.m_owner, caster, skill_id, value, duration)

    
    local char_id = caster:getCharId()
    
    -- 갱신(삭제 후 새로 적용하는 방식으로 처리함. 리스트의 가장 뒤로 보내야하기 때문)
    if (self.m_mUnit[char_id]) then
        for i, unit in ipairs(self.m_mUnit[char_id]) do
            if (unit.m_skillId == skill_id) then
                -- 주체와 스킬id가 같을 경우 삭제 후 추가 시킴
                local unit = table.remove(self.m_mUnit[char_id], i)
                self:resetStatus(unit)

                table.insert(self.m_mUnit[char_id], new_unit)
                is_exist = true
                break
            end
        end
    else
        self.m_mUnit[char_id] = {}
    end

    table.insert(self.m_mUnit[char_id], new_unit)
    
    -- Status 적용
    self:applyStatus(new_unit)

    -- 최대 중첩 횟수를 넘을 경우 젤 앞의 unit을 삭제
    if (self.m_overlabCnt > self.m_maxOverlab) then
        local unit = table.remove(self.m_mUnit[char_id], 1)
        self:resetStatus(unit)
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