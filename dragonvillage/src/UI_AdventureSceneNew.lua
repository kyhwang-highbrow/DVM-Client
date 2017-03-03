local T_CHAPTER_MAP_RES = {}
T_CHAPTER_MAP_RES[1] = 'res/bg/map_forest/map_forest.vrp'
T_CHAPTER_MAP_RES[2] = 'res/bg/map_ocean/map_ocean.vrp'
T_CHAPTER_MAP_RES[3] = 'res/bg/map_canyon/map_canyon.vrp'
T_CHAPTER_MAP_RES[4] = 'res/bg/map_volcano/map_volcano.vrp'
T_CHAPTER_MAP_RES[5] = 'res/bg/map_sky_temple/map_sky_temple.vrp'
T_CHAPTER_MAP_RES[6] = 'res/bg/map_dark_castle/map_dark_castle.vrp'

-------------------------------------
-- class UI_AdventureSceneNew
-------------------------------------
UI_AdventureSceneNew = class(UI, ITopUserInfo_EventListener:getCloneTable(), {
        m_currChapter = 'number',
        m_currDifficulty = 'number',
        m_openStage = 'number', -- 진입 가능한 스테이지
        m_focusStageIdx = 'number',
        m_adventureShip = 'UI',
        m_adventureShipAnimator = 'Animator',
        m_lStageButton = 'list[UI_AdventureStageButton]',
        m_adventureStageInfoPopup = 'UI_AdventureStageInfo',
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureSceneNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureSceneNew'
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureSceneNew:init(stage_id)
    local vars = self:load('adventure_scene.ui')
    UIManager:open(self, UIManager.NORMAL)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AdventureSceneNew')

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end) -- 이전 챕터
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end) -- 다음 챕터
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end) -- 챕터 선택

    vars['easyBtn']:registerScriptTapHandler(function() self:click_selectDifficultyBtn(1) end)
    vars['normalBtn']:registerScriptTapHandler(function() self:click_selectDifficultyBtn(2) end)
    vars['hardBtn']:registerScriptTapHandler(function() self:click_selectDifficultyBtn(3) end)

    vars['devStageBtn']:registerScriptTapHandler(function()
            if COLOSSEUM_SCENE_ACTIVE then
                local scene = SceneGameColosseum()
                scene:runScene()
            else
                self:openAdventureStageInfoPopup(DEV_STAGE_ID)
            end
        end)
    if (TARGET_SERVER == 'FGT') then
        if (not DEVELOPMENT_KSJ) then
            vars['devStageBtn']:setVisible(false)
        end
    end

    vars['bgSprite']:setLocalZOrder(-2)
    vars['chapterNode']:setLocalZOrder(-1)
    
    self:doActionReset()
    self:doAction()

    -- 비공정 오브젝트 생성
    self:makeShipObject()

    -- 마지막에 진입한 챕터로 진입
    local last_stage = (stage_id or g_adventureDataOld.m_tData['last_stage'])
    local difficulty, chapter, stage = parseAdventureID(last_stage)
    self:refreshChapter(chapter, difficulty, stage)
end

-------------------------------------
-- function makeShipObject
-- @brief 비공정 오브젝트 생성
-------------------------------------
function UI_AdventureSceneNew:makeShipObject()
    self.m_adventureShip = cc.Node:create()
    self.m_adventureShip:setDockPoint(cc.p(0.5, 0.5))
    self.m_adventureShip:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:addChild(self.m_adventureShip)

    local ship_ui = MakeAnimator('res/ui/a2d/chapter_ship/chapter_ship.vrp')
    ship_ui.m_node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(0, 10)), cc.MoveTo:create(0.5, cc.p(0, -10)))))
    self.m_adventureShip:addChild(ship_ui.m_node)
    ship_ui:changeAni('back', true)
    self.m_adventureShipAnimator = ship_ui
end

-------------------------------------
-- function moveShipObject
-- @brief 비공정 오브젝트 이동
-------------------------------------
function UI_AdventureSceneNew:moveShipObject(x, y, immediately, stage_id)
    self.m_adventureShip:stopAllActions()

    if immediately then
        self.m_adventureShip:setPosition(x, y)
        self.m_adventureShipAnimator.m_node:setScaleX(1)
        self.m_adventureShipAnimator:changeAni('back', true)
    else
        local start_x, start_y = self.m_adventureShip:getPosition()

        -- 위, 아래 에니메이션 지정
        if (start_y > y) then
            self.m_adventureShipAnimator:changeAni('front', true)
        else
            self.m_adventureShipAnimator:changeAni('back', true)
        end

        -- 좌, 우 플립
        if (start_x > x) then
            self.m_adventureShipAnimator.m_node:setScaleX(-1)
        else
            self.m_adventureShipAnimator.m_node:setScaleX(1)
        end

        local duration = 0.5
        local action = cc.EaseInOut:create(cc.MoveTo:create(duration, cc.p(x, y)), 2)
        self.m_adventureShip:runAction(action)

        -- stage_id가 지정되었을 경우 비행선 도착 시 팝업
        if stage_id then
            local function func()
                self:openAdventureStageInfoPopup(stage_id)
            end
            action = cc.Sequence:create(action, cc.CallFunc:create(func))
            cca.reserveFunc(self.m_adventureShip, duration, func)
        end
    end
