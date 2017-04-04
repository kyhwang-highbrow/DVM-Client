local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

GAME_DRAGON_SKILL_WAIT = 0
GAME_DRAGON_SKILL_LIVE = 1
GAME_DRAGON_SKILL_LIVE2 = 2

-------------------------------------
-- class GameDragonSkill
-------------------------------------
GameDragonSkill = class(PARENT, {
        m_world = 'GameWorld',

        m_node = 'cc.Node',
        
        -- 스킬을 사용할 드래곤 정보
        m_dragon = 'Dragon',
        m_bonusLevel = 'number',
        m_targetPosX = 'number',
        m_targetPosY = 'number',
                
        m_skillOpeningCutBg = 'Animator',
        m_skillOpeningCutTop = 'Animator',

        m_dragonCut = 'Animator',

        m_skillDescEffect = 'Animator',
        m_skillNameLabel = 'cc.Label',
        m_skillDescLabel = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function GameDragonSkill:init(world)
    self.m_world = world

    self.m_node = cc.Node:create()
    g_gameScene.m_viewLayer:addChild(self.m_node)

    self.m_state = GAME_DRAGON_SKILL_WAIT

    self.m_dragon = nil
    self.m_bonusLevel = 0
    self.m_targetPosX = 0
    self.m_targetPosY = 0
    
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
    g_gameScene.m_gameHighlightNode:addChild(self.m_skillOpeningCutBg.m_node, -1)
    
    self.m_skillOpeningCutTop = MakeAnimator('res/effect/cutscene_a_type/cutscene_a_type_top.vrp')
    self.m_skillOpeningCutTop:changeAni('scene_1', false)
    self.m_skillOpeningCutTop:setVisible(false)
    self.m_node:addChild(self.m_skillOpeningCutTop.m_node)

    self.m_dragonCut = nil

    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, 200)
    self.m_skillDescEffect:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillDescEffect:setDockPoint(cc.p(0.5, 0))
    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
    self.m_world.m_inGameUI.root:addChild(self.m_skillDescEffect.m_node, 10)

    local titleNode = self.m_skillDescEffect.m_node:getSocketNode('skill_title')
    local descNode = self.m_skillDescEffect.m_node:getSocketNode('skill_dsc')
    
    self.m_skillNameLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 60, 3, cc.size(800, 200), 1, 1)
    self.m_skillNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillNameLabel:setDockPoint(cc.p(0, 0))
	self.m_skillNameLabel:setColor(cc.c3b(84,244,87))
    self.m_skillNameLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    titleNode:addChild(self.m_skillNameLabel, 11)

    self.m_skillDescLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 30, 3, cc.size(800, 200), 1, 1)
    self.m_skillDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillDescLabel:setDockPoint(cc.p(0, 0))
	self.m_skillDescLabel:setColor(cc.c3b(220,220,220))
    self.m_skillDescLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    descNode:addChild(self.m_skillDescLabel, 11)
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

            -- 일시 정지
            world:setTemporaryPause(true)

            -- 도입부 컷씬
            self:makeSkillOpeningCut(dragon, function()
                self:nextStep()
            end)
        end
        
    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            -- UI 표시
            ui.root:setVisible(true)

            -- 임시 처리... 레이어 교체
            self.m_skillOpeningCutBg.m_node:retain()
            self.m_skillOpeningCutBg.m_node:removeFromParent()
            self.m_world.m_dragonSkillBgNode:addChild(self.m_skillOpeningCutBg.m_node)
            self.m_skillOpeningCutBg.m_node:release()

            self.m_skillOpeningCutBg:setVisible(true)
            self.m_skillOpeningCutBg:changeAni('scene_3', false)
            self.m_skillOpeningCutBg:addAniHandler(function()
                self.m_skillOpeningCutBg:setVisible(false)
            end)

            --[[
            self.m_skillOpeningCutTop:setVisible(true)
            self.m_skillOpeningCutTop:changeAni('scene_3', false)
            self.m_skillOpeningCutTop:setPosition(-300, 0)
            self.m_skillOpeningCutTop:addAniHandler(function()
                self.m_skillOpeningCutTop:setVisible(false)
            end)

            -- 컷씬
            self:makeDragonCut(dragon, function()
                -- 화면 쉐이킹
                world.m_shakeMgr:doShake(50, 50, 1)

                self:nextStep()
            end)
            ]]--
            --self.m_skillOpeningCutBg:setVisible(false)
            self.m_skillOpeningCutTop:setVisible(false)
            self:nextStep()
        end

    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
            -- 카메라 줌인
            world.m_gameCamera:setTarget(dragon, {scale = 3, time = delayTime / 4})

            -- 컷씬 삭제
            if (self.m_dragonCut) then
                self.m_dragonCut:release()
                self.m_dragonCut = nil
            end

            -- 드래곤만 일시 정지 제외시킴
            world:setTemporaryPause(true, dragon)

            -- 드래곤 애니메이션
            dragon.m_animator:changeAni('skill_idle', false)

            -- 애니메이션 속도 조정
            local duration = dragon:getAniDuration()
            dragon.m_animator:setTimeScale(duration / delayTime)

            -- 스킬 이름 및 설명 문구를 표시
            self:makeSkillDesc(dragon, delayTime)
                        
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
        if (self:isBeginningStep()) then
            -- 드래곤 스킬 애니메이션 시작
            dragon:changeState('skillIdle')

            -- 카메라 연출
            local cameraWorkingType = self:getCameraWorkingType(dragon)
            local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
            local cameraHomeScale = world.m_gameCamera:getHomeScale()
            world.m_gameCamera:clearTarget()
            
            if (cameraWorkingType == 1) then
                world.m_gameCamera:setAction({
                    pos_x = cameraHomePosX,
                    pos_y = cameraHomePosY,
                    scale = 0.8,
                    time = 0.25
                })

                -- 화면 쉐이킹
                world.m_shakeMgr:doShakeUpDown(25, 10)
            else
                
                world.m_gameCamera:setAction({
                    pos_x = CRITERIA_RESOLUTION_X / 4 + cameraHomePosX,
                    pos_y = cameraHomePosY,
                    scale = 1.2,
                    time = 0.25
                })
            end

        elseif (self:isPassedStepTime(1.5)) then
            -- 카메라 초기화
            world.m_gameCamera:reset()

            -- 화면 쉐이킹 멈춤
            world.m_shakeMgr:stopShake()
            
        elseif (self:isPassedStepTime(2)) then
            self.m_dragon = nil

            self:changeState(GAME_DRAGON_SKILL_WAIT)

            -- 스킬 시전 드래곤을 제외한 게임 오브젝트 resume
            world:setTemporaryPause(false, dragon)
        end
    end

    do
        local realCameraHomePosX, realCameraHomePosY = world.m_gameCamera:getPosition()
        self.m_skillOpeningCutBg:setPosition(CRITERIA_RESOLUTION_X / 2 + realCameraHomePosX, realCameraHomePosY)
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
            -- 카메라 줌인
            local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
            
            world.m_gameCamera:setAction({
                pos_x = dragon.pos.x - (CRITERIA_RESOLUTION_X / 2),
                pos_y = dragon.pos.y,
                scale = 1.2,
                time = 0.25
            })

            -- 효과음
            SoundMgr:playEffect('EFFECT', 'skill_ready')

        elseif (self:isPassedStepTime(time1 / 2)) then
            world.m_gameCamera:reset()
        
        elseif (self:isPassedStepTime(time1)) then
            self.m_dragon = nil

            self:changeState(GAME_DRAGON_SKILL_WAIT)
        end
    end
