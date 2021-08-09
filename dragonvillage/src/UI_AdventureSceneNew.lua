local T_CHAPTER_MAP_RES = {}
T_CHAPTER_MAP_RES[1] = 'res/bg/map_forest/map_forest.vrp'
T_CHAPTER_MAP_RES[2] = 'res/bg/map_ocean/map_ocean.vrp'
T_CHAPTER_MAP_RES[3] = 'res/bg/map_canyon/map_canyon.vrp'
T_CHAPTER_MAP_RES[4] = 'res/bg/map_volcano/map_volcano.vrp'
T_CHAPTER_MAP_RES[5] = 'res/bg/map_sky_temple/map_sky_temple.vrp'
T_CHAPTER_MAP_RES[6] = 'res/bg/map_dark_castle2/map_dark_castle2.vrp'
T_CHAPTER_MAP_RES[7] = 'res/bg/map_volcano2/map_volcano2.vrp'
T_CHAPTER_MAP_RES[8] = 'res/bg/map_canyon2/map_canyon2.vrp'
T_CHAPTER_MAP_RES[9] = 'res/bg/map_ocean2/map_ocean2.vrp'
T_CHAPTER_MAP_RES[10] = 'res/bg/map_forest2/map_forest2.vrp'
T_CHAPTER_MAP_RES[11] = 'res/bg/map_sky_temple2/map_sky_temple2.vrp'
T_CHAPTER_MAP_RES[12] = 'res/bg/map_dark_castle/map_dark_castle.vrp'
T_CHAPTER_MAP_RES[SPECIAL_CHAPTER.ADVENT] = 'res/bg/map_forest/map_forest.vrp'

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
        m_lFirstRewardButtons = '',
        m_lAchieveRewardButtons = '',

        m_uicSortList = 'UIC_SortList',

        -- 깜짝 출현 챕터
        m_rewindStageId = 'number', -- advent chpater로 진입 시 되돌아올 stage 임시 저장
        m_particle = 'cc.Particle',
        m_adventDragonAniList = 'table<Animator>',

        -- @mskim 20.09.14 UI 정리하면서 추가함, 전역적으로 쓰는 것은 아님
        m_stageId = 'number',


        m_tooltipUI = '',
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureSceneNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureSceneNew'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_dungeon_ready'
    
end

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureSceneNew:init(stage_id)
    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()

    self.m_lAchieveRewardButtons = {}
    self.m_stageId = stage_id

    local vars = self:load('adventure_scene.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_AdventureSceneNew')

    vars['bgSprite']:setLocalZOrder(-2)
    vars['chapterNode']:setLocalZOrder(-1)
    
    self:doActionReset()
    self:doAction()

    self:initUI()
    self:initButton()
    self:refresh()
end


-------------------------------------
-- function focusByStageID
-- @brief
-------------------------------------
function UI_AdventureSceneNew:focusByStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)
    self:refreshChapter(chapter, difficulty, stage)
end

-------------------------------------
-- function initUI
-- @brief
-------------------------------------
function UI_AdventureSceneNew:initUI()
    -- 비공정 오브젝트 생성
    self:makeShipObject()
    self:makeUICSortList()

    -- 마지막에 진입한 챕터로 진입
    local last_stage = (self.m_stageId or g_settingData:get('adventure_focus_stage'))
    local difficulty, chapter, stage = parseAdventureID(last_stage)
    self:refreshChapter(chapter, difficulty, stage)
    self.m_stageId = last_stage

    -- @TODO 임시 처리 mskim
    self.m_uicSortList:setSelectSortType(self.m_currDifficulty)
end

