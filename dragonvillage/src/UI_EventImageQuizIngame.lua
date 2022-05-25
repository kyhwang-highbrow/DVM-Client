local PARENT = UI

-------------------------------------
-- class UI_EventImageQuizIngame
-- @brief 드래곤 이미지 퀴즈 이벤트
-------------------------------------
UI_EventImageQuizIngame = class(PARENT,{
        m_coroutineHelper = 'CoroutinHelepr',

        m_dragonAnimator = 'animator',
        m_currQuizIdx = 'number', -- 문제 1번부터 시작

        m_tDragonInfo = 'list',
        m_tDragonInfoCnt = 'number',
        m_problemList = 'list',
        
        -- 현재 정답 인덱스
        m_currentAnswer = 'number', 
        
        -- 난이도
        m_difficulty = 'number', 

        -- 점수
        m_score = 'number',
        

        m_dragonNodeOriginalPositionX = 'number',
        m_dragonNodeOriginalPositionY = 'number',

        m_blindTileTable = 'table',

        m_todayEndTime = 'timer',
        m_isTimeOut = 'boolean',
        m_isFinish = 'boolean',

        m_directingNode = 'cc.Node',
        m_preVFXType = 'string',

        m_tileIdx = 'number',
    })

-- LOCAL CONST
local TIME_LIMIT_SEC = 90
local P100 = TIME_LIMIT_SEC * 1000 / 100
local MAX_QUIZ = 45
local CHOICE_CNT = 3
local ANSWER_POINT = 100
local BTN_DELAY = 0.3
local L_DIFFICULTY = {
    0, 10, 20, 30, 40
}
local L_VFX_QUIZ = {
    { 'none' },
    { 'slide', },
    { 'scale', 'spotlight_scale' },
    { 'spotlight_scan' },
    { 'blind_tile'}
}