end

-------------------------------------
-- function openAdventureStageInfoPopup
-------------------------------------
function UI_AdventureSceneNew:openAdventureStageInfoPopup(stage_id)
    if (self.m_adventureStageInfoPopup) then
        return
    end

    local function close_cb()
        self.m_adventureStageInfoPopup = nil
    end

    self.m_adventureStageInfoPopup = UI_AdventureStageInfo(stage_id)
    self.m_adventureStageInfoPopup:setCloseCB(close_cb)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_AdventureSceneNew:click_exitBtn()
    local scene = SceneLobby()
    scene:runScene()
end

-------------------------------------
-- function close
-------------------------------------
function UI_AdventureSceneNew:close()
    UI.close(self)
end

-------------------------------------
-- function click_prevBtn
-------------------------------------
function UI_AdventureSceneNew:click_prevBtn()
    local difficulty = self.m_currDifficulty
    local chapter = (self.m_currChapter - 1)

    if g_adventureDataOld:isOpenChapter(difficulty, chapter) then  
        self:refreshChapter(chapter, difficulty)
    else
        local difficulty = g_adventureDataOld:getChapterOpenDifficulty(chapter)
        if (0 < difficulty) then
            self:refreshChapter(chapter, difficulty)
            UIManager:toastNotificationRed(Str('난이도가 변경되었습니다.'))
        end
    end
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_AdventureSceneNew:click_nextBtn()
    local difficulty = self.m_currDifficulty
    local chapter = (self.m_currChapter + 1)

    if g_adventureDataOld:isOpenChapter(difficulty, chapter) then  
        self:refreshChapter(chapter, difficulty)
    else
        local difficulty = g_adventureDataOld:getChapterOpenDifficulty(chapter)
        if (0 < difficulty) then
            self:refreshChapter(chapter, difficulty)
            UIManager:toastNotificationRed(Str('난이도가 변경되었습니다.'))
        else
            UIManager:toastNotificationRed(Str('{1}챕터를 먼저 모험하세요.', self.m_currChapter))
        end
    end
end

-------------------------------------
-- function click_selectBtn
-- @brief 챕터 선택 팝업
-------------------------------------
function UI_AdventureSceneNew:click_selectBtn()
    local ui = UI_AdventureChapterSelectPopup(self.m_currChapter)
    ui.m_cbFunction = function(chapter, difficulty) self:refreshChapter(chapter, difficulty, nil, true) end
end

-------------------------------------
-- function click_selectDifficultyBtn
-- @brief 난이도 변경 버튼
-------------------------------------
function UI_AdventureSceneNew:click_selectDifficultyBtn(difficulty)
    if (self.m_currDifficulty == difficulty) then
        return
    end

    local chapter = self.m_currChapter
    local force = false

    if g_adventureDataOld:isOpenChapter(difficulty, chapter) then  
        self:refreshChapter(chapter, difficulty, nil, force)
    else
        UIManager:toastNotificationRed(Str('이전 난이도를 먼저 클리어하세요!'))
    end
end