-------------------------------------
-- function initButton
-- @brief
-------------------------------------
function UI_AdventureSceneNew:initButton()
    local vars = self.vars

    vars['prevBtn']:registerScriptTapHandler(function() self:click_prevBtn() end) -- 이전 챕터
    vars['nextBtn']:registerScriptTapHandler(function() self:click_nextBtn() end) -- 다음 챕터

    -- 개발 스테이지 테스트 모드에서만 on
    if IS_TEST_MODE() then
        vars['devStageBtn']:setVisible(true)
        vars['devStageBtn']:registerScriptTapHandler(function() self:click_devStageBtn() end)

        -- 클랜 던전 테스트
        vars['clanraidStageBtn']:setVisible(true)
        -- vars['clanraidStageBtn']:registerScriptTapHandler(function() end)
    else
        vars['devStageBtn']:setVisible(false)
        vars['clanraidStageBtn']:setVisible(false)
    end

    vars['chapterSelectBtn']:setVisible(true)
    vars['chapterSelectBtn']:registerScriptTapHandler(function() self:click_chapterSelectBtn() end)

    vars['adventChapterBtn']:registerScriptTapHandler(function() self:click_adventChapterBtn(true) --[[isToAdvent]] end)
    vars['adventureBtn']:registerScriptTapHandler(function() self:click_adventChapterBtn(false) --[[isToAdvent]] end)

    vars['adventureClearBtn03']:registerScriptTapHandler(function() self:click_adventureClearBtn03() end) -- 모험돌파 패키지 3 -- 2020.09.14 -- 특정 조건에 노출
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_AdventureSceneNew:refresh()
    local vars = self.vars

    -- 모험돌파 버튼 3 2020.08.24
    do
        -- 모험돌파 버튼 .. 지정 스테이지 클리어한 후에는 구매 후 보상 전부 수령할 때까지 노출
        local is_visible = (g_adventureData:getStageClearCnt(g_personalpackData:getStartSid()) > 0) 
                            and g_adventureClearPackageData03:isVisible_adventureClearPackOnAdventureMap()
        vars['adventureClearBtn03']:setVisible(is_visible)

        -- 모험돌파 버튼 연출 추가
        if (is_visible) then
            cca.pickMePickMe(vars['adventureClearBtn03'], 10)
        end

        -- 모험돌파 패키지 노티
        local is_noti = g_adventureClearPackageData03:isVisible_adventureClearPackNoti()
        vars['adventureClearNotiSprite03']:setVisible(is_noti)
    end
end

-------------------------------------
-- function makeUICSortList
-- @brief
-------------------------------------
function UI_AdventureSceneNew:makeUICSortList()
	local button = self.vars['difficultyBtn']
	local label = self.vars['difficultyLabel']

    local width, height = button:getNormalSize()
    local parent = button:getParent()
    local x, y = button:getPosition()

    local uic = UIC_SortList()
    uic.m_direction = UIC_SORT_LIST_BOT_TO_TOP
    uic:setNormalSize(width, height)
    uic:setPosition(x, y)
    uic:setDockPoint(button:getDockPoint())
    uic:setAnchorPoint(button:getAnchorPoint())
    uic:init_container()

    uic:setExtendButton(button)
    uic:setSortTypeLabel(label)

    parent:addChild(uic.m_node)

    uic:addSortType(1, Str('보통'), {color = COLOR['diff_normal'], stroke = 0})
    uic:addSortType(2, Str('어려움'), {color = COLOR['diff_hard'], stroke = 0})
    uic:addSortType(3, Str('지옥'), {color = COLOR['diff_hell'], stroke = 0})
    uic:addSortType(4, Str('불지옥'), {color = COLOR['diff_hellfire'], stroke = 0})

	self.m_uicSortList = uic
	self.m_uicSortList:setSortChangeCB(function(sort_type) 
        self:click_selectDifficultyBtn(sort_type)
    end)
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

    -- 깜짝 출현 챕터 예외 처리
    local front_ani_name, back_ani_name, func_arrival
    if (self.m_currChapter == SPECIAL_CHAPTER.ADVENT) then
        front_ani_name = 'advent_front'
        back_ani_name = 'advent_back'
        func_arrival = function()
            for i, animator in ipairs(self.m_adventDragonAniList) do
                animator:setVisible(i ~= self.m_focusStageIdx)
            end
        end
    else
        front_ani_name = 'front'
        back_ani_name = 'back'
        func_arrival = function() end
    end

    if immediately then
        self.m_adventureShip:setPosition(x, y)
        self.m_adventureShipAnimator.m_node:setScaleX(1)
        self.m_adventureShipAnimator:changeAni(back_ani_name, true)
        func_arrival()
    else
        local start_x, start_y = self.m_adventureShip:getPosition()

        -- 위, 아래 에니메이션 지정
        if (start_y > y) then
            self.m_adventureShipAnimator:changeAni(front_ani_name, true)
        else
            self.m_adventureShipAnimator:changeAni(back_ani_name, true)
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
                func_arrival()
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
    self:close()
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

    self:refreshChapter(chapter, difficulty)

    -- sgkim 2017-08-01 오픈되지 않은 챕터도 진입할 수 있게 변경함
    --if g_adventureData:isOpenChapter(difficulty, chapter) then  
    --    self:refreshChapter(chapter, difficulty)
    --else
    --    local difficulty = g_adventureData:getChapterOpenDifficulty(chapter)
    --    if (0 < difficulty) then
    --        self:refreshChapter(chapter, difficulty)
    --        UIManager:toastNotificationRed(Str('난이도가 변경되었습니다.'))
    --    end
    --end
