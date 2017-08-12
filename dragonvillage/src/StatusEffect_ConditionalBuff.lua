local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConditionalBuff
-------------------------------------
StatusEffect_ConditionalBuff = class(PARENT, { 
    m_chance = 'string',

    m_mInfo = 'table',
    m_mOriginValues = 'table',
    m_eventName = 'table',
    })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function StatusEffect_ConditionalBuff:init(file_name, body)

    self.m_chance = ''

    self.m_eventName = {}

    self.m_mInfo = {}
end

-------------------------------------
-- function initFromTable
-------------------------------------
function StatusEffect_ConditionalBuff:initFromTable(t_status_effect, target_char)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 변경할 상태효과를 구분하기 위한 조건 정보를 저장
    self.m_chance = t_status_effect['val_1']
    self.m_eventName = PASSIVE_CHANCE_TYPE[self.m_chance]

    for _, v in pairs (self.m_eventName) do 
        self:addTrigger(v, self:getTriggerFunction())
    end

end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_ConditionalBuff:initState()
    self:addState('start', StatusEffect_ConditionalBuff.st_start, 'center_start', false)
    self:addState('idle', StatusEffect.st_idle, 'center_idle', true)
    self:addState('end', StatusEffect.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end


-------------------------------------
-- function onStart
-------------------------------------
function StatusEffect_ConditionalBuff:onStart()
end


-------------------------------------
-- function onEnd
-------------------------------------
function StatusEffect_ConditionalBuff:onEnd()
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_ConditionalBuff:getTriggerFunction()
    local trigger_func = function()
        if (self:checkCondition()) then
            if (not self.m_bApply) then
                self:buffOn()
            end
        else
            if(self.m_bApply) then
                self:buffOff()
            end
        end
    end
    return trigger_func
end

-------------------------------------
-- function checkCondition
-------------------------------------
function StatusEffect_ConditionalBuff:checkCondition()
    return PASSIVE_CONDITION_FUNC[self.m_chance](self)
end

-------------------------------------
-- function buffOn
-------------------------------------
function StatusEffect_ConditionalBuff:buffOn()
    self:apply()
    for _, v in ipairs(self.m_lUnit) do
        v:onApply(self.m_lStatus, self.m_lStatusAbs)
    end
    
    -- @EVENT : 스탯 변화 적용(최대 체력)
	self.m_owner:dispatch('stat_changed')
end

-------------------------------------
-- function buffOff
-------------------------------------
function StatusEffect_ConditionalBuff:buffOff()
    self:unapply()
    for _, v in ipairs(self.m_lUnit) do
        v:onUnapply(self.m_lStatus, self.m_lStatusAbs)
    end

    -- @EVENT : 스탯 변화 적용(최대 체력)
	self.m_owner:dispatch('stat_changed')
end



-------------------------------------
-- function addOverlabUnit
-- 이 클래스에 한해서 오버랩이 아니라 최초 호출시 상태 효과를 조건 검사 후 걸어주는 역할을 한다.
-- 조건 검사가 필요한 부분이라 재정의
-------------------------------------
function StatusEffect_ConditionalBuff:addOverlabUnit(caster, skill_id, value, source, duration, add_param)
    local char_id = caster:getCharId()
    local skill_id = skill_id or 999999
    if (self.m_state == 'end' or self.m_state == 'dying') then
        self:changeState('start')
    end

    local new_unit = self.m_overlabClass(self:getTypeName(), self.m_owner, caster, skill_id, value, source, duration, add_param)
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
    --유닛은 만들어서 오버랩해둠. 
    -- StatusEffect의 Update에서 유닛 오버랩 카운트가 0이하면 자동으로 release해버리므로, 이를 속이기 위해.
    self:applyOverlab(new_unit)
    
    if ( not self:checkCondition() ) then
        -- 실행 조건이 아니면 효과 취소.
        self:buffOff()
    end

    -- @EVENT : 스탯 변화 적용(최대 체력)
	self.m_owner:dispatch('stat_changed')
        -- 최대 중첩 횟수를 넘을 경우 젤 앞의 unit을 삭제
    if (self.m_maxOverlab > 0 and self.m_overlabCnt > self.m_maxOverlab) then
        local unit = table.remove(self.m_mUnit[char_id], 1)
        self:unapplyOverlab(unit)

        local idx = table.find(self.m_lUnit, unit)
        table.remove(self.m_lUnit, idx)
    end
        

    -- 해당 상태효과의 종료시간을 구해서 저장
    local latestTime = self:calcLatestTime()
    self.m_bInfinity = (latestTime == -1)
    self.m_latestTimer = latestTime
end



-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect_ConditionalBuff.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 중첩에 상관없이 한번만 적용되어야하는 효과 적용

        local t_event = {}
        t_event['name'] = owner.m_statusEffectName
        t_event['category'] = owner.m_category
        t_event['type'] = owner.m_type

		
		-- 힐 사운드
		if (not owner.m_bHarmful) then
			--SoundMgr:playEffect('SFX', 'sfx_buff_get')
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