-------------------------------------
-- function refreshChapter
-- @breif 챕터 변경
-------------------------------------
function UI_AdventureSceneNew:refreshChapter(chapter, difficulty, stage, force)
    if (not force) and (self.m_currChapter == chapter) and (self.m_currDifficulty == difficulty) then
        return
    end

    local vars = self.vars
    self.m_currChapter = chapter
    self.m_currDifficulty = difficulty or self.m_currDifficulty

    do -- 챕터 전환 연출
        vars['splashLayer']:setLocalZOrder(1)
        vars['splashLayer']:setVisible(true)
        vars['splashLayer']:stopAllActions()
        vars['splashLayer']:setOpacity(255)
        vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.Hide:create()))
    end

    do -- 챕터 이름 지정
        vars['titleLabel']:setString(Str('챕터.{1}', chapter) .. ' ' .. chapterName(chapter))
    end

    do -- 챕터 배경
        vars['chapterNode']:removeAllChildren()
        local res = T_CHAPTER_MAP_RES[chapter]
        local animator = MakeAnimator(res)
        animator:setDefaultAniName('easy')
        if (self.m_currDifficulty == 1) then
            animator:changeAni('easy', true)
        elseif (self.m_currDifficulty == 2) then
            animator:changeAni('normal', true)
        elseif (self.m_currDifficulty == 3) then
            animator:changeAni('hard', true)
        else
            error('self.m_currDifficulty : ' .. self.m_currDifficulty)
        end
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        vars['chapterNode']:addChild(animator.m_node)
    end

    self.m_lStageButton = {}
    for i=1, MAX_ADVENTURE_STAGE do
        vars['stageDock0' .. i]:removeAllChildren()
        local stage_id = makeAdventureID(self.m_currDifficulty, chapter, i)
        local button = UI_AdventureStageButton(self, stage_id)
        vars['stageDock0' .. i]:addChild(button.root)
        self.m_lStageButton[i] = button

        -- 최초 클리어 보상 정보 갱신
        self:refreshFirstReward(stage_id)
    end

    do -- 진입 가능한 스테이지 저장
        local t_ret, focus_stage = g_adventureDataOld:getStageScoreList(self.m_currDifficulty, chapter)
        self.m_openStage = focus_stage

        if stage and g_adventureDataOld:isOpenStage(makeAdventureID(self.m_currDifficulty, chapter, stage)) then
            self:focusStageButton(stage, true, true)
        else
            self:focusStageButton(focus_stage, true, true)
            stage = focus_stage
        end
    end

    -- 이전, 다음 챕터 버튼
    --vars['prevBtn']:setEnabled(1 < chapter)
    vars['prevBtn']:setVisible(1 < chapter)
    --vars['nextBtn']:setEnabled(chapter < MAX_ADVENTURE_CHAPTER)
    vars['nextBtn']:setVisible(chapter < MAX_ADVENTURE_CHAPTER)

    -- 챕터 도전과제
    self:refresh_MissionReward()

    -- 난이도 버튼
    self:refresh_difficultyButtons()

    do -- 마지막에 진입한 스테이지 저장
        local stage_id = makeAdventureID(self.m_currDifficulty, chapter, stage)
        g_stageData:setFocusStage(stage_id)
    end
end

-------------------------------------
-- function refresh_MissionReward
-------------------------------------
function UI_AdventureSceneNew:refresh_MissionReward()
    local chapter = self.m_currChapter
    local difficulty = self.m_currDifficulty

    local chapter_id = (difficulty * 100) + chapter
    local chapter_achieve_info = g_adventureData:getChapterAchieveInfo(chapter_id)

    local vars = self.vars

    local percentage = chapter_achieve_info:getAchievedStarsPercent()
    vars['starBoxGg']:setPercentage(percentage)
    
    local l_star_sction = {8, 16, 24}
    for i,star in ipairs(l_star_sction) do
        local state = chapter_achieve_info:getRewardBoxState(star)

        vars['checkSprite' .. star]:setVisible(false)
        vars['closeSprite' .. star]:setVisible(false)
        vars['openSprite' .. star]:setVisible(false)
        vars['receiveVisual' .. star]:setVisible(false)

        -- 별 갯수를 달성하지 못한 경우
        if (state == 'lock') then
            vars['closeSprite' .. star]:setVisible(true)

        -- 별 갯수를 달성하였지만 보상을 받지 않은 경우
        elseif (state == 'open') then
            vars['openSprite' .. star]:setVisible(true)

        -- 보상까지 받은 경우
        elseif (state == 'received') then
            vars['checkSprite' .. star]:setVisible(true)
        end
    end
end

-------------------------------------
-- function click_stageBtn
-------------------------------------
function UI_AdventureSceneNew:click_stageBtn(stage_id, is_open)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    -- 스테이지 시작
    if (self.m_focusStageIdx == stage) and is_open then
        self:openAdventureStageInfoPopup(stage_id)
        return
    end

    -- 열린 스테이지는 포커싱
    if is_open then
        self:focusStageButton(stage, nil, nil, stage_id)
    else
        -- 잠긴 스테이지는 알림
        local node = self.m_lStageButton[stage].root
        local start_action = cc.MoveTo:create(0.05, cc.p(-20, 0))
        local end_action = cc.EaseElasticOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)), 0.2)
        node:stopAllActions()
        node:runAction(cc.Sequence:create(start_action, end_action))

        UIManager:toastNotificationRed(Str('{1}스테이지를 먼저 모험하세요.', self.m_openStage))
    end
end