end

-------------------------------------
-- function click_nextBtn
-------------------------------------
function UI_AdventureSceneNew:click_nextBtn()
    local difficulty = self.m_currDifficulty
    local chapter = (self.m_currChapter + 1)

    self:refreshChapter(chapter, difficulty)

    -- sgkim 2017-08-01 오픈되지 않은 챕터도 진입할 수 있게 변경함
    --if g_adventureData:isOpenChapter(difficulty, chapter) then  
    --    self:refreshChapter(chapter, difficulty)
    --else
    --    local difficulty = g_adventureData:getChapterOpenDifficulty(chapter)
    --    if (0 < difficulty) then
    --        self:refreshChapter(chapter, difficulty)
    --        UIManager:toastNotificationRed(Str('난이도가 변경되었습니다.'))
    --    else
    --        UIManager:toastNotificationRed(Str('{1}챕터를 먼저 모험하세요.', self.m_currChapter))
    --    end
    --end
end

-------------------------------------
-- function click_selectDifficultyBtn
-- @brief 난이도 변경 버튼
-------------------------------------
function UI_AdventureSceneNew:click_selectDifficultyBtn(difficulty)
    if (self.m_currDifficulty == difficulty) then
        return
    end

    -- @TODO 임시 처리 2017.07.07 mskim
    if (MAX_ADVENTURE_DIFFICULTY < difficulty) then
        UIManager:toastNotificationRed(Str('아직 오픈되지 않은 난이도에요!'))
        self.m_uicSortList:setSelectSortType(self.m_currDifficulty)
        return
    end

    local chapter = self.m_currChapter
    local force = false

    self:refreshChapter(chapter, difficulty, nil, force)

    -- sgkim 2017-08-01 오픈되지 않은 챕터도 진입할 수 있게 변경함
    --if g_adventureData:isOpenChapter(difficulty, chapter) then  
    --    self:refreshChapter(chapter, difficulty, nil, force)
    --else
    --    UIManager:toastNotificationRed(Str('이전 난이도를 먼저 클리어하세요!'))
    --end
end

-------------------------------------
-- function click_starBoxBtn
-- @brief
-------------------------------------
function UI_AdventureSceneNew:click_starBoxBtn(star)
    local chapter = self.m_currChapter
    local difficulty = self.m_currDifficulty

    local chapter_id = (difficulty * 100) + chapter

    local ui = UI_ChapterAchieveRewardPopup(chapter_id, star)
    local function close_cb()
        self:refresh_MissionReward()
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_adventureClearBtn03
-- @brief 레벨업 패키지 버튼
-------------------------------------
function UI_AdventureSceneNew:click_adventureClearBtn03()
    local ui = UI_EventFullPopup(PACK_ADVENTURE)
    ui:openEventFullPopup()
end


