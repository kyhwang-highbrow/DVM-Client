local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

GAME_DRAGON_SKILL_WAIT = 0
GAME_DRAGON_SKILL_LIVE = 1
GAME_DRAGON_SKILL_LIVE2 = 2

-------------------------------------
-- class GameDragonSkill
-------------------------------------
GameDragonSkill = class(PARENT, {
        m_world = 'GameWorld',
        
        -- 스킬을 사용할 드래곤 정보
        m_dragon = 'Dragon',
                
        m_skillOpeningCutBg = 'Animator',
        m_skillOpeningCutTop = 'Animator',

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
    self.m_skillOpeningCutBg = MakeAnimator('res/effect/cutscene_a_type/cutscene_a_type_bg.vrp')
    self.m_skillOpeningCutBg:changeAni('scene_1', false)
    self.m_skillOpeningCutBg:setVisible(false)
    g_gameScene.m_viewLayer:addChild(self.m_skillOpeningCutBg.m_node)

    self.m_skillOpeningCutTop = MakeAnimator('res/effect/cutscene_a_type/cutscene_a_type_top.vrp')
    self.m_skillOpeningCutTop:changeAni('scene_1', false)
    self.m_skillOpeningCutTop:setVisible(false)
    g_gameScene.m_viewLayer:addChild(self.m_skillOpeningCutTop.m_node)

    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, -200)
    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
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
    self:addState(GAME_DRAGON_SKILL_LIVE2,   GameDragonSkill.update_live2)
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
    local world = self.m_world
    local ui = self.m_world.m_inGameUI
    local dragon = self.m_dragon
    local timeScale = 1
	local t_dragon_skill_time = g_constant:get('INGAME', 'DRAGON_SKILL_DIRECTION_DURATION')
    local delayTime = t_dragon_skill_time[1]

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- UI 숨김
            ui.root:setVisible(false)

            -- 하이라이트 활성화
            world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_DRAGON_SKILL)
            world.m_gameHighlight:changeDarkLayerColor(254, 0)
            world.m_gameHighlight:setVisible(true)
            
            -- 일시 정지
            world:setTemporaryPause(true)

            -- 도입부 컷씬
            self:makeSkillOpeningCut(dragon, function()
                self:nextStep()
            end)
        end

    elseif (self:getStep() == 1) then
        --[[
        if (self:isBeginningStep()) then
            self.m_skillOpeningCutBg:changeAni('scene_2', false)
            self.m_skillOpeningCutBg:addAniHandler(function()
                self.m_skillOpeningCutBg:setVisible(false)
                self.m_skillOpeningCutTop:setVisible(false)

                self:nextStep()
            end)
            self.m_skillOpeningCutTop:changeAni('scene_2', false)
            self.m_skillOpeningCutTop:setPosition(dragon.pos.x - CRITERIA_RESOLUTION_X / 2, dragon.pos.y)
        end
        ]]--
        if (self:isBeginningStep()) then
            -- UI 표시
            ui.root:setVisible(true)

            self.m_skillOpeningCutBg:setVisible(false)
            self.m_skillOpeningCutTop:setVisible(false)

            self:nextStep()
        end
    
    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            -- 하이라이트
            world.m_gameHighlight:addChar(dragon)

            -- 일시 정지
            world:setTemporaryPause(true, dragon)
            
            -- 드래곤 승리 애니메이션
            dragon.m_animator:changeAni('skill_idle', false)

            local duration = dragon:getAniDuration()
            
            -- 애니메이션 속도 조정
            dragon.m_animator:setTimeScale(duration / delayTime)

            -- 스킬 이름 및 설명 문구를 표시
            do
                self:makeSkillDesc(dragon, delayTime)
            end

            -- 스킬 사용 직전 이펙트
            do
                self:makeSkillCutEffect(dragon, delayTime)
            end

            -- 컷씬
            do
                self:makeDragonCut(dragon, delayTime)
            end

            -- 효과음
            SoundMgr:playEffect('EFFECT', 'skill_ready')

            -- 음성
            playDragonVoice(dragon.m_charTable['type'])
        
        elseif (self:isPassedStepTime(delayTime)) then
            -- 애니메이션 속도 되돌림
            dragon.m_animator:setTimeScale(1)

            self:nextStep()

        end

    elseif (self:getStep() == 3) then
        local step_time1 = t_dragon_skill_time[2]
        local step_time2 = t_dragon_skill_time[2] + (t_dragon_skill_time[3] / 2)
        local step_time3 = t_dragon_skill_time[2] + t_dragon_skill_time[3]

        if (self:isBeginningStep()) then
            -- 드래곤 스킬 애니메이션 시작
            dragon:changeState('skillIdle')

        elseif (self:isPassedStepTime(step_time1)) then
            -- 암전 해제
            world.m_gameHighlight:changeDarkLayerColor(0, t_dragon_skill_time[3])

        elseif (self:isPassedStepTime(step_time2)) then
            -- 하이라이트 비활성화
            world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_HIDE)
            world.m_gameHighlight:clear()

        elseif (self:isPassedStepTime(step_time3)) then
            self.m_dragon = nil

            self:changeState(GAME_DRAGON_SKILL_WAIT)

            -- 스킬 시전 드래곤을 제외한 게임 오브젝트 resume
            world:setTemporaryPause(false, dragon)
        end
    end