-------------------------------------
-- function focusStageButton
-------------------------------------
function UI_AdventureSceneNew:focusStageButton(idx, immediately, b_force, stage_id)
    if (not b_force) and (self.m_focusStageIdx == idx) then
        return
    end

    local prev_btn = self.m_lStageButton[self.m_focusStageIdx]
    if prev_btn then
        prev_btn.vars['selectSprite']:setVisible(false)
        prev_btn.vars['arrowSprite']:setVisible(false)
    end

    local next_btn = self.m_lStageButton[idx]
    if next_btn then
        next_btn.vars['selectSprite']:setVisible(true)
        next_btn.vars['arrowSprite']:setVisible(true)

        next_btn.vars['arrowSprite']:stopAllActions()
        next_btn.vars['arrowSprite']:setPosition(0, 0)
        local sequence = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(0, 20)), cc.MoveTo:create(0.5, cc.p(0, -10)))
        next_btn.vars['arrowSprite']:runAction(cc.RepeatForever:create(sequence))

        -- 배의 위치를 조절
        local x, y = next_btn.root:getParent():getPosition()
        self:moveShipObject(x, y + 50, immediately, stage_id)
    end

    self.m_focusStageIdx = idx

    do -- 마지막에 진입한 스테이지 저장
        local stage_id = makeAdventureID(self.m_currDifficulty, self.m_currChapter, idx)
        g_stageData:setFocusStage(stage_id)
    end
end

-------------------------------------
-- function refresh_difficultyButtons
-- @brief 난이도 관련 버튼 갱신 (쉬움, 보통, 어려움)
-------------------------------------
function UI_AdventureSceneNew:refresh_difficultyButtons()
    local vars = self.vars

    local chapter = self.m_currChapter
    for difficulty=1, MAX_ADVENTURE_DIFFICULTY do

        -- 난이도별 잠금 아이콘
        local is_lock = (not g_adventureDataOld:isOpenChapter(difficulty, chapter))
        local lock_sprite_name = 'lockSprite' .. string.format('%.2d', difficulty)
        vars[lock_sprite_name]:setVisible(is_lock)

        -- 선택된 난이도 아이콘
        local is_selected = (difficulty == self.m_currDifficulty)
        local disable_sprite_name = 'disableSprite' .. string.format('%.2d', difficulty)
        vars[disable_sprite_name]:setVisible(not is_selected)
    end
    
    do -- 난이도에 따라 sprite표시
        local difficulty = self.m_currDifficulty
        vars['easySprite']:setVisible(false)
        vars['normalSprite']:setVisible(false)
        vars['hardSprite']:setVisible(false)

        vars['easyBtn']:setEnabled(true)
        vars['normalBtn']:setEnabled(true)
        vars['hardBtn']:setEnabled(true)

        if (difficulty == 1) then
            vars['easySprite']:setVisible(true)
            vars['easyBtn']:setEnabled(false)

        elseif (difficulty == 2) then
            vars['normalSprite']:setVisible(true)
            vars['normalBtn']:setEnabled(false)

        elseif (difficulty == 3) then
            vars['hardSprite']:setVisible(true)
            vars['hardBtn']:setEnabled(false)

        else
            error('difficulty : ' .. difficulty)
        end
    end
end


-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 start
-------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function refreshFirstReward
-- @brief stage_id에 해당하는 최초 클리어 보상 정보를 갱신함
-------------------------------------
function UI_AdventureSceneNew:refreshFirstReward(stage_id)
    local vars = self.vars

    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local first_reward_state = g_adventureDataOld:getFirstRewardInfo(stage_id)

    local reward_btn = vars['rewardBtn' .. stage]

    if (not reward_btn) then
        return
    end

    reward_btn:registerScriptTapHandler(function() self:click_firstRewardBtn(stage_id) end)

    local exist_reward = (first_reward_state ~= 'NA')
    reward_btn:setVisible(exist_reward)

    -- 보상 정보가 없으면 리턴
    if (not exist_reward) then
        return
    end

    do -- 첫 아이템 생성
        local drop_helper = DropHelper(stage_id)
        local icon = drop_helper:getDisplayItemImage()
        icon.vars['clickBtn']:setEnabled(false)
        vars['rewardIconNode' .. stage]:removeAllChildren()
        vars['rewardIconNode' .. stage]:addChild(icon.root)
    end

    -- 최초 보상 정도에 따라 UI 설정
    if (first_reward_state == 'lock') then
        vars['rewardReceiveVisual' .. stage]:setVisible(false)
        vars['rewardCheckSprite' .. stage]:setVisible(false)

    elseif (first_reward_state == 'open') then
        vars['rewardReceiveVisual' .. stage]:setVisible(true)
        vars['rewardCheckSprite' .. stage]:setVisible(false)

    elseif (first_reward_state == 'finish') then
        vars['rewardReceiveVisual' .. stage]:setVisible(false)
        vars['rewardCheckSprite' .. stage]:setVisible(true)

    else
        error('first_reward_state : ' .. first_reward_state)
    end
end

-------------------------------------
-- function click_firstRewardBtn
-- @brief
-------------------------------------
function UI_AdventureSceneNew:click_firstRewardBtn(stage_id)
    UI_AdventureFirstRewardPopup(stage_id, function() self:refreshFirstReward(stage_id) end)
end


-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 end
-------------------------------------------------------------------------------------------------------------------