-------------------------------------
-- function refreshChapter
-- @breif 챕터 변경
-------------------------------------
function UI_AdventureSceneNew:refreshChapter(chapter, difficulty, stage, force)
    if (not force) and (self.m_currChapter == chapter) and (self.m_currDifficulty == difficulty) then
        return
    end
        
    -- tutorial 실행중이라면
    if TutorialManager.getInstance():isDoing() then
        chapter = 1
        difficulty = 1
    end

    local vars = self.vars        
    self.m_currChapter = chapter
    self.m_currDifficulty = difficulty or self.m_currDifficulty

	-- @ TUTORIAL 1-7 클리어 보상
	if (TutorialManager.getInstance():showAmazingNewbiePresent()) then
		vars['clearEventSprite']:setVisible(chapter == 1)
	end

    do -- 챕터 전환 연출
        vars['splashLayer']:setLocalZOrder(1)
        vars['splashLayer']:setVisible(true)
        vars['splashLayer']:stopAllActions()
        vars['splashLayer']:setOpacity(255)
        vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.Hide:create()))
    end

    do -- 챕터 배경
       -- 20190108 챕터 배경 애니는 easy만 존재 (defult값 easy)
        vars['chapterNode']:removeAllChildren()
        local res = T_CHAPTER_MAP_RES[chapter]

        local animator = MakeAnimator(res)
        animator:setDefaultAniName('easy')
        if (difficulty == 1) then
            animator:changeAni('easy', true)
        elseif (difficulty == 2) then
            animator:changeAni('normal', true)
        elseif (difficulty == 3) then
            animator:changeAni('hard', true)
        elseif (difficulty == 4) then
            animator:changeAni('hellfire', true)
        else
            error('difficulty : ' .. difficulty)
        end
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        vars['chapterNode']:addChild(animator.m_node)
    end
    
    -- 핫타임 정보 갱신
    self:refreshHotTimeInfo()

    -- 이전 스테이지 버튼 제거
    self:clearStageButton()

    -- 깜짝 출현 챕터
    if (chapter == SPECIAL_CHAPTER.ADVENT) then
        if (g_hotTimeData:isActiveEvent('event_advent')) then
            self:refreshChapter_advent(chapter, difficulty, stage)
            return

        -- 깜짝 출현 챕터로 저장되어있지만 이벤트 비활성화 된 경우 챕터 1로 보냄
        else
            chapter = 1
            stage = 1
                
            self.m_currChapter = chapter
        end
    end

    -- 일반 챕터
    self:refreshChapter_common(chapter, difficulty, stage)
end

-------------------------------------
-- function refreshChapter_common
-- @breif 챕터 변경 - 깜짝 출현 챕터 전용
-- @sub refreshChapter
-------------------------------------
function UI_AdventureSceneNew:refreshChapter_common(chapter, difficulty, stage)
    local vars = self.vars

    do 
        -- 챕터 이름
        vars['titleLabel']:setString(Str('챕터.{1}', chapter) .. ' ' .. chapterName(chapter))
        vars['timeLabel']:setString('')
        vars['titleFrameSprite']:unscheduleUpdate()

        -- 타이틀 프레임
        local frame_size = vars['titleFrameSprite']:getContentSize()
        local height = 42
        vars['titleFrameSprite']:setContentSize(frame_size['width'], height)

        -- 이전, 다음 챕터 버튼
        vars['prevBtn']:setVisible(1 < chapter)
        vars['nextBtn']:setVisible(chapter < MAX_ADVENTURE_CHAPTER)

        -- 일반 챕터 리소스
        vars['stagePathSprite']:setVisible(true)
        vars['adventStagePathSprite']:setVisible(false)
        vars['achieveBtnMenu']:setVisible(true)

        local is_active_advent = g_hotTimeData:isActiveEvent('event_advent')
        vars['adventChapterBtn']:setVisible(is_active_advent)
        vars['adventBtnVisual']:setVisible(is_active_advent)
        vars['adventureBtn']:setVisible(false)

        -- 파티클 있다면 제거
        if (self.m_particle) then
            self.m_particle:removeFromParent()
            self.m_particle = nil
        end
    end

    -- 스테이지 버튼 생성
    self.m_lStageButton = {}
    for i=1, MAX_ADVENTURE_STAGE do
        local dock_node = vars[string.format('stageDock%.2d', i)]
        if dock_node then
            local stage_id = makeAdventureID(self.m_currDifficulty, chapter, i)
            local button = UI_AdventureStageButton(self, stage_id)
            dock_node:addChild(button.root)
            self.m_lStageButton[i] = button
        end
    end

    -- tutorial에서 접근하기 위해 사용
    vars['tutorialStageBtn'] = self.m_lStageButton[1].vars['stageBtn']
	vars['tutorialStageBtn2'] = self.m_lStageButton[2].vars['stageBtn']

    do -- 최초 보상 클리어 관련
        self.m_lFirstRewardButtons = {}

        -- 최초 클리어 보상 정보 갱신
        for i=1, MAX_ADVENTURE_STAGE do
            local stage_id = makeAdventureID(self.m_currDifficulty, chapter, i)
            self:refreshFirstReward(stage_id)
        end
    end

    do -- 진입 가능한 스테이지 저장
        local focus_stage = g_adventureData:getFocusStage(self.m_currDifficulty, chapter)
        self.m_openStage = focus_stage

        if stage and g_adventureData:isOpenStage(makeAdventureID(self.m_currDifficulty, chapter, stage)) then
            self:focusStageButton(stage, true, true)
        else
            self:focusStageButton(focus_stage, true, true)
            stage = focus_stage
        end
    end

    -- 챕터 도전과제
    self:refresh_MissionReward()