end

-------------------------------------
-- function makeSkillOpeningCut
-- @brief 액자 컷
-------------------------------------
function GameDragonSkill:makeSkillOpeningCut(dragon, cbEnd)
    self.m_skillOpeningCutBg.m_node:retain()
    self.m_skillOpeningCutBg.m_node:removeFromParent()
    g_gameScene.m_gameHighlightNode:addChild(self.m_skillOpeningCutBg.m_node, -1)
    self.m_skillOpeningCutBg.m_node:release()

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
        dragonNode:removeAllChildren()

        local aniName = self:getDragonAniForCut(dragon)
        local res_name = dragon.m_animator.m_resName
        local animator = MakeAnimator(res_name)
        animator:changeAni(aniName, false)
        dragonNode:addChild(animator.m_node)

        -- 드래곤 애니메이션 속도 조정
        local delayTime = self.m_skillOpeningCutBg:getDuration() - 0.2
        local duration = animator:getDuration()
        animator:setTimeScale(duration / delayTime)
    end

    self.m_skillOpeningCutTop:changeAni('scene_1', false)
    self.m_skillOpeningCutTop:setPosition(0, 0)
    self.m_skillOpeningCutTop:setVisible(true)
end

-------------------------------------
-- function makeSkillDesc
-- @brief 스킬 설명
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
-- @brief 포효씬 드래곤 컷
-------------------------------------
function GameDragonSkill:makeDragonCut(dragon, cbEnd)
    if (self.m_dragonCut) then
        self.m_dragonCut:release()
        self.m_dragonCut = nil
    end

    local res_name = dragon.m_animator.m_resName
    local animator = MakeAnimator(res_name)
    self.m_node:addChild(animator.m_node)

    local aniName = self:getDragonAniForCut(dragon)
    animator:changeAni('skill_appear', false)
        
    local bFlip = dragon.m_animator.m_bFlip
    if (bFlip) then
        animator:setPosition(300, 2000)
        animator:setScale(1.5)
        animator:setFlip(true)
        animator:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(300, -50)),
            cc.CallFunc:create(function()
                animator:changeAni(aniName, false)
                animator:addAniHandler(cbEnd)
            end)
        ))
    else
        animator:setPosition(-300, 2000)
        animator:setScale(1.5)
        animator:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.5, cc.p(-300, -50)),
            cc.CallFunc:create(function()
                animator:changeAni(aniName, false)
                animator:addAniHandler(cbEnd)
            end)
        ))
    end

    self.m_dragonCut = animator
