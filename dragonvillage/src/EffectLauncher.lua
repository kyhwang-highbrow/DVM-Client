local PARENT = Entity

-------------------------------------
-- class EffectLauncher
-------------------------------------
EffectLauncher = class(PARENT, {
        m_target = 'Character List',
		m_effectRes = 'str',
		m_motionStreakRes = 'str',
        m_aiParam = 'number',

		m_orgX = 'num',
		m_orgY = 'num', 
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function EffectLauncher:init(file_name, body, ...)
	self:initState()
end

-------------------------------------
-- function initState
-------------------------------------
function EffectLauncher:initState()
	self:addState('idle', EffectLauncher.st_idle, nil, true)
    self:addState('dying', EffectLauncher.st_dying, nil, nil, 10)
end

-------------------------------------
-- function init_effect
-------------------------------------
function EffectLauncher:init_effect(world, effect_res, motion_streak_res, target, x, y)
	-- 멤버 변수 초기화
	self.m_world = world
	self.m_orgX = x
	self.m_orgY = y
    self.m_target = target
	self.m_effectRes = effect_res
	self.m_motionStreakRes = motion_streak_res

	self:setPosition(x, y)
end

-------------------------------------
-- function st_idle
-------------------------------------
function EffectLauncher.st_idle(owner, dt)
	if (owner.m_stateTimer == 0) then
		owner:fireEffect()
	end
end

-------------------------------------
-- function st_dying
-------------------------------------
function EffectLauncher.st_dying(owner, dt)
    return true
end

-------------------------------------
-- function makeEffect
-- @breif 대상에게 생성되는 추가 이펙트 생성
-------------------------------------
function EffectLauncher:makeEffect()
    -- 이팩트 생성
    local effect = Entity(self.m_effectRes, {0, 0, 0})
    effect:setPosition(self.m_orgX, self.m_orgY)

    self.m_world.m_missiledNode:addChild(effect.m_rootNode, 0)

	-- 모션스트릭(MotionStreak) 효과
    if self.m_motionStreakRes then
        effect:setMotionStreak(self.m_world.m_missiledNode, self.m_motionStreakRes)
    end

	return effect
end

-------------------------------------
-- function fireEffect
-------------------------------------
function EffectLauncher:fireEffect()
    local duration = 1
	local jump_height = 100
	local effect = self:makeEffect()
	local target_pos = cc.p(self.m_target.pos.x, self.m_target.pos.y)
	local action = cc.JumpTo:create(duration, target_pos, jump_height, 1)
	local action2 = cc.RemoveSelf:create()
	effect.m_rootNode:runAction(cc.Sequence:create(cc.EaseIn:create(action, 2), action2))
end