end

-------------------------------------
-- function refreshChapter_advent
-- @breif 챕터 변경 - 깜짝 출현 챕터 전용
-- @sub refreshChapter
-------------------------------------
function UI_AdventureSceneNew:refreshChapter_advent(chapter, difficulty, stage)
    local vars = self.vars

    do 
        -- 챕터 이름
        local title = g_eventAdventData:getAdventTitle()
        vars['titleLabel']:setString(title)
        
        -- 깜짝 출현 남은 시간
        vars['timeLabel']:setString('')
        local frame_guard = 1
        local function update(dt)
            frame_guard = frame_guard + dt
            if (frame_guard < 1) then
                return
            end
            frame_guard = frame_guard - 1

            local remain_time = g_hotTimeData:getEventRemainTime('event_advent')
            if remain_time > 0 then
                local time_str = datetime.makeTimeDesc(remain_time, true)
                vars['timeLabel']:setString(Str('{1} 남음', time_str))
            end
        end
        vars['titleFrameSprite']:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)

        -- 타이틀 프레임
        local frame_size = vars['titleFrameSprite']:getContentSize()
        local height = 84
        vars['titleFrameSprite']:setContentSize(frame_size['width'], height)

        -- 이전, 다음 챕터 버튼
        vars['prevBtn']:setVisible(false)
        vars['nextBtn']:setVisible(false)

        -- 깜짝 출현을 위한 세팅
        vars['stagePathSprite']:setVisible(false)
        vars['adventStagePathSprite']:setVisible(true)
        vars['achieveBtnMenu']:setVisible(false)

        vars['adventChapterBtn']:setVisible(false)
        vars['adventBtnVisual']:setVisible(false)
        vars['adventureBtn']:setVisible(true)

		-- 깜짝 출현 로비 팝업
		vars['popupInfoBtn']:setVisible(true)
		vars['popupInfoBtn']:registerScriptTapHandler(function() UI_EventAdvent.createAdventPopup() end)

        -- 눈 파티클 추가
        if (self.m_particle == nil) then
            local particle = cc.ParticleSystemQuad:create("res/ui/particle/dv_snow.plist")
	        particle:setAnchorPoint(CENTER_POINT)
	        particle:setDockPoint(CENTER_POINT)
	        self.root:addChild(particle)
            self.m_particle = particle
        end
    end
  
    -- 깜짝 출현 스테이지
    local advent_stage_count = g_eventAdventData:getAdventStageCount()

    -- 깜짝 출현 스테이지 버튼 및 드래곤 애니 생성
    self.m_lStageButton = {}
    self.m_adventDragonAniList = {}
    local advent_dock_node
    local stage_btn_gap = 200
    local l_advent_did_list = g_eventAdventData:getAdventDidList()
    for i, did in ipairs(l_advent_did_list) do
        advent_dock_node = vars[string.format('adventStageDock%.2d', i)]
        
        -- button
        local stage_id = makeAdventureID(difficulty, chapter, i)
        local button = UI_AdventureStageButton(self, stage_id)
        self.m_lStageButton[i] = button
        advent_dock_node:addChild(button.root)

        -- dragon
        local evolution = 3
        local animator = AnimatorHelper:makeDragonAnimator_usingDid(did, evolution)
        animator:setPositionY(32)
        animator:setScale(0.38)
        animator:setFlip(math_random(2) == 1)
        animator:setTimeScale(math_random(64,128)/100)
        self.m_adventDragonAniList[i] = animator
        advent_dock_node:addChild(animator.m_node)
    end
    
    -- stage 보정
    stage = stage and math_clamp(stage, 1, advent_stage_count) or 1

    -- 비공정 이동
    self:focusStageButton(stage, true, true)
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
    
    
    local max = MAX_ADVENTURE_STAGE * 3 -- 스테이지 1개당 별 3개
    for star=1, max do
        if chapter_achieve_info:isExist(star) then
            local button_ui = self:getAchieveRewardBtn(star)
            button_ui.root:setVisible(true)

            local state = chapter_achieve_info:getRewardBoxState(star)

            button_ui.vars['checkSprite']:setVisible(false)
            button_ui.vars['closeSprite']:setVisible(false)
            button_ui.vars['openSprite']:setVisible(false)
            button_ui.vars['receiveVisual']:setVisible(false)

            -- 별 갯수를 달성하지 못한 경우
            if (state == 'lock') then
                button_ui.vars['closeSprite']:setVisible(true)

            -- 별 갯수를 달성하였지만 보상을 받지 않은 경우
            elseif (state == 'open') then
                button_ui.vars['openSprite']:setVisible(true)
                button_ui.vars['receiveVisual']:setVisible(true)

            -- 보상까지 받은 경우
            elseif (state == 'received') then
                button_ui.vars['openSprite']:setVisible(true)
                button_ui.vars['checkSprite']:setVisible(true)
            end

        elseif self.m_lAchieveRewardButtons[star] then
            self.m_lAchieveRewardButtons[star].root:setVisible(false)
        end
    end