end

-------------------------------------
-- function update_live2
-------------------------------------
function GameDragonSkill.update_live2(self, dt)
    local world = self.m_world
    local dragon = self.m_dragon
    local timeScale = 1
    local t_dragon_skill_time = g_constant:get('INGAME', 'DRAGON_TIME_SKILL_DIRECTION_DURATION')
	local time1 = t_dragon_skill_time[1]
    local time2 = t_dragon_skill_time[2]
    
    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 하이라이트 활성화
            world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_DRAGON_SKILL)
            world.m_gameHighlight:changeDarkLayerColor(254, 0.1)
            --world.m_gameHighlight:clear()
            world.m_gameHighlight:addChar(dragon)

            for i, enemy in pairs(dragon:getOpponentList()) do
                world.m_gameHighlight:addChar(enemy)
            end
            
            -- 효과음
            SoundMgr:playEffect('EFFECT', 'skill_ready')
        
        elseif (self:isPassedStepTime(0.1 + time1)) then
            -- 암전 해제
            world.m_gameHighlight:changeDarkLayerColor(0, time2)

        elseif (self:isPassedStepTime(0.1 + time1 + (time2 / 2))) then

            -- 하이라이트 비활성화
            world.m_gameHighlight:setMode(GAME_HIGHLIGHT_MODE_HIDE)
            world.m_gameHighlight:clear()

            self.m_dragon = nil

            self:changeState(GAME_DRAGON_SKILL_WAIT)
        end
    end
end

-------------------------------------
-- function makeSkillOpeningCut
-------------------------------------
function GameDragonSkill:makeSkillOpeningCut(dragon, cbEnd)
    self.m_skillOpeningCutBg:changeAni('scene_1', false)
    self.m_skillOpeningCutBg:setVisible(true)
    self.m_skillOpeningCutBg:addAniHandler(function()
        if (cbEnd) then
            cbEnd()
        end
    end)

    -- 드래곤을 생성하여 해당 소켓에 붙임
    do
        local dragonNode = self.m_skillOpeningCutBg.m_node:getSocketNode('dragon')
        local res_name = dragon.m_animator.m_resName
        local animator = MakeAnimator(res_name)
        animator:changeAni('skill_appear', false)
        dragonNode:removeAllChildren()
        dragonNode:addChild(animator.m_node)
    end

    self.m_skillOpeningCutTop:changeAni('scene_1', false)
    self.m_skillOpeningCutTop:setPosition(0, 0)
    self.m_skillOpeningCutTop:setVisible(true)
end

-------------------------------------
-- function makeSkillCutEffect
-------------------------------------
function GameDragonSkill:makeSkillCutEffect(dragon, delayTime)
    local attr = dragon:getAttribute()
    local animator = MakeAnimator(string.format('res/effect/effect_skillcut_dragon/effect_skillcut_dragon_%s.vrp', attr))
    animator:changeAni('idle', false)
    animator:setPosition(0, 80)
    g_gameScene.m_viewLayer:addChild(animator.m_node)

    local duration = animator:getDuration()
    animator:setTimeScale(duration / delayTime)
    animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)
end

-------------------------------------
-- function makeSkillDesc
-------------------------------------
function GameDragonSkill:makeSkillDesc(dragon, delayTime)
    local active_skill_id = dragon:getSkillID('active')
    local t_skill = TableDragonSkill():get(active_skill_id)

    self.m_skillDescEffect.m_node:setFrame(0)
    self.m_skillDescEffect:setVisible(true)
    self.m_skillDescEffect:setTimeScale(0.5)

    self.m_skillNameLabel:setString(Str(t_skill['t_name']))
    self.m_skillDescLabel:setString(IDragonSkillManager:getSkillDescPure(t_skill))
end

-------------------------------------
-- function makeDragonCut
-------------------------------------
function GameDragonSkill:makeDragonCut(dragon, delayTime)
    local res_name = dragon.m_animator.m_resName

    local animator = MakeAnimator(res_name)
    animator:changeAni('skill_idle', false)
    g_gameScene.m_viewLayer:addChild(animator.m_node)

    local duration = animator:getDuration() * delayTime
    animator:setTimeScale(duration / delayTime)
    animator:addAniHandler(function() animator:runAction(cc.RemoveSelf:create()) end)

    local bFlip = dragon.m_animator.m_bFlip
    if (bFlip) then
        animator:setPosition(300, -50)
        animator:setScale(1.5)
        animator:setFlip(true)
    else
        animator:setPosition(-300, -50)
        animator:setScale(1)
        animator:runAction(cc.ScaleTo:create(delayTime, 1.5))
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameDragonSkill:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_active_skill') then
        local arg = {...}
        local dragon = arg[1]

        self.m_dragon = dragon

        self:changeState(GAME_DRAGON_SKILL_LIVE)

    elseif (event_name == 'dragon_time_skill') then
        local arg = {...}
        local dragon = arg[1]

        if (self:isPlaying()) then
        else
            self.m_dragon = dragon

            self:changeState(GAME_DRAGON_SKILL_LIVE2)
        end
    end
end

-------------------------------------
-- function isPlaying
-------------------------------------
function GameDragonSkill:isPlaying()
    return (self.m_state == GAME_DRAGON_SKILL_LIVE)
end