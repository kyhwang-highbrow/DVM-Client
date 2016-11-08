local TAMER_SKILL_CUT_TYPE__NORMAL = 1
local TAMER_SKILL_CUT_TYPE__SPECIAL = 2

-------------------------------------
-- class TamerSkillCut
-------------------------------------
TamerSkillCut = class(IEventListener:getCloneClass(), {
        m_world = 'GameWrold',
        m_darkLayer = '',
        
        m_bPlaying = 'boolean',

        -- 연출 진행 상태 관련 정보
        m_timer = 'number',		-- 전체 타이머

        m_step = 'number',		-- 현재 연출 단계
	    m_nextStep = 'number',

        m_stepTimer = 'number',	-- 현재 연출 단계내에서의 타이머
	    m_stepPrevTime = 'number',	-- 이전 프레임에서의 m_stepTimer값

        -- 연출 정보
        m_type = 'number',
        m_cbEnd = 'function',

        --
        m_bgVisual = 'Animator',
        m_tamerAnimator = 'Animator',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillCut:init(world, dark_layer, t_tamer)
    self.m_world = world
    self.m_darkLayer = dark_layer

    self.m_bPlaying = false

    local socketNode

    -- 배경
    do
        self.m_bgVisual = MakeAnimator('res/effect/effect_skillcut_goni/effect_skillcut_goni.vrp')
        self.m_bgVisual:setVisible(false)
        socketNode = self.m_bgVisual.m_node:getSocketNode('goni')

        self.m_darkLayer:addChild(self.m_bgVisual.m_node)
    end
    
    -- 테이머
    if socketNode then
        self.m_tamerAnimator = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        self.m_tamerAnimator:changeAni('idle', true, true)

        socketNode:addChild(self.m_tamerAnimator.m_node)
    end
end

-------------------------------------
-- function update
-------------------------------------
function TamerSkillCut:update(dt)
    if not self.m_bPlaying then return end

    if self.m_step ~= self.m_nextStep then
		self.m_step = self.m_nextStep
		self.m_stepTimer = 0
		self.m_stepPrevTime = 0
	end
    
    if self.m_type == TAMER_SKILL_CUT_TYPE__NORMAL then
        self:update_normal(dt)

    elseif self.m_type == TAMER_SKILL_CUT_TYPE__SPECIAL then
    end

    self:updateTimer(dt)
end

-------------------------------------
-- function update_normal
-------------------------------------
function TamerSkillCut:update_normal(dt)
    if self.m_timer == 0 then
        g_gameScene:flashIn({color = cc.c3b(0, 0, 0), time = 0})

        self.m_bgVisual:changeAni('skill_1', tre)
        self.m_bgVisual:setVisible(true)
    end
end

-------------------------------------
-- function updateTimer
-------------------------------------
function TamerSkillCut:updateTimer(dt)
	self.m_timer = self.m_timer + dt

	self.m_stepPrevTime = self.m_stepTimer
	self.m_stepTimer = self.m_stepTimer + dt
end

-------------------------------------
-- function nextStep
-------------------------------------
function TamerSkillCut:nextStep()
	self.m_nextStep = self.m_nextStep + 1
end

-------------------------------------
-- function isBeginningInStep
-------------------------------------
function TamerSkillCut:isBeginningInStep(step)
	local step = step or self.m_step
	
	return (self.m_step == step and self.m_stepTimer == 0)
end

-------------------------------------
-- function start
-------------------------------------
function TamerSkillCut:start(type, cbEnd)
    self.m_bPlaying = true

    self.m_step = 0
	self.m_nextStep = 0

    self.m_timer = 0
    self.m_stepTimer = 0
	self.m_stepPrevTime = 0

    self.m_type = type
    self.m_cbEnd = cbEnd
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSkillCut:onEvent(event_name, ...)
    local arg = {...}
    local cbEnd = arg[1]

    -- 테이머 스킬
    if (event_name == 'tamer_skill') then
        --self:start(TAMER_SKILL_CUT_TYPE__NORMAL, cbEnd)

    -- 테이머 궁극기
    elseif (event_name == 'tamer_special_skill') then
        --self:start(TAMER_SKILL_CUT_TYPE__SPECIAL, cbEnd)

    end
end