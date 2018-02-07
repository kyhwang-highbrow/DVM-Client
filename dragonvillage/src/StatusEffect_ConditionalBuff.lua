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
function StatusEffect_ConditionalBuff:initFromTable(t_status_effect, target_char, caster)
    PARENT.initFromTable(self, t_status_effect, target_char)

    -- 변경할 상태효과를 구분하기 위한 조건 정보를 저장
    self.m_chance = t_status_effect['val_1']
    self.m_eventName = PASSIVE_CHANCE_TYPE[self.m_chance]
end

-------------------------------------
-- function initState
-------------------------------------
function StatusEffect_ConditionalBuff:initState()
    self:addState('start', StatusEffect_ConditionalBuff.st_start, 'center_start', false)
    self:addState('idle', PARENT.st_idle, 'center_idle', true)
    self:addState('end', PARENT.st_end, 'center_end', false)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function getTriggerFunction
-------------------------------------
function StatusEffect_ConditionalBuff:getTriggerFunction()
    local trigger_func = function(t_event)
        if (self:checkCondition(t_event)) then
            self:buffOn()
        else
            self:buffOff()
        end
    end
    return trigger_func
end

-------------------------------------
-- function checkCondition
-------------------------------------
function StatusEffect_ConditionalBuff:checkCondition(t_event)
    return PASSIVE_CONDITION_FUNC[self.m_chance](self, t_event)
end

-------------------------------------
-- function buffOn
-------------------------------------
function StatusEffect_ConditionalBuff:buffOn()
    self:apply()

    -- 유닛 개별로 조건 체크 후 적용 및 해제
    for i, v in ipairs(self.m_lUnit) do
        if (v:checkCondition()) then
            v:onApply(self.m_lStatus, self.m_lStatusAbs)
        else
            v:onUnapply(self.m_lStatus, self.m_lStatusAbs)
        end
    end
    
    -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
    self:dispatchEvent_statChange()
end

-------------------------------------
-- function buffOff
-------------------------------------
function StatusEffect_ConditionalBuff:buffOff()
    self:unapply()

    for _, v in ipairs(self.m_lUnit) do
        v:onUnapply(self.m_lStatus, self.m_lStatusAbs)
    end

    -- @EVENT : 스탯 변화 적용(최대 체력 or 공속)
    self:dispatchEvent_statChange()
end

-------------------------------------
-- function addOverlabUnit
-- 이 클래스에 한해서 오버랩이 아니라 최초 호출시 상태 효과를 조건 검사 후 걸어주는 역할을 한다.
-- 조건 검사가 필요한 부분이라 재정의
-------------------------------------
function StatusEffect_ConditionalBuff:addOverlabUnit(caster, skill_id, value, source, duration, add_param)
    PARENT.addOverlabUnit(self, caster, skill_id, value, source, duration, add_param)

    -- 시전자에게 해당 unit을 위한 리스너 등록
    for _, event_name in pairs (self.m_eventName) do
        self:addTriggerToCaster(caster, event_name, self:getTriggerFunction())
    end

    if ( not self:checkCondition() ) then
        -- 실행 조건이 아니면 효과 취소.
        self:buffOff()
    end
end

-------------------------------------
-- function st_start
-------------------------------------
function StatusEffect_ConditionalBuff.st_start(owner, dt)
    if (owner.m_stateTimer == 0) then
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
-- function addTriggerToCaster
-------------------------------------
function StatusEffect_ConditionalBuff:addTriggerToCaster(caster, event_name, func)
    if (not self.m_lTriggerFunc[event_name]) then
        self.m_lTriggerFunc[event_name] = {}
    end

    -- listner 등록
    caster:addListener(event_name, self)

    table.insert(self.m_lTriggerFunc[event_name], func)
end