end

-------------------------------------
-- function getAchieveRewardBtn
-------------------------------------
function UI_AdventureSceneNew:getAchieveRewardBtn(star)
    if (not self.m_lAchieveRewardButtons[star]) then
        local ui = UI()
        ui:load('adventure_chapter_achieve_button.ui')
        ui.vars['starboxLabel']:setString(star)
        ui.vars['starBoxBtn']:registerScriptTapHandler(function() self:click_starBoxBtn(star) end)
        self.m_lAchieveRewardButtons[star] = ui

        ui.root:setDockPoint(cc.p(0, 0.5))
        ui.root:setAnchorPoint(cc.p(0.5, 0.5))
        self.vars['achieveBtnMenu']:addChild(ui.root)

        local width, height = self.vars['achieveBtnMenu']:getNormalSize()
        local max = MAX_ADVENTURE_STAGE * 3 -- 스테이지 1개당 별 3개
        local pos_x = (star / max) * width
        ui.root:setPositionX(pos_x)
    end


    local ui = self.m_lAchieveRewardButtons[star]
    return ui
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

        local msg = Str('{1}스테이지를 먼저 모험하세요.', self.m_openStage)
        msg = Str('이전 스테이지를 먼저 모험하세요.')
        UIManager:toastNotificationRed(msg)
    end
end

