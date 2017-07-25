local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConditionalBuff
-------------------------------------
StatusEffect_ConditionalBuff = class(PARENT, {
    m_bToggle = 'boolean', 
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

    self.m_bToggle = false -- 버프의 상태
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
    self.m_eventName = PASSIVE_CHANCE_TYPE[self.m_chance]

    for _, v in pairs (self.m_eventName) do 
        self:addTrigger(v, self:getTriggerFunction())
    end

end


function StatusEffect_ConditionalBuff:initValues(event_name)
    self.m_chance = event_name
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
            if (not self.m_bToggle) then
                self:buffOn()
                self.m_bToggle = true
                self.m_bApply = self.m_bToggle
            end
        else
            if(self.m_bToggle) then
                self:buffOff()
                self.m_bToggle = false
                self.m_bApply = self.m_bToggle
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
    for _, v in ipairs(self.m_lUnit) do
        v:onApply(self.m_lStatus, self.m_lStatusAbs)
    end
end

-------------------------------------
-- function buffOff
-------------------------------------
function StatusEffect_ConditionalBuff:buffOff()
    for _, v in ipairs(self.m_lUnit) do
        v:onUnapply(self.m_lStatus, self.m_lStatusAbs)
    end
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
    if ( self:checkCondition() ) then
    -- 중첩시 효과 적용
        self:applyOverlab(new_unit)
        self.m_bToggle = true
        self.m_bApply = self.m_bToggle
    end
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
