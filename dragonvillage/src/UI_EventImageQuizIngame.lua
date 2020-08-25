local PARENT = UI

-------------------------------------
-- class UI_Forest
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

        m_directingNode = 'cc.Node',
    })

-- LOCAL CONST
local TIME_LIMIT_SEC = 90
local P100 = TIME_LIMIT_SEC * 1000 / 100

local MAX_QUIZ = 45
local CHOICE_CNT = 3
local ANSWER_POINT = 100
local L_DIFFICULTY = {
    0, 10, 20, 30, 40
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
    self.m_currQuizIdx= 1
    self.m_difficulty= 1
    self.m_score = 0

    self.m_tDragonInfo = TableDragon():filterTable('test', 2)
    self.m_tDragonInfoCnt = table.count(self.m_tDragonInfo)

    self.m_blindTileTable = {}

    self.m_directingNode = vars['directorNode']

    -- 게임 타이머
    self.m_todayEndTime = Timer:getServerTime_Milliseconds() + TIME_LIMIT_SEC * 1000 
    self.m_isTimeOut = false

    self:initUI()
    self:initButton()
    self:refresh()
    
    require('UI_EventImageQuizIngame_directing')

    -- 시작 연출
    self:directing_startGame(function()
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
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    self.m_dragonNodeOriginalPositionX = vars['dragonNode']:getPositionX()
    self.m_dragonNodeOriginalPositionY = vars['dragonNode']:getPositionY()    
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

    local cur_time = Timer:getServerTime_Milliseconds()
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
        
        -- 주석 해제시 게임 모드 실행됨
        --self:blindImage()
        --self:blindTile()
        --self:spotlightScaleUp()
        --self:spotlightScan()
        --self:dragonSlide()
        --self:dragonScaleUp()

        self.m_currQuizIdx = self.m_currQuizIdx + 1
    end
end

-------------------------------------
-- function resetGameSetting
-- @brief 게임 세팅 초기화
-------------------------------------
function UI_EventImageQuizIngame:resetGameSetting()
    local vars = self.vars
    vars['dragonNode']:setScale(1)
    vars['dragonNode']:setPositionX(self.m_dragonNodeOriginalPositionX)
    vars['dragonNode']:setPositionY(self.m_dragonNodeOriginalPositionY)
    -- vars['curtain']:setPositionX(0)
    -- vars['curtain']:setPositionY(0)
    -- vars['curtain']:setVisible(false)
    -- vars['spotlight']:setVisible(false)
    -- vars['blockLayer1']:setVisible(false)
    -- vars['blockLayer2']:setVisible(false)
    -- vars['blockLayer3']:setVisible(false)
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
    
    for i = 1, CHOICE_CNT do
        local t_dragon = self.m_tDragonInfo[l_idx[i]]
        local dragon_name = t_dragon['c_name']
        local dragon_id = t_dragon['did']

        vars['answerLabel' .. i]:setString(Str(dragon_name))
        vars['answerLayer' .. i]:setColor(COLOR[t_dragon['attr']])
    end
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventImageQuizIngame:click_closeBtn()
    self:close()
end

-------------------------------------
-- function answerResult
-- @brief 정답 확인
-- @return 없음. 함수 내에서 처리하는게 더 깔끔함.
-------------------------------------
function UI_EventImageQuizIngame:answerResult(answer)
    local vars = self.vars

    if (self.m_currentAnswer == answer) then
        UIManager:toastNotificationGreen('정답 연출')
        self.m_score = self.m_score + 1
        self:nextQuiz()
    else
        UIManager:toastNotificationRed('오답 연출!')
        vars['answerBtn' .. answer]:setVisible(false)
        self:directing_wrongAnswer()
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
end

-------------------------------------
-- function setQuizProgress
-- @brief 진행 상황 표시
-------------------------------------
function UI_EventImageQuizIngame:setQuizProgress()
    self.vars['numberLabel']:setString(self.m_currQuizIdx .. '/' .. MAX_QUIZ)
end

-------------------------------------
-- function finishGame
-- @brief 게임 종료 처리
-------------------------------------
function UI_EventImageQuizIngame:finishGame()
    -- update 종료
    self.root:unscheduleUpdate()

    -- 종료 연출

    -- 종료 통신
    g_eventImageQuizData:request_eventImageQuizFinish(
        self.m_score, 
        function()
            -- 결과 화면
            require('UI_EventImageQuizResult')
            UI_EventImageQuizResult(
                self.vars['scoreLabel']:getString(),
                self.vars['timeLabel']:getString()
            ):setCloseCB(function() self:close() end)
        end
    )
end