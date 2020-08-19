local PARENT = UI

-------------------------------------
-- class UI_Forest
-------------------------------------
UI_EventImageQuizIngame = class(PARENT,{
        m_dragonAnimator = 'animator',
        m_currQuizIdx = 'number', -- 문제 1번부터 시작

        m_dragonInfoList = 'list',
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
    })

-- LOCAL CONST
local TIME_LIMIT_SEC = 90
local MAX_QUIZ = 45
local CHOICE_CNT = 3
local ANSWER_POINT = 100
local L_DIFFICULTY = {
    0, 1000, 2000, 3000, 4000
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

    self.m_dragonInfoList = TableDragon().m_orgTable

    self.m_blindTileTable = {}

    -- 게임 타이머
    self.m_todayEndTime = Timer:getServerTime_Milliseconds() + TIME_LIMIT_SEC * 1000 
    self.m_isTimeOut = false

    self:initUI()
    self:initButton()
    self:refresh()
    
    self:setGame()
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
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

    vars['answerBtn1']:registerScriptTapHandler(function() self:AnswerResult(1) end)
    vars['answerBtn2']:registerScriptTapHandler(function() self:AnswerResult(2) end)
    vars['answerBtn3']:registerScriptTapHandler(function() self:AnswerResult(3) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuizIngame:refresh()
    self:setScore()
    self:setDifficulty()
    self:setQuizProgress()
end

local bunmo = TIME_LIMIT_SEC * 1000 / 100
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
        cclog(milliseconds / bunmo)
        self.vars['timeGauge']:setPercentage(milliseconds / bunmo)

    -- 시간 초과
    elseif (milliseconds <= 0 and not self.m_isTimeOut) then
        self.m_isTimeOut = true
        local msg = Str('게임 끝')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        self.vars['timeLabel']:setString('')
    end
end

-------------------------------------
-- function setGame
-- @brief 사실상 main 함수
-------------------------------------
function UI_EventImageQuizIngame:setGame()
    local vars = self.vars
    self:resetGameSetting()
    self:refresh()

    -- 모든 퀴즈 클리어
    if (self.m_currQuizIdx - 1 >= MAX_QUIZ or self.m_isTimeOut) then
        local msg = Str('게임 끝')
        MakeSimplePopup(POPUP_TYPE.OK, msg)

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
    local dragon_cnt = table.count(self.m_dragonInfoList)

    local l_idx = self:getCombination(dragon_cnt, CHOICE_CNT)
    self.m_currentAnswer = math_random(CHOICE_CNT)

    cclog(dragon_cnt)
    cclog(l_idx[self.m_currentAnswer])
    local t_dragon = self.m_dragonInfoList[l_idx[self.m_currentAnswer]]
    self:setDragon(t_dragon)
    self:setAnswerBtns(l_idx)
end

-------------------------------------
-- function getCombination
-- @param dragon_cnt : Number
-- @param choice_cnt : Number
-------------------------------------
function UI_EventImageQuizIngame:getCombination(dragon_cnt, choice_cnt)
    return { 120011, 120405, 120612 }
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
        local t_dragon = self.m_dragonInfoList[l_idx[i]]
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
-- function AnswerResult
-- @brief 정답 확인
-- @return 없음. 함수 내에서 처리하는게 더 깔끔함.
-------------------------------------
function UI_EventImageQuizIngame:AnswerResult(answer)
    local vars = self.vars

    if (self.m_currentAnswer == answer) then
        UIManager:toastNotificationGreen('정답 연출')
        self.m_score = self.m_score + ANSWER_POINT
        self:setGame()
    else
        UIManager:toastNotificationRed('오답 연출!')
        vars['answerBtn' .. answer]:setVisible(false)
    end
end

-------------------------------------
-- function setScore
-- @brief 점수 표시
-------------------------------------
function UI_EventImageQuizIngame:setScore()
    self.vars['scoreLabel']:setString(m_score)
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







--------------------------------------------------------------------------
-- Directing
--------------------------------------------------------------------------

-------------------------------------
-- function spotlightScan
-- @brief 스포트라이트 움직이다 커지는 효과
-------------------------------------
function UI_EventImageQuizIngame:spotlightScan()
    local vars = self.vars
    local duration = 0.5
    local scale = 5
    
    vars['spotlight']:stopAllActions()
    vars['spotlight']:setScale(1)
    vars['spotlight']:setVisible(true)
    local l_location = {}
    for i = 1, 6 do
        table.insert(l_location, math_random(-150, 150))
    end
    local l_action = {}
    for i = 1, 3 do
        table.insert(l_action, cc.Sequence:create(cc.MoveTo:create(duration, cc.p(l_location[i * 2 - 1], l_location[i * 2]))))
    end
    local action_scale = cc.ScaleTo:create(duration, scale)
    local sequence = cc.Sequence:create(l_action[1], l_action[2], l_action[3], action_scale)
    vars['spotlight']:runAction(sequence)
end

-------------------------------------
-- function spotlightScaleUp
-- @brief 스포트라이트 scale up 효과. 중앙에서 커지기만함
-------------------------------------
function UI_EventImageQuizIngame:spotlightScaleUp()
    local vars = self.vars
    local duration = 2
    
    vars['spotlight']:stopAllActions()
    vars['spotlight']:setScale(1)
    vars['spotlight']:setVisible(true)
    vars['spotlight']:setPosition(0, 0)
    local action_scale = cc.ScaleTo:create(duration, 5)

    vars['spotlight']:runAction(action_scale)
end

-------------------------------------
-- function blindTile
-- @brief 타일 블라인드 효과
-------------------------------------
function UI_EventImageQuizIngame:blindTile()
    local vars = self.vars
    local x_interval = 90
    local y_interval = 50
    vars['tempNodeForBlindTile']:stopAllActions()
    vars['blindTileNode']:removeAllChildren()
    self.m_blindTileTable = {}

    for i = 1, 10 do
        for j = 1, 10 do
            local layer = cc.LayerColor:create()
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setDockPoint(cc.p(0, 0))
            layer:setColor(cc.c3b(255,0,0))
            layer:setContentSize(90, 50)
            layer:setPosition(x_interval * (i-1), y_interval * (j-1))
            layer:setOpacity(254)
            table.insert(self.m_blindTileTable, layer)
            vars['blindTileNode']:addChild(layer, 99999)
        end
    end
    self:removeBlindTileUnit()
end
-------------------------------------
-- function removeBlindTileUnit
-- @brief 타일 하나씩 지우기
-------------------------------------
function UI_EventImageQuizIngame:removeBlindTileUnit()
    local vars = self.vars
    local remained_tile_number = table.count(self.m_blindTileTable)
    local target_tile_number = math_random(remained_tile_number)
    local target_tile = self.m_blindTileTable[target_tile_number]
    if target_tile then
        target_tile:removeFromParent(true)
    end
    table.remove(self.m_blindTileTable, target_tile_number)

    if (table.count(self.m_blindTileTable) > 0) then
        local node = vars['tempNodeForBlindTile']
        local function removeBlindTileUnit()
            self:removeBlindTileUnit()
        end
        local blind_tile_action = cc.Sequence:create(cc.DelayTime:create(0.015), cc.CallFunc:create(removeBlindTileUnit))
        node:runAction(blind_tile_action)
    end
end

-------------------------------------
-- function dragonScaleUp
-- @brief 드래곤 확대
-------------------------------------
function UI_EventImageQuizIngame:dragonScaleUp(from)
    local vars = self.vars
    local from = from or 0.1
    vars['dragonNode']:setScale(from)

    local scale = 1
    local duration = 2
    local zoom_action = cc.ScaleTo:create(duration, scale)
    local ease_action = cc.EaseIn:create(zoom_action, 2)

    vars['dragonNode']:stopAllActions()
    vars['dragonNode']:runAction(ease_action)
end

-------------------------------------
-- function dragonSlide
-- @brief 화면의 상/하/좌/우에서 랜덤하게 나타남
-------------------------------------
function UI_EventImageQuizIngame:dragonSlide()
    local vars = self.vars
    local from = math_random(4)
    local dragon_node = vars['dragonNode']
    local interval = 500
    
    local dragon_node_x = dragon_node:getPositionX()
    local dragon_node_y = dragon_node:getPositionY()
    local duration = 2

    local pos_x = 0
    local pos_y = 0
    if (from == 1) then
        pos_x = dragon_node_x
        pos_y = dragon_node_y + interval
    elseif (from == 2) then
        pos_x = dragon_node_x
        pos_y = dragon_node_y - interval
    elseif (from == 3) then
        pos_x = dragon_node_x - interval
        pos_y = dragon_node_y
    else
        pos_x = dragon_node_x + interval
        pos_y = dragon_node_y
    end
    
    dragon_node:setPositionX(pos_x)
    dragon_node:setPositionY(pos_y)
    local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(dragon_node_x, dragon_node_y)))

    vars['dragonNode']:stopAllActions()
    vars['dragonNode']:runAction(action)
end

-------------------------------------
-- function blindImage
-- @brief 커튼 이미지에 가려 있다가 커튼이 좌/우로 랜덤하게 이동하며 등장
-------------------------------------
function UI_EventImageQuizIngame:blindImage()
    local vars = self.vars
    local to = math_random(2)
    local curtain = vars['curtain']
    curtain:setVisible(true)
    local duration = 2

    local pos_x = 0
    local pos_y = curtain:getPositionY()
    if (to == 1) then
        pos_x = -1000
    else
        pos_x = 1000
    end
    local action = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(pos_x, pos_y)))

    curtain:stopAllActions()
    curtain:runAction(action)
end