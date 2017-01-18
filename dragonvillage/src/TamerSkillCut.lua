local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

local TAMER_SKILL_CUT_TYPE__IDLE = 0
local TAMER_SKILL_CUT_TYPE__NORMAL = 1
local TAMER_SKILL_CUT_TYPE__SPECIAL = 2

-------------------------------------
-- class TamerSkillCut
-------------------------------------
TamerSkillCut = class(PARENT, {
        m_world = 'GameWrold',
        m_skillLayer = '',
        
        m_bPlaying = 'boolean',
        
        -- 연출 정보
        m_cbEnd = 'function',

        --
        m_bgVisual = 'Animator',
        m_tamerAnimator = 'Animator',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSkillCut:init(world, skill_layer, t_tamer)
    self.m_world = world
    self.m_skillLayer = skill_layer
    self.m_skillLayer:scheduleUpdateWithPriorityLua(function(dt) return self:update(dt) end, 0)

    self.m_bPlaying = false

    local socketNode

    -- 배경
    do
        self.m_bgVisual = MakeAnimator('res/effect/effect_skillcut_goni/effect_skillcut_goni.vrp')
        self.m_bgVisual:setVisible(false)
        self.m_bgVisual:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_bgVisual:setDockPoint(cc.p(0.5, 0.5))
        self.m_skillLayer:addChild(self.m_bgVisual.m_node)

        socketNode = self.m_bgVisual.m_node:getSocketNode('goni')
    end
    
    -- 테이머
    if socketNode then
        self.m_tamerAnimator = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        self.m_tamerAnimator:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_tamerAnimator:setDockPoint(cc.p(0.5, 0.5))
                
        socketNode:addChild(self.m_tamerAnimator.m_node)
    end

    self:initState()
    self:changeState(TAMER_SKILL_CUT_TYPE__IDLE)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function TamerSkillCut:initState()
    self:addState(TAMER_SKILL_CUT_TYPE__IDLE, TamerSkillCut.update_idle)
    self:addState(TAMER_SKILL_CUT_TYPE__NORMAL, TamerSkillCut.update_normal)
    self:addState(TAMER_SKILL_CUT_TYPE__SPECIAL, TamerSkillCut.update_special)
end

-------------------------------------
-- function update_idle
-- @brief
-------------------------------------
function TamerSkillCut.update_idle(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_bPlaying = false
        
        if self.m_cbEnd then
            self.m_cbEnd()
            self.m_cbEnd = nil
        end
    end
end

-------------------------------------
-- function update_normal
-- @brief 테이머 스킬
-------------------------------------
function TamerSkillCut.update_normal(self, dt)
    if self:isBeginningStep(0) then
        g_gameScene:flashIn({color = cc.c3b(0, 0, 0), opacity = 100, time = 0.2, cbEnd = function()
            self:nextStep()
        end})

    elseif self:isBeginningStep(1) then
        g_gameScene:gamePause()

        self.m_bgVisual:changeAni('skill_1', false)
        self.m_bgVisual:setVisible(true)
        self.m_bgVisual:addAniHandler(function()
            self:nextStep()
        end)

        self.m_tamerAnimator:changeAni('skill_1', false)

        -- 효과음
        SoundMgr:playEffect('VOICE', 'vo_tamer_basic')
        SoundMgr:playEffect('EFFECT', 'skill_tamer_basic')
        
    elseif self:isBeginningStep(2) then
        self.m_bgVisual:setVisible(false)
        
        g_gameScene:flashOut({color = cc.c3b(255, 255, 255), time = 0.1, cbEnd = function()
            self:nextStep()
        end})     

    elseif self:isBeginningStep(3) then
        g_gameScene:gameResume()
        self:changeState(TAMER_SKILL_CUT_TYPE__IDLE)
    end
end

-------------------------------------
-- function update_special
-- @brief 테이머 궁극기
-------------------------------------
function TamerSkillCut.update_special(self, dt)
    if self:isBeginningStep(0) then
        g_gameScene:gamePause()

        g_gameScene:flashIn({color = cc.c3b(0, 0, 0), time = 0.3, cbEnd = function()
            self:nextStep()
        end})

    elseif self:isBeginningStep(1) then
        self.m_bgVisual:changeAni('skill_2', false)
        self.m_bgVisual:setVisible(true)
        self.m_bgVisual:addAniHandler(function()
            self:nextStep()
        end)

        self.m_tamerAnimator:changeAni('skill_2', false)

        -- 효과음
        SoundMgr:playEffect('VOICE', 'vo_tamer_special')
        SoundMgr:playEffect('EFFECT', 'skill_tamer_special')

    elseif self:isBeginningStep(2) then
        self.m_bgVisual:setVisible(false)
        
        g_gameScene:flashOut({color = cc.c3b(255, 255, 255), time = 0.3, cbEnd = function()
            self:nextStep()
        end})
        
    elseif self:isBeginningStep(3) then
        g_gameScene:gameResume()
        self:changeState(TAMER_SKILL_CUT_TYPE__IDLE)
    end
end

-------------------------------------
-- function isPassedStepTime
-------------------------------------
function TamerSkillCut:isPlaying()
    return self.m_bPlaying
end

-------------------------------------
-- function start
-------------------------------------
function TamerSkillCut:start(type, cbEnd)
    if self.m_bPlaying then return end

    self.m_bPlaying = true

    self:changeState(type)
    self.m_cbEnd = cbEnd or function() end
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSkillCut:onEvent(event_name, t_event, ...)
    local arg = {...}
    local cbEnd = arg[1]

    -- 테이머 스킬
    if (event_name == 'tamer_skill') then
        self:start(TAMER_SKILL_CUT_TYPE__NORMAL, cbEnd)

    -- 테이머 궁극기
    elseif (event_name == 'tamer_special_skill') then
        self:start(TAMER_SKILL_CUT_TYPE__SPECIAL, cbEnd)

    end
end