-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuizIngame:init()
    local vars = self:load('event_image_quiz_ingame.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_EventImageQuizIngame')

    self:sceneFadeInAction()

    -- 변수 초기화
    self.m_currQuizIdx = 0
    self.m_difficulty = 1
    self.m_score = 0

    self.m_tDragonInfo = TableDragon():filterTable('test', 2)
    self.m_tDragonInfoCnt = table.count(self.m_tDragonInfo)

    self.m_blindTileTable = {}

    self.m_directingNode = vars['directorNode']
    self.m_preVFXType = ''

    
    self.m_isTimeOut = false
    self.m_isFinish = false

    self:initUI()
    self:initButton()
    self:refresh()
    
    require('UI_EventImageQuizIngame_directing')
    self:initDirectingInfo()

    -- 시작 연출
    self:directing_startGame(function()
        -- 버튼 활성화
        self:setAllAnswerBtnEnable(true)
        
        -- 게임 타이머
        self.m_todayEndTime = ServerTime:getInstance():getCurrentTimestampMilliseconds() + TIME_LIMIT_SEC * 1000 

        self:nextQuiz()
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuizIngame:initUI()
    local vars = self.vars
    
    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        self.m_dragonAnimator:setTalkEnable(false)
        self.m_dragonAnimator:setChangeAniEnable(false)
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    self.m_dragonNodeOriginalPositionX = vars['dragonNode']:getPositionX()
    self.m_dragonNodeOriginalPositionY = vars['dragonNode']:getPositionY()

    -- 버튼 블럭
    for i = 1, 3 do
        vars['answerLabel' .. i]:setString('')
        vars['answerLabel' .. i]:setLocalZOrder(10)
        vars['answerBtn' .. i]:setEnabled(false)
        
        -- 버튼 리소스를 교체하기 때문에 버튼 하위에 있는 라벨은 zOrder를 올려두어야 한다.
        -- 내부적으로는 버튼의 버튼 리소소는 하위 자식이다.
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuizIngame:initButton()
    local vars = self.vars

    vars['answerBtn1']:registerScriptTapHandler(function() self:answerResult(1) end)
    vars['answerBtn2']:registerScriptTapHandler(function() self:answerResult(2) end)
    vars['answerBtn3']:registerScriptTapHandler(function() self:answerResult(3) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuizIngame:refresh()
    self:setScore()
    self:setDifficulty()
    self:setQuizProgress()
end

-------------------------------------
-- function update
-- @brief 남은 시간 표시
-------------------------------------
function UI_EventImageQuizIngame:update()
    if (self.m_isTimeOut) then
        return
    end

    local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
    local milliseconds = (self.m_todayEndTime - cur_time)

    -- 게임 진행 중 (게임 종료까지 남은 시간 표시)
    if (milliseconds > 0) then
        self.vars['timeLabel']:setString(datetime.makeTimeDesc_millsec(milliseconds, false))
        self.vars['timeGauge']:setPercentage(milliseconds / P100)

    -- 시간 초과
    elseif (milliseconds <= 0 and not self.m_isTimeOut) then
        self.m_isTimeOut = true
        self.vars['timeLabel']:setString('00:00:00')
        self.vars['timeGauge']:setPercentage(0)

        self:finishGame()
    end
end

-------------------------------------
-- function nextQuiz
-------------------------------------
function UI_EventImageQuizIngame:nextQuiz()
    local vars = self.vars
    self:resetGameSetting()
    self:refresh()

    -- 모든 퀴즈 클리어
    if (self.m_currQuizIdx >= MAX_QUIZ or self.m_isTimeOut) then
        self:finishGame()

    -- 다음 퀴즈
    else
        self:makeQuiz()
        self.m_currQuizIdx = self.m_currQuizIdx + 1
    end
end

-------------------------------------
-- function resetGameSetting
-- @brief 게임 세팅 초기화
-------------------------------------
function UI_EventImageQuizIngame:resetGameSetting()
    local vars = self.vars
    vars['dragonNode']:setPositionX(self.m_dragonNodeOriginalPositionX)
    vars['dragonNode']:setPositionY(self.m_dragonNodeOriginalPositionY)

    vars['answerBtn1']:stopAllActions()
    vars['answerBtn2']:stopAllActions()
    vars['answerBtn3']:stopAllActions()

    vars['answerBtn1']:setVisible(true)
    vars['answerBtn2']:setVisible(true)
    vars['answerBtn3']:setVisible(true)
end

-------------------------------------
-- function makeQuiz
-- @brief 퀴즈를 만든다!
-------------------------------------
function UI_EventImageQuizIngame:makeQuiz()
    local l_did = self:getCombination(self.m_tDragonInfoCnt, CHOICE_CNT)
    self.m_currentAnswer = math_random(CHOICE_CNT)

    local t_dragon = self.m_tDragonInfo[l_did[self.m_currentAnswer]]

    self:setDragon(t_dragon)
    self:setAnswerBtns(l_did)

    -- 난도 영역
    local l_vfx = L_VFX_QUIZ[self.m_difficulty]
    local vfx = table.getRandom(l_vfx)
    
    self:cleanImageQuizEffect(self.m_preVFXType, vfx)
    
    self.m_preVFXType = vfx
    
    if (vfx == 'spotlight_scale') then
        self:spotlightScaleUp()
    elseif (vfx == 'spotlight_scan') then
        self:spotlightScan()

    elseif (vfx == 'blind_tile') then
        self:blindTile()
    elseif (vfx == 'slide') then
        self:dragonSlide()
    elseif (vfx == 'scale') then
        self:dragonScaleUp()
    end
end

-------------------------------------
-- function getCombination
-- @param dragon_cnt : Number
-- @param choice_cnt : Number
-------------------------------------
function UI_EventImageQuizIngame:getCombination(dragon_cnt, choice_cnt)
    local l_rand = {}
    
    local idx = 0
    while idx < choice_cnt do
        local rand_num = math_random(1, dragon_cnt)
        if (not isContainValue(rand_num, l_rand)) then
            table.insert(l_rand, rand_num)
            idx = idx + 1
        end
    end
    
    local l_did = {}
    idx = 1
    for k,v in pairs(self.m_tDragonInfo) do
        if (isContainValue(idx, l_rand)) then
            table.insert(l_did, v['did'])
        end
        idx = idx + 1
    end

    return l_did
end

-------------------------------------
-- function setDragon
-------------------------------------
function UI_EventImageQuizIngame:setDragon(t_dragon)
    local evolution = math_random(3)
    local flv = 0
    local current_problem_number = self.m_currQuizIdx
    local did = t_dragon['did']

    self.m_dragonAnimator:setDragonAnimator(did, evolution, flv)
end

-------------------------------------
-- function setAnswerBtns
-- @param 답안 선택지 생성
-------------------------------------
function UI_EventImageQuizIngame:setAnswerBtns(l_idx)
    local vars = self.vars
    
    -- 버튼 블럭
    self:setAllAnswerBtnEnable(false)

    for i = 1, CHOICE_CNT do
        local t_dragon = self.m_tDragonInfo[l_idx[i]]
        vars['answerLabel' .. i]:setString(TableDragon:getDragonNameWithAttr(t_dragon['did']))
        local attr = t_dragon['attr']
        
        -- 캐릭터 속성에 따라 버튼 리소스를 교체한다.
        local normal_sprite
        local selected_sprite
        if (attr == 'earth') then
            normal_sprite = 'res/ui/buttons/image_quiz_btn_earth_0101.png'
            selected_sprite = 'res/ui/buttons/image_quiz_btn_earth_0102.png'
        elseif (attr == 'water') then
            normal_sprite = 'res/ui/buttons/image_quiz_btn_water_0101.png'
            selected_sprite = 'res/ui/buttons/image_quiz_btn_water_0102.png'
        elseif (attr == 'fire') then
            normal_sprite = 'res/ui/buttons/image_quiz_btn_fire_0101.png'
            selected_sprite = 'res/ui/buttons/image_quiz_btn_fire_0102.png'
        elseif (attr == 'light') then
            normal_sprite = 'res/ui/buttons/image_quiz_btn_light_0101.png'
            selected_sprite = 'res/ui/buttons/image_quiz_btn_light_0102.png'
        elseif (attr == 'dark') then
            normal_sprite = 'res/ui/buttons/image_quiz_btn_dark_0101.png'
            selected_sprite = 'res/ui/buttons/image_quiz_btn_dark_0102.png'
        end
        vars['answerBtn' .. i]:setNormalImage(cc.Sprite:create(normal_sprite))
        vars['answerBtn' .. i]:setSelectedImage(cc.Sprite:create(selected_sprite))
    end

    local btn_enable_action = cc.Sequence:create(cc.DelayTime:create(BTN_DELAY), cc.CallFunc:create(function() self:setAllAnswerBtnEnable(true) end))
    self.root:runAction(btn_enable_action)
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventImageQuizIngame:click_closeBtn()
    if (IS_TEST_MODE()) then
        self:close()
    else
        UIManager:toastNotificationGreen(Str('지금은 사용 할 수 없습니다.'))
    end
end

-------------------------------------
-- function answerResult
-- @brief 정답 확인
-- @return 없음. 함수 내에서 처리하는게 더 깔끔함.
-------------------------------------
function UI_EventImageQuizIngame:answerResult(answer)
    if (self.m_isFinish) then
        return
    end

    local vars = self.vars

    if (self.m_currentAnswer == answer) then
        self.m_score = self.m_score + 1
        self:nextQuiz()
        self:directing_goodAnswer()

        -- 시간 출력
        if (IS_TEST_MODE()) then
            local cur_time = ServerTime:getInstance():getCurrentTimestampMilliseconds()
            local milliseconds = (self.m_todayEndTime - cur_time)
            cclog('Answer : ' .. TIME_LIMIT_SEC - milliseconds/1000)
        end
    else
        vars['answerBtn' .. answer]:setVisible(false)
        self:directing_badAnswer()
    end
end

-------------------------------------
-- function setScore
-- @brief 점수 표시
-------------------------------------
function UI_EventImageQuizIngame:setScore()
    self.vars['scoreLabel']:setString(self.m_score * ANSWER_POINT)
end

-------------------------------------
-- function setDifficulty
-- @brief 난이도 설정
-------------------------------------
function UI_EventImageQuizIngame:setDifficulty()
    local score = self.m_score

    local pre_difficulty = self.m_difficulty

    if (score < L_DIFFICULTY[2]) then
        self.m_difficulty = 1
    elseif (score < L_DIFFICULTY[3]) then
        self.m_difficulty = 2
    elseif (score < L_DIFFICULTY[4]) then
        self.m_difficulty = 3
    elseif (score < L_DIFFICULTY[5]) then
        self.m_difficulty = 4
    else
        self.m_difficulty = 5
    end

    self.vars['levelLabel']:setString('LEVEL ' .. self.m_difficulty)

    -- 난이도 증가 시 연출
    if (self.m_difficulty > pre_difficulty) then
        self:directing_levelUp()
    end
end

-------------------------------------
-- function setQuizProgress
-- @brief 진행 상황 표시
-------------------------------------
function UI_EventImageQuizIngame:setQuizProgress()
    local display_idx = self.m_currQuizIdx
    if (display_idx > MAX_QUIZ) then
        display_idx = MAX_QUIZ
    end

    self.vars['numberLabel']:setString(display_idx .. '/' .. MAX_QUIZ)
end

-------------------------------------
-- function setAllAnswerBtnEnable
-- @brief 버튼 일괄 변경
-------------------------------------
function UI_EventImageQuizIngame:setAllAnswerBtnEnable(b)
    local enable = b
    -- finish 호출된 이후에는 무조건 비활성화 처리 한다.
    if (self.m_isFinish) then
        enable = false
    else
        enable = b
    end

    -- 버튼 블럭
    for i = 1, CHOICE_CNT do
        self.vars['answerBtn' .. i]:setEnabled(enable)
    end
end

-------------------------------------
-- function finishGame
-- @brief 게임 종료 처리
-------------------------------------
function UI_EventImageQuizIngame:finishGame()
    if (self.m_isFinish) then
        return
    end

    self.m_isFinish = true

    -- update 종료
    self.root:unscheduleUpdate()

    -- 버튼 블럭
    self:setAllAnswerBtnEnable(false)

    -- 종료 연출
    local function directing_finish()
        self:directing_finishGame(self.m_isTimeOut, function()
            -- 결과 화면
            require('UI_EventImageQuizResult')
            UI_EventImageQuizResult(
                self.vars['scoreLabel']:getString(),
                self.vars['timeLabel']:getString()
            ):setCloseCB(function() self:close() end)
        end)
    end   
    
    -- 종료 통신
    g_eventImageQuizData:request_eventImageQuizFinish(self.m_score, directing_finish)
end