-------------------------------------
-- function click_devStageBtn
-- @brief 개발 스테이지 버튼
--        sgkim 2018.11.07 10vs10 PvP 테스트 버튼으로 사용 중
--        jhakim 2019.08.07 룬 수호자 던전 테스트 버튼
--        ochoi 2021.03.08 시련던전 테스트 버튼
-------------------------------------
function UI_AdventureSceneNew:click_devStageBtn()
    --self:openAdventureStageInfoPopup(DEV_STAGE_ID)
    --local scene = SceneGameEventArena(nil, ARENA_STAGE_ID, 'stage_colosseum', true)
    --scene:runScene()
    --UI_AdventureStageInfo(1119801)
    self:openAdventureStageInfoPopup(3011001)
end

-------------------------------------
-- function click_adventChapterBtn
-- @brief 모험 챕터 <--> 깜짝 출현 챕터 전환
-------------------------------------
function UI_AdventureSceneNew:click_adventChapterBtn(isToAdvent)
    local difficulty, chapter, stage = nil, nil, nil
    
    -- 깜짝 출현 챕터 현재 난이도의 1스테이지로 보냄
    if (isToAdvent) then
        difficulty = self.m_currDifficulty
        chapter = SPECIAL_CHAPTER.ADVENT
        stage = 1

        -- 되돌아올 stage id 저장
        self.m_rewindStageId = makeAdventureID(difficulty, self.m_currChapter, self.m_focusStageIdx)
        
    -- 모험 챕터 현재 난이도로 보냄
    else
        -- 스테이지 되감기
        if (self.m_rewindStageId) then
            difficulty, chapter, stage = parseAdventureID(self.m_rewindStageId)
        -- 없는 경우 1챕터 1스테이지
        else
            difficulty = self.m_currDifficulty
            chapter = 1
            stage = 1
        end
    end

    self.vars['popupInfoBtn']:setVisible(isToAdvent)
    self:refreshChapter(chapter, difficulty, stage)
    self.m_uicSortList:setSelectSortType(difficulty)
end

-------------------------------------
-- function clearStageButton
-------------------------------------
function UI_AdventureSceneNew:clearStageButton()
    local vars = self.vars
    local dock_node, advent_dock_node
    for i=1, MAX_ADVENTURE_STAGE do
        local dock_node = vars[string.format('stageDock%.2d', i)]
        if dock_node then
            dock_node:removeAllChildren()
        end
        local advent_dock_node = vars[string.format('adventStageDock%.2d', i)]
        if (advent_dock_node) then
            advent_dock_node:removeAllChildren()
        end
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

    self.m_focusStageIdx = idx

    local next_btn = self.m_lStageButton[idx]
    if next_btn then
        do -- 열림 여부 체크
            local _stage_id = makeAdventureID(self.m_currDifficulty, self.m_currChapter, idx)
            if g_adventureData:isOpenStage(_stage_id) then
                next_btn.vars['selectSprite']:setVisible(true)
            else
                next_btn.vars['selectSprite']:setVisible(false)
            end
        end

        next_btn.vars['arrowSprite']:setVisible(true)
        next_btn.vars['arrowSprite']:stopAllActions()
        next_btn.vars['arrowSprite']:setPosition(0, 0)
        local sequence = cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(0, 20)), cc.MoveTo:create(0.5, cc.p(0, -10)))
        next_btn.vars['arrowSprite']:runAction(cc.RepeatForever:create(sequence))

        -- 배의 위치를 조절
        local x, y = next_btn.root:getParent():getPosition()
        self:moveShipObject(x, y + 50, immediately, stage_id)
    end

    do -- 마지막에 진입한 스테이지 저장
        local stage_id = makeAdventureID(self.m_currDifficulty, self.m_currChapter, idx)
        g_stageData:setFocusStage(stage_id)
    end
end

