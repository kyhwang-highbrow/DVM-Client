local PARENT = class(IEventListener:getCloneClass(), IStateHelper:getCloneTable())

local STATE = {
    WAIT = 0,
    PLAY_DRAG_SKILL = 1
}

-------------------------------------
-- class GameDragonSkill
-------------------------------------
GameDragonSkill = class(PARENT, {
        m_world = 'GameWorld',

        m_node = 'cc.Node',

        m_bSkipMode = 'boolean',
                
        -- 스킬을 사용할 드래곤 정보
        m_dragon = 'Dragon',
        m_bReservedDie = 'boolean',     -- 연출 종료후 드래곤을 죽여야하는지 여부(반사데미지 등)
                
        m_skillOpeningCutBg = 'Animator',
        m_skillOpeningCutTop = 'Animator',

        m_skillDescEffect = 'Animator',
        m_skillNameLabel = 'cc.Label',
        m_skillDescLabel = 'cc.Label',

        m_bubble = 'Animator',
        m_speechLabel = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function GameDragonSkill:init(world)
    self.m_world = world

    self.m_node = cc.Node:create()
    g_gameScene.m_viewLayer:addChild(self.m_node)

    self.m_bSkipMode = g_autoPlaySetting:get('skip_mode') or false

    self.m_state = STATE.WAIT

    self.m_dragon = nil
    self.m_bReservedDie = false
            
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

    -- 스킬 설명
    self.m_skillDescEffect = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_skillDescEffect:setPosition(0, -285)
    self.m_node:addChild(self.m_skillDescEffect.m_node)

    self.m_skillDescEffect:changeAni('skill', false)
    self.m_skillDescEffect:setVisible(false)
    
    local titleNode = self.m_skillDescEffect.m_node:getSocketNode('skill_title')
    local descNode = self.m_skillDescEffect.m_node:getSocketNode('skill_dsc')
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()
    
    self.m_skillNameLabel = cc.Label:createWithTTF('', Translate:getFontPath(), 60, 3, cc.size(1000, 200), 1, 1)
    self.m_skillNameLabel:setPosition(0, -20)
    self.m_skillNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_skillNameLabel:setDockPoint(cc.p(0, 0))
	self.m_skillNameLabel:setColor(cc.c3b(84,244,87))
    self.m_skillNameLabel:setScale(font_scale_x, font_scale_y)
    self.m_skillNameLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)
    titleNode:addChild(self.m_skillNameLabel, 11)

    --[[
	local rich_label = UIC_RichLabel()
    rich_label:setFontSize(20)
    rich_label:setDimension(1000, 800)
    rich_label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	rich_label:setDockPoint(cc.p(0, 0))
    rich_label:setAnchorPoint(CENTER_POINT)
	rich_label:enableOutline(cc.c3b(220,220,220), 1)
    self.m_skillDescLabel = rich_label
    descNode:addChild(self.m_skillDescLabel.m_root, 11)
    ]]--

    -- 말풍선
    self.m_bubble = MakeAnimator('res/ui/a2d/ingame_dragon_skill/ingame_dragon_skill.vrp')
    self.m_bubble:setScale(1)
    self.m_bubble:setVisual('skill_gauge', 'bubble_2')
    self.m_bubble:setRepeat(false)
    self.m_bubble:setVisible(false)
    self.m_node:addChild(self.m_bubble.m_node)
    
    local speechNode = self.m_bubble.m_node:getSocketNode('skill_bubble')

    self.m_speechLabel = cc.Label:createWithTTF('', Translate:getFontPath(), 24, 0, cc.size(340, 100), 1, 1)
    self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_speechLabel:setDockPoint(cc.p(0, 0))
	self.m_speechLabel:setColor(cc.c3b(0,0,0))
    self.m_speechLabel:setScale(font_scale_x, font_scale_y)
    speechNode:addChild(self.m_speechLabel)
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function GameDragonSkill:initState()
    self:addState(STATE.WAIT,   function(self, dt) end)
    self:addState(STATE.PLAY_DRAG_SKILL,   GameDragonSkill.st_playDragSkill)
end

-------------------------------------
-- function update_play_drag_skill
-------------------------------------
function GameDragonSkill.st_playDragSkill(self, dt)
    local world = self.m_world
    local ui = self.m_world.m_inGameUI
    local dragon = self.m_dragon
    local timeScale = 1
	local t_dragon_skill_time = g_constant:get('INGAME', 'DRAGON_SKILL_DIRECTION_DURATION')
    local delayTime = t_dragon_skill_time[1]

    if (self:getStep() == 0) then
        if (self:isBeginningStep()) then
            -- 해당 유닛을 제외한 일시 정지
            world:setTemporaryPause(true, dragon)

            -- 경직 중이라면 즉시 해제
            dragon:setSpasticity(false)
            dragon:changeState('skillAppear') -- 수정 필요(의미가 없음...)

            self:nextStep()
        end

    elseif (self:getStep() == 1) then
        if (self:isBeginningStep()) then
            -- 일시 정지
            world:setTemporaryPause(true)

            -- 화면 쉐이킹 멈춤
            world.m_shakeMgr:stopShake()

            if (self.m_bSkipMode) then
                self:nextStep()
            else
                -- UI 숨김
                ui.root:setVisible(false)

                -- 도입부 컷씬
                self:makeSkillOpeningCut(dragon, function()
                    self:nextStep()
                end)
					            
				-- 효과음
				SoundMgr:playEffect('UI', 'ui_drag_scene')

                -- 스킬 이름 및 설명 문구를 표시
                self:makeSkillDesc(dragon, delayTime)
            end
        end
        
    elseif (self:getStep() == 2) then
        if (self:isBeginningStep()) then
			
            if (self.m_bSkipMode) then
                self:nextStep()
            else
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

                self.m_skillOpeningCutTop:setVisible(false)

                self:nextStep()
            end
        end

    elseif (self:getStep() == 3) then
        if (self:isBeginningStep()) then
            -- 드래곤만 일시 정지 제외시킴
            world:setTemporaryPause(true, dragon)

            -- 드래곤 애니메이션
            dragon.m_animator:changeAni('skill_idle', false)

            -- 특정 스킬의 경우 애니메이션과 동시에 회전 연출...
            do
                local active_skill_id = dragon:getSkillID('active')
                local t_dragon_skill = TableDragonSkill():get(active_skill_id)

                if (t_dragon_skill['skill_type'] == 'skill_laser_zet') then
                    local indicatorData = dragon.m_skillIndicator:getIndicatorData()
                    local dir = indicatorData['dir']

                    if (dragon.m_bLeftFormation) then
                        dir = dir + 90
                    else
                        dir = dir - 90
                    end

                    dragon.m_animator:setRotation(dir)
                end
            end


            -- 드래곤 애니메이션 속도 조정
            local duration = dragon:getAniDuration()
            dragon:setTimeScale(duration / delayTime)

            if (not self.m_bSkipMode) then
                -- 카메라 줌인
                do
                    local offset_x = 0

                    if (dragon.m_bLeftFormation) then
                        offset_x = 50
                    else
                        offset_x = -50
                    end

                    world.m_gameCamera:setAction({
                        pos_x = dragon.pos.x - (CRITERIA_RESOLUTION_X / 2) + offset_x,
                        pos_y = dragon.pos.y,
                        scale = 3,
                        time = delayTime / 4
                    })
                end

                -- 유닛 정보 숨김
                self:setVisible_UnitInfo(false)

                -- 말풍선
                self:makeSpeechBubble(dragon)
            end

        elseif (self:isPassedStepTime(delayTime)) then
            -- 애니메이션 속도 되돌림
            dragon:setTimeScale()

            self:nextStep()

        end

    elseif (self:getStep() == 4) then
        if (self:isBeginningStep()) then
            -- 드래곤 스킬 애니메이션 시작
            dragon:changeState('skillIdle')

            if (not self.m_bSkipMode) then
                -- 카메라 연출
                self:doCameraWork(dragon)

                -- 유닛 정보 표시
                self:setVisible_UnitInfo(true)
            end
            
        elseif (self:isPassedStepTime(1.5)) then
            -- 카메라 초기화
            world.m_gameCamera:reset()

            -- 화면 쉐이킹 멈춤
            world.m_shakeMgr:stopShake()

            self:nextStep()
        end

    elseif (self:getStep() == 5) then
        if (self:isPassedStepTime(0.5)) then
            self:nextStep()
        end

    elseif (self:getStep() == 6) then
        if (dragon.m_state ~= 'delegate') then
            self:releaseFocusingDragon()

            -- 스킬 시전 드래곤을 제외한 게임 오브젝트 resume
            world:setTemporaryPause(false, dragon)

            self:changeState(STATE.WAIT)
        end
    end

    do
        local curCameraPosX, curCameraPosY = world.m_gameCamera:getPosition()
        local curCameraScale = world.m_gameCamera:getScale()
        self.m_skillOpeningCutBg:setPosition(CRITERIA_RESOLUTION_X / 2 + curCameraPosX, curCameraPosY)
        self.m_skillOpeningCutBg:setScale(1 / curCameraScale)

        if (dragon.m_bLeftFormation) then
            self.m_skillOpeningCutBg:setFlip(false)
        else
            self.m_skillOpeningCutBg:setFlip(true)
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

    if (dragon.m_bLeftFormation) then
        self.m_skillOpeningCutBg:setFlip(false)
        self.m_skillOpeningCutTop:setFlip(false)
    else
        self.m_skillOpeningCutBg:setFlip(true)
        self.m_skillOpeningCutTop:setFlip(true)
    end
end

-------------------------------------
-- function makeSkillDesc
-- @brief 스킬 설명
-------------------------------------
function GameDragonSkill:makeSkillDesc(dragon, delayTime)
    local active_skill_info = dragon:getSkillIndivisualInfo('active')
    local t_skill = active_skill_info.m_tSkill

    self.m_skillDescEffect.m_node:setFrame(0)
    self.m_skillDescEffect:setVisible(true)
    self.m_skillDescEffect:setTimeScale(0.7)

    local name = active_skill_info:getSkillName()
	local desc = active_skill_info:getSkillDesc()

    --[[
    -- 현재 skill_info 스킬아이디와 드래곤의 액티브스킬 아이디를 비교하여 다르다면
    -- 스킬 강화 된것으로 보고 강화되기전 스킬을 꺼내온다.
    local curr_skill_id = active_skill_info:getSkillID()
    local active_skill_id = dragon.m_charTable['skill_active']
    if (curr_skill_id ~= active_skill_id) then
        local old_skill_info = dragon:getSkillInfoByID(active_skill_id)
        -- 강화 되기 전 스킬 정보를 가져왔을 경우
        if (old_skill_info) then
            -- 이름
            local old_skill_name = old_skill_info:getSkillName()
            if (old_skill_name) then
                name = string.format('%s (%s)', old_skill_name, name)
            end

            -- 설명
            local old_skill_desc = old_skill_info:getSkillDesc()
            if (old_skill_desc) then
                desc = string.format('%s \n %s', old_skill_desc, desc)
            end
        end
    end
    ]]--

    self.m_skillNameLabel:setString(name)
    --self.m_skillDescLabel:setString(desc)
end

-------------------------------------
-- function makeSpeechBubble
-- @brief 말풍선
-------------------------------------
function GameDragonSkill:makeSpeechBubble(dragon)
    
    local did = dragon.m_dragonID
    local flv = dragon.m_tDragonInfo:getFlv()
    local str = TableDragonPhrase:getDragonShout(did, flv)
    self.m_speechLabel:setString(str)

    if (dragon.m_bLeftFormation) then
        self.m_bubble:setPosition(300, 150)
    else
        self.m_bubble:setPosition(-300, 150)
    end
    
    self.m_bubble:setFrame(0)
    self.m_bubble:addAniHandler(function()
        self.m_bubble:setVisible(false)
    end)
    self.m_bubble:setVisible(true)

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
-- function doCameraWork
-------------------------------------
function GameDragonSkill:doCameraWork(dragon)
    local world = self.m_world
    local active_skill_id = dragon:getSkillID('active')
    local t_skill = TableDragonSkill():get(active_skill_id)
    
    local cameraWorkType = t_skill['camera_work'] or 'close_up'
    local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
    local cameraHomeScale = world.m_gameCamera:getHomeScale()
    
    world.m_gameCamera:clearTarget()

	-- 전체 화면 줌 아웃
    if (cameraWorkType == 'full') then
        world.m_gameCamera:setAction({
            pos_x = cameraHomePosX,
            pos_y = cameraHomePosY,
            scale = 0.8,
            time = 0.25
        })

        -- 화면 쉐이킹
        world.m_shakeMgr:doShakeUpDown(25, 10)

	-- 사용자를 쫓아간다
    elseif (cameraWorkType == 'tracking') then
        world.m_gameCamera:setTarget(dragon, {
            scale = 1.2,
            time = 0.25
        })

	-- 반대 진형에 포커스 + 확대
    elseif (cameraWorkType == 'close_up') then
        local pos_x

        if (dragon.m_bLeftFormation) then
            pos_x = CRITERIA_RESOLUTION_X / 4
        else
            pos_x = -(CRITERIA_RESOLUTION_X / 4)
        end
                
        world.m_gameCamera:setAction({
            pos_x = pos_x + cameraHomePosX,
            pos_y = cameraHomePosY,
            scale = 1.2,
            time = 0.25
        })
    end
end

-------------------------------------
-- function setVisible_UnitInfo
-------------------------------------
function GameDragonSkill:setVisible_UnitInfo(b)
    self.m_world.m_unitStatusNode:setVisible(b)
    self.m_world.m_unitInfoNode:setVisible(b)
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameDragonSkill:onEvent(event_name, t_event, ...)
    if (event_name == 'damaged') then
        local arg = {...}
        local dragon = arg[1]
        local will_die = t_event['will_die']

        -- 연출 중인 드래곤이 데미지를 입고 죽었을 경우(반사 데미지 등)
        -- 강제로 죽음 막음 처리 후 연출 종료시 죽도록 처리
        if (self:isPlaying()) then
            if (will_die and dragon == self.m_dragon) then
                self.m_dragon:setZombie(true)
                self.m_bReservedDie = true
            end
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
-- function setFocusingDragon
-------------------------------------
function GameDragonSkill:setFocusingDragon(dragon)
    if (not dragon) then return end

    if (self.m_dragon and self.m_dragon ~= dragon) then
        self:releaseFocusingDragon()
    end

    self.m_dragon = dragon
    self.m_bReservedDie = false

    self.m_dragon:addListener('damaged', self)
end

-------------------------------------
-- function releaseFocusingDragon
-------------------------------------
function GameDragonSkill:releaseFocusingDragon()
    if (self.m_dragon) then
        self.m_dragon.m_animator:setRotation(90)

        self.m_dragon:removeListener('damaged', self)

        if (self.m_bReservedDie) then
            self.m_dragon:setZombie(false)
            self.m_dragon:doDie()

        elseif (self.m_dragon.m_state ~= 'delegate') then
            self.m_dragon:changeState('attackDelay')

        end
    end
    
    self.m_dragon = nil
    self.m_bReservedDie = false
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
    return (self.m_state == STATE.PLAY_DRAG_SKILL)
end





-------------------------------------
-- function doPlay
-------------------------------------
function GameDragonSkill:doPlay(unit, skip)
    local dragon = unit
    local skip_mode = g_autoPlaySetting:get('skip_mode') or false

    if (not skip_mode) then
        if (skip ~= nil) then
            skip_mode = skip
        end

        -- 더블 팀 모드의 경우 AI팀의 드래곤은 연출 강제 스킵
        if (isInstanceOf(self.m_world, GameWorldForDoubleTeam)) then
            if (dragon:getPhysGroup() == self.m_world:getNPCGroup()) then
                skip_mode = true
            end
        end
    end

    self.m_bSkipMode = skip_mode

    -- 일시 정지
    self.m_world:setTemporaryPause(true)

    -- 연출 드래곤 설정
    self:setFocusingDragon(dragon)

    self:changeState(STATE.PLAY_DRAG_SKILL)
end