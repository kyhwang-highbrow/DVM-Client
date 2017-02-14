local PARENT = Entity

-------------------------------------
-- class SkillAttributeAmor
-------------------------------------
SkillAttributeAmor = class(PARENT, IEventListener:getCloneTable(), {
        m_owner = 'Character',
        m_activityCarrier = 'AttackDamage',
        m_missileRes = 'string',
        m_motionStreakRes = 'string',
        m_targetCount = 'number',
        m_duration = 'number',
		m_triggerName = 'str',

		m_timerEffect = 'EffectTimer',
        m_label = 'cc.Label',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function SkillAttributeAmor:init(file_name, body, ...)
    self:initState()
end

-------------------------------------
-- function init_skill
-------------------------------------
function SkillAttributeAmor:init_skill(owner, res, x, y, t_skill, t_data)
    self.m_owner = owner

    self.m_missileRes = SkillHelper:getAttributeRes(t_skill['res_1'], owner)
    self.m_motionStreakRes = SkillHelper:getAttributeRes(t_skill['res_2'], owner)
    self.m_targetCount = t_skill['hit']
    self.m_duration = t_skill['val_1']
	self.m_triggerName = 'undergo_attack'

    -- 리스너 등록
	self.m_owner:addListener(self.m_triggerName, self)

    -- 추가 지속 시간
    if t_data and t_data['add_duration'] then
        self.m_duration = self.m_duration + t_data['add_duration']
    end    

    self.m_activityCarrier = owner:makeAttackDamageInstance()
    self.m_activityCarrier.m_skillCoefficient = (t_skill['power_rate'] / 100)

    -- Dash Effect 초기화
    self:initAnimator(self.m_missileRes)

    self:changeState('idle')

    if self.m_duration and (self.m_duration ~= 0) then
        self.m_timerEffect = EffectTimer()
        self.m_rootNode:addChild(self.m_timerEffect.m_node)
    end

    do
        local label = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 20, 2, cc.size(250, 100), 1, 1)
        label:setPosition(0, 100)
        label:setDockPoint(cc.p(0.5, 0.5))
        label:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_rootNode:addChild(label)
        self.m_label = label
    end

    self:setDurationText(self.m_duration)
end

-------------------------------------
-- function initState
-------------------------------------
function SkillAttributeAmor:initState()
    self:addState('idle', SkillAttributeAmor.st_idle, 'effect_reflect_on', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
end

-------------------------------------
-- function st_idle
-------------------------------------
function SkillAttributeAmor.st_idle(owner, dt)
    local char = owner.m_owner
    owner:setPosition(char.pos.x, char.pos.y)

    -- 종료
    if (not owner.m_owner) or owner.m_owner.m_bDead then
        owner:changeState('dying')
        return
    end

    if (not owner.m_stateTimer) or (owner.m_stateTimer <= 0) then
        return
    end

    if owner.m_timerEffect then
        local percentage = (1 - (owner.m_stateTimer / owner.m_duration)) * 100
        owner.m_timerEffect:setPercentage(percentage)
    end

    owner:setDurationText(owner.m_duration - owner.m_stateTimer)

    if (owner.m_stateTimer >= owner.m_duration) then
        owner:changeState('dying')
        return
    end
end


-------------------------------------
-- function onEvent
-------------------------------------
function SkillAttributeAmor:onEvent(event_name, t_event, ...)
	local args = {...}
	local attacker = args[1]
	local defender = self.m_owner
    if (event_name == self.m_triggerName) then
		self:fireMissile(attacker)
    end
end

-------------------------------------
-- function release
-------------------------------------
function SkillAttributeAmor:release()
    self.m_owner:removeListener(self.m_triggerName, self)
	PARENT.release(self)
end

-------------------------------------
-- function fireMissile
-------------------------------------
function SkillAttributeAmor:fireMissile()
    local l_target = self:findTarget()

    if (not l_target) then
        return
    end

    for i=1, self.m_targetCount do
        local target = l_target[i]
        if (not target) then
            break
        end

        do -- 이펙트 생성
            local owner = self.m_owner
            local effect = self.m_world:addInstantEffect(self.m_missileRes, 'effect_reflect', owner.pos.x, owner.pos.y)
            self.m_world:effectSyncPos(owner, effect, 0, 0)
        end

        local char = self.m_owner
        local world = self.m_world

        local t_option = {}

    
        t_option['pos_x'] = char.pos.x
        t_option['pos_y'] = char.pos.y

        t_option['physics_body'] = {0, 0, 0}
        t_option['attack_damage'] = self.m_activityCarrier

        t_option['object_key'] = char:getAttackPhysGroup()

        t_option['missile_res_name'] = self.m_missileRes
		t_option['attr_name'] = self.m_owner:getAttribute()
        t_option['visual'] = 'missile'

        t_option['movement'] = 'fix'
        t_option['target'] = target
        t_option['effect'] = {}
        t_option['effect']['motion_streak'] = self.m_motionStreakRes

        local missile = world.m_missileFactory:makeMissile(t_option)
    end
end

-------------------------------------
-- function findTarget
-------------------------------------
function SkillAttributeAmor:findTarget()
    local l_target = self.m_world:getTargetList(self.m_owner, self.m_owner.pos.x, self.m_owner.pos.y, 'enemy', 'x', 'random')
    return l_target
end

-------------------------------------
-- function setDurationText
-------------------------------------
function SkillAttributeAmor:setDurationText(remain_time)
    local remain_time = math_floor(remain_time + 0.5)
    self.m_label:setString(Str('{1} 초', remain_time))
end