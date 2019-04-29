local PARENT = UI_AdventureSceneNew

-------------------------------------
-- class UI_AdventureScene_Illusion
-------------------------------------
UI_AdventureScene_Illusion = class(PARENT, {
       
     })

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_AdventureScene_Illusion:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_AdventureScene_Illusion'
    self.m_bUseExitBtn = true
    self.m_uiBgm = 'bgm_dungeon_ready'
end

-------------------------------------
-- function init
-------------------------------------
function UI_AdventureScene_Illusion:init(stage_id)
    
end


-------------------------------------
-- function focusByStageID
-- @brief
-------------------------------------
function UI_AdventureScene_Illusion:focusByStageID(stage_id)
    local difficulty, chapter, stage = parseAdventureID(stage_id)
    self:refreshChapter(chapter, difficulty, stage)
end

-------------------------------------
-- function initButton
-- @brief
-------------------------------------
function UI_AdventureScene_Illusion:makeUICSortList()
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
-- function moveShipObject
-- @brief 비공정 오브젝트 이동
-------------------------------------
function UI_AdventureScene_Illusion:moveShipObject(x, y, immediately, stage_id)
    self.m_adventureShip:stopAllActions()

    local front_ani_name, back_ani_name, func_arrival
    front_ani_name = 'advent_front'
    back_ani_name = 'advent_back'
    func_arrival = function()
        for i, animator in ipairs(self.m_adventDragonAniList) do
            animator:setVisible(i ~= self.m_focusStageIdx)
        end
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
-- function click_selectDifficultyBtn
-- @brief 난이도 변경 버튼
-------------------------------------
function UI_AdventureScene_Illusion:click_selectDifficultyBtn(difficulty)
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
-- function refreshChapter
-- @breif 챕터 변경
-------------------------------------
function UI_AdventureScene_Illusion:refreshChapter(chapter, difficulty, stage, force)
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

    do -- 챕터 전환 연출
        vars['splashLayer']:setLocalZOrder(1)
        vars['splashLayer']:setVisible(true)
        vars['splashLayer']:stopAllActions()
        vars['splashLayer']:setOpacity(255)
        vars['splashLayer']:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.Hide:create()))
    end
    
    
    do -- 챕터 배경
        vars['chapterNode']:removeAllChildren()
        local res = 'res/bg/map_forest/map_forest.vrp'

        local animator = MakeAnimator(res)
        animator:setDefaultAniName('easy')
        animator:changeAni('easy', true)
        animator:setDockPoint(cc.p(0.5, 0.5))
        animator:setAnchorPoint(cc.p(0.5, 0.5))
        vars['chapterNode']:addChild(animator.m_node)
    end

    -- 핫타임 정보 갱신
    self:refreshHotTimeInfo()

    -- 이전 스테이지 버튼 제거
    self:clearStageButton()

    self:refreshChapter_Illusion(chapter, difficulty, stage)
    
end


-------------------------------------
-- function refreshChapter_advent
-- @breif 챕터 변경 - 깜짝 출현 챕터 전용
-- @sub refreshChapter
-------------------------------------
function UI_AdventureScene_Illusion:refreshChapter_Illusion(chapter, difficulty, stage)
    local vars = self.vars

    do 
        -- 챕터 이름
        local title = Str('환상 던전 이벤트')
        vars['titleLabel']:setString(title)
        
        --[[
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
        --]]
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

    end

    -- 깜짝 출현 스테이지
    local advent_stage_count = 3

    -- 깜짝 출현 스테이지 버튼 및 드래곤 애니 생성
    self.m_lStageButton = {}
    self.m_adventDragonAniList = {}
    local advent_dock_node
    local stage_btn_gap = 200
    for i = 1, 3  do
        advent_dock_node = vars[string.format('adventStageDock%.2d', i)]      
        -- button
        --local stage_id = makeAdventureID(1, 1, i)
        local button = UI_AdventureStageButton(self, SPECIAL_CHAPTER.GAME_MODE_EVENT_ILLUSION_DUNSEON)
        self.m_lStageButton[i] = button
        advent_dock_node:addChild(button.root)
    end
    
    -- stage 보정
    stage = stage and math_clamp(stage, 1, advent_stage_count) or 1
    
    -- 비공정 이동
    self:focusStageButton(stage, true, true)
    --]]
end
