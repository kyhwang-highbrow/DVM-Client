local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

GAME_DRAGON_SKILL_WAIT = 0
GAME_DRAGON_SKILL_LIVE = 1

-------------------------------------
-- class GameDragonSkill
-------------------------------------
GameDragonSkill = class(PARENT, {
        m_world = 'GameWorld',
        
        -- 스킬을 사용할 드래곤 정보
        m_dragon = 'Dragon',
                
        m_skillDescEffect = 'Animator',
        m_skillNameLabel = 'cc.Label',
        m_skillDescLabel = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function GameDragonSkill:init(world)
    self.m_world = world
    self.m_state = GAME_DRAGON_SKILL_WAIT

    self.m_dragon = nil
    
    self:initState()
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function GameDragonSkill:initUI()
    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, -200)
    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
    --g_gameScene.m_containerLayer:addChild(self.m_skillDescEffect.m_node)
    g_gameScene.m_viewLayer:addChild(self.m_skillDescEffect.m_node)

    local titleNode = self.m_skillDescEffect.m_node:getSocketNode('skill_title')
    local descNode = self.m_skillDescEffect.m_node:getSocketNode('skill_dsc')
    
    self.m_skillNameLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 60, 3, cc.size(800, 200), 1, 1)
    self.m_skillNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillNameLabel:setDockPoint(cc.p(0, 0))
	self.m_skillNameLabel:setColor(cc.c3b(84,244,87))
    self.m_skillNameLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    titleNode:addChild(self.m_skillNameLabel)

    self.m_skillDescLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 30, 3, cc.size(800, 200), 1, 1)
    self.m_skillDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillDescLabel:setDockPoint(cc.p(0, 0))
	self.m_skillDescLabel:setColor(cc.c3b(220,220,220))
    self.m_skillDescLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    descNode:addChild(self.m_skillDescLabel)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameDragonSkill:initState()
    self:addState(GAME_DRAGON_SKILL_WAIT,   function(self, dt) end)
    self:addState(GAME_DRAGON_SKILL_LIVE,   GameDragonSkill.update_live)
end

-------------------------------------
-- function update
-------------------------------------
function GameDragonSkill:update(dt)
    return PARENT.update(self, dt)
end

-------------------------------------
-- function update_live
-------------------------------------
function GameDragonSkill.update_live(self, dt)
    local dragon = self.m_dragon
    local timeScale = 0.1
    local delayTime = 1
    
    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            self.m_world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_DRAGON_SKILL)

            -- 암전
            self.m_world.m_gameHighlight:changeDarkLayerColor(254, 0.5)

            -- 슬로우
            self.m_world.m_gameTimeScale:set(timeScale)

            -- 드래곤 승리 애니메이션
            dragon.m_animator:changeAni('pose_1', false)

            local duration = dragon:getAniDuration()
            dragon.m_animator:setTimeScale(duration / (timeScale * delayTime))
        
            -- 카메라 줌인
            --self.m_world.m_gameCamera:setTarget(dragon, {time = timeScale / 8})

            -- 스킬 이름 및 설명 문구를 표시
            do
                local active_skill_id = dragon:getSkillID('active')
                local t_skill = TABLE:get('dragon_skill')[active_skill_id]

                self.m_skillDescEffect.m_node:setFrame(0)
                self.m_skillDescEffect:setVisible(true)
                --self.m_skillDescEffect:setTimeScale(duration / (timeScale * delayTime))
                self.m_skillDescEffect:setTimeScale(0.5 / timeScale)

                self.m_skillNameLabel:setString(Str(t_skill['t_name']))
                self.m_skillDescLabel:setString(IDragonSkillManager:getSkillDescPure(t_skill))
            end

            -- 스킬 사용 직전 이펙트
            do
                local attr = dragon:getAttribute()
                local animator = MakeAnimator(string.format('res/effect/effect_skillcut_dragon/effect_skillcut_dragon_%s.vrp', attr))
                animator:changeAni('idle', false)
                animator:setPosition(0, 80)
                g_gameScene.m_viewLayer:addChild(animator.m_node)

                local duration = animator:getDuration() * delayTime
                animator:setTimeScale(duration / (timeScale * delayTime))
                animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
            end

            -- 컷씬
            do
                self:makeDragonCut(dragon, timeScale, delayTime)
            end

            -- 효과음
            SoundMgr:playEffect('EFFECT', 'skill_ready')

            -- 음성
            playDragonVoice(dragon.m_charTable['type'])
        
        elseif (self:isPassedStepTime(timeScale * delayTime)) then
            self:nextStep()

        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            
            -- 기본 속도로 되돌림
            self.m_world.m_gameTimeScale:set(1)
            self.m_skillDescEffect:setTimeScale(0.5)

            -- 드래곤 스킬 애니메이션
            dragon:changeState('skillIdle')
            dragon.m_animator:setTimeScale(1)

            -- 카메라 줌아웃
            --self.m_world.m_gameCamera:reset()

            -- 스킬 시전 드래곤을 제외한 게임 오브젝트 일시 정지
            self:setTemporaryPause(true, dragon)

        elseif (self:isPassedStepTime(2)) then
            self.m_world.m_gameHighlight:changeDarkLayerColor(0, 1)

        elseif (self:isPassedStepTime(2.7)) then
            self.m_world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_HIDE)
            self.m_world.m_gameHighlight:clear()

        elseif (self:isPassedStepTime(3)) then
            self.m_dragon = nil

            self:changeState(GAME_DRAGON_SKILL_WAIT)

            -- 스킬 시전 드래곤을 제외한 게임 오브젝트 resume
            self:setTemporaryPause(false)
        end
    end