-------------------------------------
-- function refreshHotTimeInfo
-- @breif 핫타임 정보 갱신
-------------------------------------
function UI_AdventureSceneNew:refreshHotTimeInfo()
    local vars = self.vars

    local l_active_hot = {}

    vars['hotTimeMarbleBtn']:setVisible(false)
    vars['hotTimeExpBtn']:setVisible(false)
    vars['hotTimeGoldBtn']:setVisible(false)
    vars['hotTimeStBtn']:setVisible(false)    


    -- 경험치 핫타임
    local active, value = g_hotTimeData:getActiveHotTimeInfo_exp()
    if active then
        table.insert(l_active_hot, 'hotTimeExpBtn')
        local str = string.format('+%d%%', value)
        vars['hotTimeExpLabel']:setString(str)
        vars['hotTimeExpBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('exp', vars['hotTimeExpBtn']) end)
    end

    -- 골드 핫타임
    local active, value = g_hotTimeData:getActiveHotTimeInfo_gold()
    if active then
        table.insert(l_active_hot, 'hotTimeGoldBtn')
        local str = string.format('+%d%%', value)
        vars['hotTimeGoldLabel']:setString(str)
        vars['hotTimeGoldBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('gold', vars['hotTimeGoldBtn']) end)
    end

    -- 스태미나 핫타임
    local active, value = g_hotTimeData:getActiveHotTimeInfo_stamina()
    if active then
        table.insert(l_active_hot, 'hotTimeStBtn')
        local str = string.format('-%d%%', value)
        vars['hotTimeStLabel']:setString(str)
        vars['hotTimeStBtn']:registerScriptTapHandler(function() g_hotTimeData:makeHotTimeToolTip('stamina', vars['hotTimeStBtn']) end)
    end

    -- 
    table.insert(l_active_hot, 'hotTimeMarbleBtn')
    vars['hotTimeMarbleBtn']:registerScriptTapHandler(function() 
        if (not self.m_tooltipUI) then
            self.m_tooltipUI = UI_TooltipTest()
            
            local local_pos = convertToAnoterParentSpace(vars['hotTimeMarbleBtn'], self.m_tooltipUI.root)
            local pos_x = local_pos['x']
            local pos_y = local_pos['y']
            self.m_tooltipUI.root:setPosition(pos_x, pos_y - 120)
        else
            self.m_tooltipUI:close()
            self.m_tooltipUI = nil
        end
     end)


    for i,v in ipairs(l_active_hot) do
        vars[v]:setVisible(true)
        local x = -108 + ((i-1) * 72)
        vars[v]:setPositionX(x)
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
    local difficulty, chapter, stage = parseAdventureID(stage_id)

    if self.m_lFirstRewardButtons[stage] then
        self.m_lFirstRewardButtons[stage].root:removeFromParent()
        self.m_lFirstRewardButtons[stage] = nil
    end

    -- 최초 클리어 보상 정보 얻어옴
    local first_reward_data = g_adventureFirstRewardData:getFirstRewardInfo(stage_id)

    -- 보상 정보가 없을 경우 return
    if (not first_reward_data) then
        return
    end

    local ui = UI_AdventureFirstRewardButton(stage_id)
    ui.root:setPosition(75, 15)
    
    self.m_lFirstRewardButtons[stage] = ui
    self.vars['stageDock0' .. stage]:addChild(ui.root)

    ui.vars['rewardBtn']:registerScriptTapHandler(function() self:click_firstRewardBtn(stage_id) end)
end

-------------------------------------
-- function click_firstRewardBtn
-- @brief
-------------------------------------
function UI_AdventureSceneNew:click_firstRewardBtn(stage_id)
    local function close_cb()
        self:refreshFirstReward(stage_id)
    end

    local ui = UI_AdventureFirstRewardPopup(stage_id)
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_chapterSelectBtn
-- @brief
-------------------------------------
function UI_AdventureSceneNew:click_chapterSelectBtn()
    function move_to_chapter(stage_id)
        if (not stage_id) then 
            return 
        end

        local difficulty, chapter, stage = parseAdventureID(stage_id)
        self:refreshChapter(chapter, difficulty, stage)
        self.m_uicSortList:setSelectSortType(difficulty)
    end

    UI_ChapterSelect(self.m_currDifficulty, move_to_chapter)
end

-------------------------------------------------------------------------------------------------------------------
-- 최초 클리어 보상 관련 end
-------------------------------------------------------------------------------------------------------------------