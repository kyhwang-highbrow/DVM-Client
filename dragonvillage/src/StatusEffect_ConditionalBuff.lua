local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ConditionalBuff
-------------------------------------
StatusEffect_ConditionalBuff = class(PARENT, { 
    m_chance = 'string',
    m_caster = 'Character',
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

    -- caster를 넘겨주어야 하는 경우가 생김( ex)시전자가 살아있을 때 owner에게 버프 )
    -- 위 경우에 한해 사용될 m_caster 변수 생성. 다른 경우에는 m_caster는 m_owner와 같음.
    if (caster) then
        self.m_caster = caster
    else
        self.m_caster = self.m_owner
    end

    -- 변경할 상태효과를 구분하기 위한 조건 정보를 저장
    self.m_chance = t_status_effect['val_1']
    self.m_eventName = PASSIVE_CHANCE_TYPE[self.m_chance]

    local is_self_cast = (self.m_caster == self.m_owner)

        for _, v in pairs (self.m_eventName) do 
            if (is_self_cast) then
                self:addTrigger(v, self:getTriggerFunction()) 
            else
                self:addTriggerToOther(v, self:getTriggerFunction()) -- 여기서 상태효과의 주인이 아니라 시전자에게 리스너를 달아줌.
            end
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
    local trigger_func = function(t_event)
        if (self:checkCondition(t_event)) then
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
function StatusEffect_ConditionalBuff:checkCondition(t_event)
    return PASSIVE_CONDITION_FUNC[self.m_chance](self, t_event)
end

-------------------------------------
-- function buffOn
-------------------------------------
function StatusEffect_ConditionalBuff:buffOn()
    self:apply()

    for _, v in ipairs(self.m_lUnit) do
        v:onApply(self.m_lStatus, self.m_lStatusAbs)
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



function StatusEffect_ConditionalBuff:addTriggerToOther(event_name, func, interval)
    if (not self.m_lTriggerFunc[event_name]) then
        self.m_lTriggerFunc[event_name] = {}

        -- listner 등록
        self.m_caster:addListener(event_name, self)
    end

    table.insert(self.m_lTriggerFunc[event_name], func)

    if (interval and interval > 0) then
        local idx = #self.m_lTriggerFunc[event_name]
        local key = event_name .. idx
        self.m_lTriggerFuncTimer[key] = 0
        self.m_lTriggerFuncInterval[key] = interval
    end
end