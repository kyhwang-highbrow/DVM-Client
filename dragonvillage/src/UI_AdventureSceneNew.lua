-------------------------------------
-- class UI_AdventureSceneNew
-------------------------------------
UI_AdventureSceneNew = class(UI, ITopUserInfo_EventListener:getCloneTable(), {
        m_currChapter = 'number',
        m_openStage = 'number', -- 진입 가능한 스테이지
        m_focusStageIdx = 'number',
        m_adventureShip = 'UI',
        m_adventureShipAnimator = 'Animator',
        m_lStageButton = 'list[UI_AdventureStageButton]',
        m_speechBallonLabel = 'RichLabel',
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
function UI_AdventureSceneNew:init()
    local vars = self:load('adventure_scene_02.ui')
    UIManager:open(self, UIManager.NORMAL)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AdventureSceneNew')

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end) -- 이전 챕터
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end) -- 다음 챕터
    vars['selectBtn']:registerScriptTapHandler(function() self:click_selectBtn() end) -- 챕터 선택

    vars['normalBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('미구현 기능입니다.') end)
    vars['hardBtn']:registerScriptTapHandler(function() UIManager:toastNotificationRed('미구현 기능입니다.') end)
    
    self:doActionReset()
    self:doAction()

    -- 비공정 오브젝트 생성
    self:makeShipObject()

    -- 마지막에 진입한 챕터로 진입
    local last_chapter = g_adventureData.m_tData['last_chapter'] or 1
    self:refreshChapter(last_chapter)
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
function UI_AdventureSceneNew:moveShipObject(x, y, immediately)
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

        self.m_adventureShip:runAction(cc.EaseInOut:create(cc.MoveTo:create(0.5, cc.p(x, y)), 2))
    end
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
    self:refreshChapter(self.m_currChapter - 1)
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_AdventureSceneNew:click_nextBtn()
    self:refreshChapter(self.m_currChapter + 1)
end

-------------------------------------
-- function click_selectBtn
-- @brief 챕터 선택 팝업
-------------------------------------
function UI_AdventureSceneNew:click_selectBtn()
    local ui = UI_AdventureChapterSelectPopup(self.m_currChapter)
    ui.m_cbFunction = function(chapter) self:refreshChapter(chapter, true) end
end

-------------------------------------
-- function refreshChapter
-- @breif 챕터 변경
-------------------------------------
function UI_AdventureSceneNew:refreshChapter(chapter, force)
    if (not force) and (self.m_currChapter == chapter) then
        return
    end

    local vars = self.vars
    self.m_currChapter = chapter

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
        local bg = cc.Sprite:create('res/bg/world_map/chapter_0' .. chapter .. '.png')
        bg:setDockPoint(cc.p(0.5, 0.5))
        bg:setAnchorPoint(cc.p(0.5, 0.5))
        vars['chapterNode']:addChild(bg)
    end

    self.m_lStageButton = {}
    for i=1, MAX_ADVANTURE_STAGE do
        vars['stageDock0' .. i]:removeAllChildren()
        local difficulty = 1
        local stage_id = makeAdventureID(difficulty, chapter, i)
        local button = UI_AdventureStageButton(self, stage_id)
        vars['stageDock0' .. i]:addChild(button.root)
        self.m_lStageButton[i] = button

        -- 최초 클리어 보상 정보 갱신
        self:refreshFirstReward(stage_id)
    end

    do -- 진입 가능한 스테이지 저장
        local t_ret, focus_stage = g_adventureData:getStageScoreList(1, chapter)
        self:focusStageButton(focus_stage, true)
        self.m_openStage = focus_stage
    end

    -- 말풍선
    self:SpeechBalloon(chapter)

    -- 이전, 다음 챕터 버튼
    vars['prevBtn']:setEnabled(1 < chapter)
    vars['nextBtn']:setEnabled(chapter < MAX_ADVENTURE_CHAPTER)


    -- 마지막에 진입한 챕터 저장
    g_adventureData.m_tData['last_chapter'] = chapter
    g_userData:setDirtyLocalSaveData(true)
end

-------------------------------------
-- function SpeechBalloon
-- @breif
-------------------------------------
function UI_AdventureSceneNew:SpeechBalloon(chapter)
    local speech_ballon_node = self.vars['speechBallonNode']

    speech_ballon_node:stopAllActions()
    speech_ballon_node:setScale(0.5)

    local scale_action = cc.ScaleTo:create(0.2, 1)
    local secuence = cc.Sequence:create(cc.EaseBackInOut:create(scale_action))

    speech_ballon_node:runAction(secuence)


    do
        self.vars['speechBallonLabel']:setVisible(false)
        if self.m_speechBallonLabel then
            self.m_speechBallonLabel:release()
            self.m_speechBallonLabel = nil
        end

        local str = ''
        if (chapter == 1) then
            str = Str('풍속성 드래곤이 유리한 지역이야.\n잘 모르겠으면 [자동배치]를 이용해.')
        elseif (chapter == 2) then
            str = Str('각종 상태이상 효과를 거는 적들이 등장해.\n[리티오] 드래곤을 데려가.')
        elseif (chapter == 3) then
            str = Str('테이머의 능력인 [집중공격]을 사용해봐.\n테이머 터치 -> 대상 지정')
        elseif (chapter == 4) then
            str = Str('궁극기는 적을 한번에 처치할 수 있어.\n화면 우측하단의 [테이머] 버튼을 터치해봐')
        elseif (chapter == 5) then
            str = Str('승급과 진화를 통해 한층 더 강력해 질 수 있지.\n[상점]에서 진화와 승급을 체험할 수 있어.')
        elseif (chapter == 6) then
            str = Str('강력한 몬스터들과 마음껏 싸워봐.\n친밀도가 상승하면 [합동공격]을 할 수 있어.')
        end

        local dock_point = cc.p(0.5, 1)
        local is_limit_message = false
        local rich_label = RichLabel('{@SPEECH}' .. str, 20, 640, 320, TEXT_H_ALIGN_CENTER, TEXT_V_ALIGN_CENTER, dock_point, is_limit_message)
        local width = rich_label:getStringWidth()
        local height = rich_label:getStringHeight()

        self.vars['speedBallonSprite']:setNormalSize(width + 20, 90)

        speech_ballon_node:addChild(rich_label.m_root)
        self.m_speechBallonLabel = rich_label
    end
end

-------------------------------------
-- function click_stageBtn
-------------------------------------
function UI_AdventureSceneNew:click_stageBtn(stage_id, is_open)
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    -- 스테이지 시작
    if (self.m_focusStageIdx == stage) and is_open then
        UI_ReadySceneNew(nil, stage_id)
        return
    end

    -- 열린 스테이지는 포커싱
    if is_open then
        self:focusStageButton(stage)
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
function UI_AdventureSceneNew:focusStageButton(idx, immediately)
    if (self.m_focusStageIdx == idx) then
        return
    end

    local difficulty = 1
    local chapter = self.m_currChapter
    local stage = idx
    local stage_id = makeAdventureID(difficulty, chapter, stage)

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
        self:moveShipObject(x, y + 50, immediately)
    end

    self.m_focusStageIdx = idx


    
end


-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 start
-------------------------------------------------------------------------------------------------------------------

-------------------------------------
-- function refreshFirstReward
-- @brief stage_id에 해당하는 최초 클리어 보상 정보를 갱신함
-------------------------------------
function UI_AdventureSceneNew:refreshFirstReward(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local first_reward_state = g_adventureData:getFirstRewardInfo(stage_id)

    local reward_btn = self.vars['rewardBtn' .. stage]

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

    -- 최초 보상 정도에 따라 UI 설정
    if (first_reward_state == 'lock') then
        self.vars['receiveVisual' .. stage]:setVisible(false)
        self.vars['closeSprite' .. stage]:setVisible(true)
        self.vars['openSprite' .. stage]:setVisible(false)

    elseif (first_reward_state == 'open') then
        self.vars['receiveVisual' .. stage]:setVisible(true)
        self.vars['closeSprite' .. stage]:setVisible(true)
        self.vars['openSprite' .. stage]:setVisible(false)

    elseif (first_reward_state == 'finish') then
        self.vars['receiveVisual' .. stage]:setVisible(false)
        self.vars['closeSprite' .. stage]:setVisible(false)
        self.vars['openSprite' .. stage]:setVisible(true)

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