end

-------------------------------------
-- function getDragonAniForCut
-------------------------------------
function GameDragonSkill:getDragonAniForCut(dragon)
    local aniName = 'idle'

    if (dragon.m_charTable['type']  == 'powerdragon') then
        if (dragon.m_tDragonInfo['evolution'] == 3) then
            aniName = 'skill_appear'
        else
            aniName = 'pose_2'
        end
    elseif (dragon.m_charTable['type']  == 'pinkbell') then
        aniName = 'attack'
    elseif (dragon.m_charTable['type']  == 'lightningdragon') then
        if (dragon.m_charTable['attr'] == T_ATTR_LIST[ATTR_FIRE]) then
            aniName = 'pose_2'
        else
            aniName = 'pose_1'
        end
    elseif (dragon.m_charTable['type']  == 'clowndragon') then
        aniName = 'skill_appear'
    elseif (dragon.m_charTable['type']  == 'wonderdragon') then
        aniName = 'attack'
    elseif (dragon.m_charTable['type']  == 'blackdragon') then
        aniName = 'pose_1'
    elseif (dragon.m_charTable['type']  == 'smartdragon') then
        aniName = 'pose_1'
    end

    return aniName
end

-------------------------------------
-- function getDragonAniForCut
-------------------------------------
function GameDragonSkill:getCameraWorkingType(dragon)
    local type = 0

    if (dragon.m_charTable['type']  == 'lightningdragon') then
        type = 1
    end

    return type
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameDragonSkill:onEvent(event_name, t_event, ...)
    if (event_name == 'dragon_active_skill') then
        local arg = {...}
        local dragon = arg[1]

        -- 보너스 레벨 설정
        local active_skill_id = dragon:getSkillID('active')
        local t_skill = TableDragonSkill():get(active_skill_id)
        local score = dragon.m_skillIndicator.m_resultScore

        self.m_dragon = dragon
        self.m_bonusLevel = SkillHelper:getDragonActiveSkillBonusLevel(t_skill, score)
        self.m_targetPosX = dragon.m_skillIndicator.m_targetPosX
        self.m_targetPosY = dragon.m_skillIndicator.m_targetPosY

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
-- function getFocusingDragon
-------------------------------------
function GameDragonSkill:getFocusingDragon()
    return self.m_dragon
end

-------------------------------------
-- function isPlaying
-------------------------------------
function GameDragonSkill:isPlaying()
    return (self:isPlayingActiveSkill())
end

-------------------------------------
-- function isPlayingActiveSkill
-------------------------------------
function GameDragonSkill:isPlayingActiveSkill()
    return (self.m_state == GAME_DRAGON_SKILL_LIVE)
end

-------------------------------------
-- function isPlayingTimeSkill
-------------------------------------
function GameDragonSkill:isPlayingTimeSkill()
    return (self.m_state == GAME_DRAGON_SKILL_LIVE2)
end