end

-------------------------------------
-- function setTemporaryPause
-- @brief 스킬 사용 도중 시전 드래곤을 제외하고 일시 정지
-------------------------------------
function GameDragonSkill:setTemporaryPause(pause, excluded_dragon)
    local world = self.m_world

    -- 일시 정지
    if pause then
        -- unit들 일시 정지
        for i,v in pairs(world.m_lUnitList) do
            v:setTemporaryPause(true)
        end

        -- 미사일들 액션 정지
        local action_mgr = cc.Director:getInstance():getActionManager()
        for i,v in pairs(world.m_lMissileList) do
            action_mgr:pauseTarget(v.m_rootNode)
        end

        -- 스킬 사용 중인 드래곤은 일시 정지에서 제외
        if excluded_dragon then
            excluded_dragon:setTemporaryPause(false)
        end
    -- 전투 재개
    else
        -- unit들 일시 정지 해제
        for i,v in pairs(world.m_lUnitList) do
            v:setTemporaryPause(false)
        end

        -- 미사일들 액션 재개
        local action_mgr = cc.Director:getInstance():getActionManager()
        for i,v in pairs(world.m_lMissileList) do
            action_mgr:resumeTarget(v.m_rootNode)
        end
    end
end

-------------------------------------
-- function makeDragonCut
-------------------------------------
function GameDragonSkill:makeDragonCut(dragon, timeScale, delayTime)
    local res_name = dragon.m_animator.m_resName

    local animator = MakeAnimator(res_name)
    animator:changeAni('pose_1', false)
    animator:setPosition(-300, -50)
    g_gameScene.m_viewLayer:addChild(animator.m_node)

    animator:setScale(1)
    animator:runAction(cc.ScaleTo:create(timeScale, 1.5))

    local duration = animator:getDuration() * delayTime
    animator:setTimeScale(duration / (timeScale * delayTime))
    animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameDragonSkill:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_skill') then
        local arg = {...}
        local dragon = arg[1]

        self.m_dragon = dragon

        self:changeState(GAME_DRAGON_SKILL_LIVE)
    end
end

-------------------------------------
-- function isPlaying
-------------------------------------
function GameDragonSkill:isPlaying()
    return (self.m_state == GAME_DRAGON_SKILL_LIVE)
end