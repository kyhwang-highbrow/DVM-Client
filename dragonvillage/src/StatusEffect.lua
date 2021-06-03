local PARENT = class(Entity, IEventListener:getCloneTable())

-------------------------------------
-- class StatusEffect
-------------------------------------
StatusEffect = class(PARENT, {
        m_res = 'string',

        m_offsetPos = 'cc.p',
        
        m_statusEffectTable = 'table',
        m_statusEffectName = 'string',
        m_overlabClass = 'class',
        
		m_owner = 'Character',		-- 피시전자 & 상태효과의 대상
		
        m_lStatus = 'list', -- key:능력치명, value:수치
        m_lStatusAbs = 'list', -- key:능력치명, value:수치

        m_bHasHpStatus = 'boolean',     -- hp 옵션 존재 여부
        m_bHasAspdStatus = 'boolean',   -- aspd 옵션 존재 여부

        m_lUnit = 'table',  -- 해당 상태효과에 추가된 StatusEffectUnit의 리스트
        m_mUnit = 'table',  -- 시전자의 char_id값을 키값으로 StatusEffectUnit의 리스트를 가지는 맵

        m_bErasable = 'boolean',
        m_bHidden = 'boolean',

        m_bDead = 'boolean',
        m_bApply = 'boolean',
        m_bDirtyPos = 'bollean',
        m_bHarmful = 'boolean',
        m_bAbs = 'boolean',     -- 절대값
        m_bStopUntilSkillEnd = 'boolean',   -- 스킬 연출 중(일시정지) 일 경우 시간 흐름 여부(false일 경우 일시정지 이후에 걸린 경우는 시간이 흘러감)
        m_bInfinity = 'boolean', -- 타이머없이 계속 유지되는지 여부
        m_latestTimer = 'number',

        m_overlabCnt = 'number',
        m_maxOverlab = 'number', -- 0:중복 가능, 1:중복 불가능, 중첩 불가능, 지속 시간 초기화, 2이상:숫자만큼 중첩 가능, 지속 시간 초기화

        m_topEffect = 'Animator',

		m_type = 'status type',
        m_category = 'status category',

        -- 트리거 관련
        m_lTriggerFunc = 'table',           -- 트리거 이벤트별 함수 리스트를 가진 테이블(event_name : func_list)
        m_lTriggerFuncTimer = 'table',      -- 트리거 함수별 최근 호출되고 지난 시간값을 가진 맵테이블(func : timer)
        m_lTriggerFuncInterval = 'table',   -- 트리거 함수별 주기시간값을 가진 맵테이블(func : interval)

        -- 별도의 연출 처리를 위한 모듈
        m_edgeDirector = 'StatusEffectEdgeDirector',

        m_keep_value = 'number',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect:init(file_name, body)
    self.m_res = file_name

    self.m_offsetPos = { x = 0, y = 0 }
    
    self.m_overlabClass = StatusEffectUnit

	self.m_lStatus = {}
    self.m_lStatusAbs = {}

    self.m_bHasHpStatus = false
    self.m_bHasAspdStatus = false

    self.m_lUnit = {}
    self.m_mUnit = {}

    self.m_bErasable = false
    self.m_bHidden = false

    self.m_bDead = false
    self.m_bApply = false
    self.m_bDirtyPos = true
    self.m_bHarmful = false
    self.m_bStopUntilSkillEnd = true
    self.m_bInfinity = false
    self.m_latestTimer = 0

    self.m_overlabCnt = 0
    self.m_maxOverlab = 0

    self.m_lTriggerFunc = {}
    self.m_lTriggerFuncTimer = {}
    self.m_lTriggerFuncInterval = {}

    self.m_edgeDirector = nil

	self:init_top(file_name)
	self:initState()

    self.m_rootNode:setVisible(false)
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

    self.m_bErasable = (SkillHelper:getValid(t_status_effect['erasable'], 1) == 1)
    self.m_bHidden = (SkillHelper:getValid(t_status_effect['show_icon'], 1) == 0)
    self.m_bHarmful = StatusEffectHelper:isHarmful(t_status_effect['category'])
    self.m_bAbs = (t_status_effect['abs_switch'] and (t_status_effect['abs_switch'] == 1) or false)

    -- 스킬 연출 중(일시정지) 일 경우 시간 흐름 여부
    if (string.find(self.m_type, 'add_dmg') or string.find(self.m_type, 'add_heal')) then
        self.m_bStopUntilSkillEnd = false
    end

    -- status 배율 지정
    do
        for _, type in ipairs(L_STATUS_TYPE) do
            local value = t_status_effect[type] or 0
            if (value ~= 0) then
                self:insertStatus(type, value, self.m_bAbs)
            end
        end
    end

    -- 연출 지정
    if (t_status_effect['direction']) then
        self:init_direction(t_status_effect['direction'])
    end

    -- 하이라이트 설정
    self.m_owner:addHighlightNode(self.m_rootNode)
end

-------------------------------------
-- function init_top
-------------------------------------
function StatusEffect:init_top(file_name)
    if (not self.m_animator) then return end

    local list = self.m_animator:getVisualList()
    if (list and table.find(list, 'top_idle')) then
        self.m_topEffect = MakeAnimator(file_name)
        self.m_topEffect:setPosition(0, 80)
        self.m_rootNode:addChild(self.m_topEffect.m_node)
    end
end

-------------------------------------
-- function init_direction
-- @TODO 연출 타입별 초기화 작업 수행
-------------------------------------
function StatusEffect:init_direction(direction_type)
    if (self.m_edgeDirector) then return end
    if (not self.m_animator) then return end

    local func = {}
    func['barrier'] = function()
        self:addTrigger('hit_barrier', function()
            if (not self.m_animator) then return end

            if (self.m_state == 'idle') then
                self.m_animator:changeAni('hit', false)
                self:addAniHandler(function()
                    self.m_animator:changeAni('idle', true)
                end)
            end
        end)
    end

    func['linear'] = function()
        -- TODO: 연출을 위한 모듈 생성
    end

    func['polygons'] = function()
        self.m_edgeDirector = StatusEffectEdgeDirector(self.m_owner.m_bLeftFormation, 'polygons', self.m_rootNode, self.m_res, self.m_maxOverlab)
    end

    if (func[direction_type]) then
        if (direction_type == 'polygons') then
            self.m_animator:release()
            self.m_animator = nil
        end

        func[direction_type]()

    elseif (self.m_animator) then
        local list = self.m_animator:getVisualList()

        -- hit 애니메이션이 있을 경우 barrier 연출로 처리
        if (table.find(list, 'hit')) then
            func['barrier']()
        end
    end
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
-- function addState
-- @param state : string
-- @param func : function
-- @param ani : string
-- @param loop : boolean
-- @param priority : number
-------------------------------------
function StatusEffect:addState(state, func, ani, loop, priority)
    PARENT.addState(self, state, func, ani, loop, priority)

    if (not self.m_animator) then return end

    if (ani) then
        local list = self.m_animator:getVisualList()
        local idx = table.find(list, ani)
        if (not idx) then
            if (ani == 'center_start') then ani = 'appear'
            elseif (ani == 'center_idle') then ani = 'idle'
            elseif (ani == 'center_end') then ani = 'disappear'
            else return end

            self.m_tStateAni[state] = ani
        end
    end
end

-------------------------------------
-- function setName
-------------------------------------
function StatusEffect:setName(name)
    self.m_statusEffectName = name
end

-------------------------------------
-- function setOverlabClass
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

    self:removeAllTrigger()

    -- 대상이 들고 있는 상태효과 리스트에서 제거
	self.m_owner:removeStatusEffect(self)
    self.m_owner:removeHighlightNode(self.m_rootNode)
            
    self.m_bDead = true

    if(self.m_bHarmful) then
    	local t_event = clone(EVENT_STATUS_EFFECT)
		t_event['char'] = self.m_owner
		t_event['status_effect_name'] = self.m_statusEffectName
        self.m_owner:dispatch('release_debuff', t_event)
    end
    
end

-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then

        -- 중첩에 상관없이 한번만 적용되어야하는 효과 적용
        owner:apply()

        -- 상태효과 적용 이벤트
        local t_event = {}
        t_event['name'] = owner.m_statusEffectName
        t_event['category'] = owner.m_category
        t_event['type'] = owner.m_type

        if (not owner.m_world.m_gameState:isFightWait() and not owner.m_world.m_waveMgr:isFirstWave()) then
            owner.m_owner:dispatch('get_status_effect', t_event, owner.m_owner) 
        end

		-- 힐 사운드
		if (not owner.m_bHarmful) then
			--SoundMgr:playEffect('SFX', 'sfx_buff_get')
		end

		-- 에니메이션이 0프레임일 경우 즉시 상태를 변경
        local duration = owner.m_animator and owner.m_animator:getDuration() or 0
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

        -- 상태효과 리스트에서 제거
        owner:setDead()
		
        -- 에니메이션이 0프레임일 경우 즉시 상태를 변경
        local duration = owner.m_animator and owner.m_animator:getDuration() or 0
        if (duration == 0) then
            owner:changeState('dying')
        else
            owner:addAniHandler(function()
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
        local modified_dt

        if (not self.m_world.m_gameState:isFight()) then
            -- 전투 중이 아닐 경우 지속시간이 감소하지 않도록 처리
            modified_dt = 0
        
        elseif (self.m_bStopUntilSkillEnd and self.m_world.m_gameDragonSkill:isPlaying()) then
            -- 스킬 연출 중일 경우 지속시간이 감소하지 않도록 처리
            modified_dt = 0
        
        elseif (self.m_bHarmful) then
            -- 대상자의 디법 유지 시간 관련 스텟을 실시간으로 적용
            local debuff_time = self.m_owner:getStat('debuff_time')
            debuff_time = math_max(debuff_time, -99)    -- 만약의 경우 분모가 0이 되는 경우를 방지

            modified_dt = dt / (1 + (debuff_time / 100))
        else
            modified_dt = dt
        end

        -- 중첩 수 만큼 개별 update
        for _, list in pairs(self.m_mUnit) do
            local t_remove = {}

            for i, unit in ipairs(list) do
                if (unit:update(dt, modified_dt)) then
                    table.insert(t_remove, 1, i)
                    self:unapplyOverlab(unit)

                    local idx = table.find(self.m_lUnit, unit)
                    if (idx) then
                        table.remove(self.m_lUnit, idx)
                    end
                end
            end

            for i, v in ipairs(t_remove) do
                table.remove(list, v)
            end
        end

        -- 타이머
        self:updateTimer(modified_dt)
            
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

    -- 대상자가 죽었을 경우 이펙트 숨김
    if (self.m_owner:isDead()) then
        self.m_rootNode:setVisible(false)
    else
        self.m_rootNode:setVisible(self.m_bApply)
    end

    return ret
end

-------------------------------------
-- function checkPosDirty
-------------------------------------
function StatusEffect:checkPosDirty()
    local offset_x = self.m_offsetPos['x'] or 0
    local offset_y = self.m_offsetPos['y'] or 0

    if ((self.pos['x'] ~= self.m_owner.pos['x'] + offset_x) or
        (self.pos['y'] ~= self.m_owner.pos['y'] + offset_y)) then
        self.m_bDirtyPos = true
    end
end

-------------------------------------
-- function updatePos
-------------------------------------
function StatusEffect:updatePos()
    local offset_x = self.m_offsetPos['x'] or 0
    local offset_y = self.m_offsetPos['y'] or 0

    self:setPosition(self.m_owner.pos['x'] + offset_x, self.m_owner.pos['y'] + offset_y)
    self.m_bDirtyPos = false
end

-------------------------------------
-- function updateTimer
-------------------------------------
function StatusEffect:updateTimer(dt)
    -- 남은 시간
    if (not self:isInfinity()) then
        self.m_latestTimer = self.m_latestTimer - dt
        self.m_latestTimer = math_max(self.m_latestTimer, 0)
    end

    -- 트리거 함수별 마지막 호출 이후 지난 시간
    for k, v in pairs(self.m_lTriggerFuncTimer) do
        self.m_lTriggerFuncTimer[k] = v + dt
    end
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

    if (type == 'hp') then
        self.m_bHasHpStatus = true
    end
    if (type == 'aspd') then
        self.m_bHasAspdStatus = true
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

    -- 효과음
    self:playEffect()

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
    -- 중첩에 상관없이 한번만 적용되어야하는 효과 적용
    if (not self.m_bApply) then
        self:apply()
    end

    local b = unit:onApply(self.m_lStatus, self.m_lStatusAbs)
    if (not b) then return end

    self.m_overlabCnt = (self.m_overlabCnt + 1)

    -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
    self:dispatchEvent_statChange()

    self:onApplyOverlab(unit)

    if (self.m_edgeDirector) then
        self.m_edgeDirector:addEdge()
    end
end

-------------------------------------
-- function onApplyOverlab
-- @brief 해당 상태효과가 최초 1회를 포함하여 중첩 적용될시마다 호출
-------------------------------------
function StatusEffect:onApplyOverlab(unit)
    if (not self.m_statusEffectTable) then return end

    self:setOverlabScaleByVariables(unit)
end

-------------------------------------
-- function unapplyOverlab
-- @brief 중첩될때마다 적용되어야하는 효과를 해제
-------------------------------------
function StatusEffect:unapplyOverlab(unit, is_skip_event)
    local b = unit:onUnapply(self.m_lStatus, self.m_lStatusAbs)
    if (not b) then return end

    self.m_overlabCnt = (self.m_overlabCnt - 1)

    -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
    if (not is_skip_event) then
        -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
        self:dispatchEvent_statChange()
    end

    self:onUnapplyOverlab(unit)

    if (self.m_edgeDirector) then
        self.m_edgeDirector:removeEdge()
    end
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
            self:unapplyOverlab(unit, true)
        end

        self.m_lUnit = {}
        self.m_mUnit = {}
        self.m_overlabCnt = 0

        -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
        self:dispatchEvent_statChange()
    end
end

-------------------------------------
-- function addOverlabUnit
-------------------------------------
function StatusEffect:addOverlabUnit(caster, skill_id, value, source, duration, add_param)
    if (self.m_bDead) then return end

    local char_key = caster.phys_idx
    local skill_id = skill_id or 999999

    -- 시전자의 스텟에 따라 지속시간을 증가시킴(이미 걸려있던 디버프 중첩별 실시간 적용은 안함)
    if (self.m_bHarmful and caster) then
        local target_debuff_time = caster:getStat('target_debuff_time')
        target_debuff_time = math_max(target_debuff_time, -100)

        if (target_debuff_time ~= 0) then
            duration = duration + duration * target_debuff_time / 100
        end
    end

    local new_unit = self.m_overlabClass(self:getTypeName(), self.m_owner, caster, skill_id, value, source, duration, add_param)
    local t_status_effect = self.m_statusEffectTable
    
    if (not self.m_mUnit[char_key]) then
        self.m_mUnit[char_key] = {}
    end

    local add_new_unit = function(add_unit)
        -- 중첩 정보 추가
        table.insert(self.m_mUnit[char_key], add_unit)
        table.insert(self.m_lUnit, add_unit)

        -- 지속 시간으로 정렬시킴(오름차순)
        table.sort(self.m_mUnit[char_key], function(a, b)
            return a:getDuration() < b:getDuration()
        end)
        table.sort(self.m_lUnit, function(a, b)
            return a:getDuration() < b:getDuration()
        end)

        -- 중첩시 효과 적용
        self:applyOverlab(add_unit)
    end

    -- 갱신(삭제 후 새로 추가하는 방식으로 처리함. 리스트의 가장 뒤로 보내야하기 때문)
    local bSkipAdd = false

    -- overlab_option 이 0 이면 중첩불가 / 몬스터가 드래곤에 거는 디버프도 중첩 불가
    if (t_status_effect['overlab_option'] == 0 or (caster:getCharType() == 'monster' and self.m_owner.m_bLeftFormation)) then
        for i, unit in ipairs(self.m_mUnit[char_key]) do
            -- 주체와 스킬id가 같고 지속시간이 짧을 경우 삭제 후 추가 시킴
            if (unit.m_skillId == new_unit.m_skillId) then
                if (unit:getDuration() <= new_unit:getDuration()) then
                    local remove_unit = table.remove(self.m_mUnit[char_key], i)
                    self:unapplyOverlab(remove_unit)

                    local idx = table.find(self.m_lUnit, remove_unit)
                    table.remove(self.m_lUnit, idx)
                else
                    bSkipAdd = true
                end
                
                break
            end
        end
    end

    if (not bSkipAdd) then
        add_new_unit(new_unit)
    end
    
    -- 최대 중첩 횟수를 넘을 경우 지속 시간이 가장 짧은 unit을 삭제
    if (self.m_maxOverlab > 0 and self.m_overlabCnt > self.m_maxOverlab) then
        local unit = table.remove(self.m_lUnit, 1)

        for _, v in pairs(self.m_mUnit) do
            local idx = table.find(v, unit)
            if (idx) then
                table.remove(v, idx)
                break
            end
        end

        self:unapplyOverlab(unit)
    end

    -- 해당 상태효과의 종료시간을 구해서 저장
    local latestTime = self:calcLatestTime()
    self.m_bInfinity = (latestTime == -1)
    self.m_latestTimer = latestTime
end

-------------------------------------
-- function removeOverlabUnit
-------------------------------------
function StatusEffect:removeOverlabUnit(unit)
    local unit = unit or self.m_lUnit[1]
    if (not unit) then return false end

    self:unapplyOverlab(unit)

    local idx = table.find(self.m_lUnit, unit)
    if (idx) then
        table.remove(self.m_lUnit, idx)
    end

    for _, list in pairs(self.m_mUnit) do
        local idx = table.find(list, unit)
        if (idx) then
            table.remove(list, idx)
            break
        end
    end

    -- 현재는 항상 리스트의 앞에꺼부터 삭제되고 있으므로 종료시간을 다시 계산할 필요없음

    return true
end

-------------------------------------
-- function calcLatestTime
-- @brief 해당 상태효과의 종료시간을 얻는다
-------------------------------------
function StatusEffect:calcLatestTime()
    local latestTimer = 0

    for _, unit in pairs(self.m_lUnit) do
        if (unit.m_duration ~= -1) then
            latestTimer = math_max(latestTimer, unit:getDuration())
        else
            latestTimer = -1
            return latestTimer
        end
    end

    return latestTimer
end

-------------------------------------
-- function playEffect
-------------------------------------
function StatusEffect:playEffect()
    local res_sound = self.m_statusEffectTable['sound'] or ''

    if (res_sound ~= '') then
        ISkillSound:playSkillSound(res_sound)
    end
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
    if (self.m_temporaryPause == pause) then
        return false
    end

    self.m_temporaryPause = pause

    local action_mgr = cc.Director:getInstance():getActionManager()

    if (pause) then
        action_mgr:pauseTarget(self.m_rootNode)
    else
        action_mgr:resumeTarget(self.m_rootNode)
    end
    
    return true
end


-------------------------------------
-- function getUnit
-------------------------------------
function StatusEffect:getUnit(caster, skill_id)
    if (not caster or not skill_id) then return end

    local char_key = caster.phys_idx

    if (not self.m_mUnit[char_key]) then return end

    for i, unit in ipairs(self.m_mUnit[char_key]) do
        if (unit.m_skillId == skill_id) then
            return unit
        end
    end
end


-------------------------------------
-- function isActiveIcon
-------------------------------------
function StatusEffect:isActiveIcon()
    return (self.m_bApply and not self.m_owner:isDead())
end

-------------------------------------
-- function getTypeName
-------------------------------------
function StatusEffect:getTypeName()
    return self.m_statusEffectName
end

-------------------------------------
-- function isErasable
-------------------------------------
function StatusEffect:isErasable()
    return self.m_bErasable
end

-------------------------------------
-- function isHidden
-------------------------------------
function StatusEffect:isHidden()
    return self.m_bHidden
end

-------------------------------------
-- function isHarmful
-------------------------------------
function StatusEffect:isHarmful()
    return self.m_bHarmful
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
-- function getOverlabCount
-------------------------------------
function StatusEffect:getOverlabCount()
    return self.m_overlabCnt
end

-------------------------------------
-- function getOverlabUnitList
-------------------------------------
function StatusEffect:getOverlabUnitList()
    return self.m_lUnit
end

-------------------------------------
-- function getEdgeDirector
-------------------------------------
function StatusEffect:getEdgeDirector()
    return self.m_edgeDirector
end




-------------------------------------
-- function addTrigger
-------------------------------------
function StatusEffect:addTrigger(event_name, func, interval)
    if (not self.m_lTriggerFunc[event_name]) then
        self.m_lTriggerFunc[event_name] = {}

        -- listner 등록
        self.m_owner:addListener(event_name, self)
    end

    table.insert(self.m_lTriggerFunc[event_name], func)

    if (interval and interval > 0) then
        local idx = #self.m_lTriggerFunc[event_name]
        local key = event_name .. idx
        self.m_lTriggerFuncTimer[key] = 0
        self.m_lTriggerFuncInterval[key] = interval
    end
end

-------------------------------------
-- function removeAllTrigger
-------------------------------------
function StatusEffect:removeAllTrigger()
    for name, _ in pairs(self.m_lTriggerFunc) do
        -- listener 해제
        self.m_owner:removeListener(name, self)
    end

    self.m_lTriggerFunc = {}
    self.m_lTriggerFuncTimer = {}
    self.m_lTriggerFuncInterval = {}
end

-------------------------------------
-- function onEvent
-------------------------------------
function StatusEffect:onEvent(event_name, t_event, ...)
    local l_func = self.m_lTriggerFunc[event_name]
    if (not l_func) then return false end
    
    for idx, func in ipairs(l_func) do
        local key = event_name .. idx

        if (self.m_lTriggerFuncInterval[key]) then
            if (self.m_lTriggerFuncTimer[key] > self.m_lTriggerFuncInterval[key]) then
                self.m_lTriggerFuncTimer[key] = self.m_lTriggerFuncTimer[key] - self.m_lTriggerFuncInterval[key]

                func(t_event, ...)
            end
        else
            func(t_event, ...)    
        end
    end
end

-------------------------------------
-- function dispatchEvent_statChange
-------------------------------------
function StatusEffect:dispatchEvent_statChange()
    -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
    if (self.m_bHasHpStatus or self.m_bHasAspdStatus) then
        local t_event = clone(EVENT_STAT_CHANGED_CARRIER)
        if (self.m_bHasHpStatus) then
            t_event['hp'] = true

            -- @kwkang 21-01-04 첫 웨이브가 아닌 웨이브에 나오는 적 드래곤의 경우 HP 패시브 버프가 올바르게 들어가지 않았던 현상 수정
            if (self.m_owner:isBoss()) then
                t_event['is_boss'] = true
            end

        end
        if (self.m_bHasAspdStatus) then
            t_event['aspd'] = true
        end

	    self.m_owner:dispatch('stat_changed', t_event)
    end
end

-------------------------------------
-- function setOffsetPos
-------------------------------------
function StatusEffect:setOffsetPos(pos)
    self.m_offsetPos = pos
end


-------------------------------------
-- function initValue
-------------------------------------
function StatusEffect:initValue(value)
    self.m_keep_value = value
end


-------------------------------------
-- function setOffsetPos
-- 중첩 가능한 상태일 때
-- 그 중첩에 따라 스케일값 변동하는
-- 값이 들어가 있는지 확인
-------------------------------------
function StatusEffect:setOverlabScaleByVariables(unit)
    if (not self.m_owner) then return end

    local act_type = self.m_statusEffectTable['val_1']
    local period = self.m_statusEffectTable['val_2']
    local rate = self.m_statusEffectTable['val_3']

    -- 셋중에 하나도 비어있으면 암것도 안함
    if (self.m_overlabCnt <= 0 or isNullOrEmpty(act_type) or isNullOrEmpty(period) or isNullOrEmpty(rate)) then return end
    if (not string.find(act_type, 'scale')) then return end

    if (string.find(act_type, 'skill')) then
        -- 0이 되었을 때를 대비 
        period = math.max(tonumber(period), 1)

        if (not self.m_owner.m_reactingInfo['skill_scale']) then self.m_owner.m_reactingInfo["skill_scale"] = 1 end

        local original_scale = self.m_owner.m_reactingInfo['skill_scale']
        local add_scale = math.max(self.m_overlabCnt / period, 0) * tonumber(rate)
        self.m_owner.m_reactingInfo["skill_scale"] = original_scale + add_scale

    else
        -- 0이 되었을 때를 대비 
        period = math.max(tonumber(period), 1)

        local original_scale = self.m_owner.m_originScale
        local add_scale = math.max(self.m_overlabCnt / period, 0) * tonumber(rate)
        local final_scale = original_scale + add_scale

        if (final_scale > 1.5) then
            cca.stopAction(self.m_owner.m_animator.m_node, CHARACTER_ACTION_TAG__FLOATING)
        end

        self.m_owner.m_animator:setScale(final_scale)
    end
end

