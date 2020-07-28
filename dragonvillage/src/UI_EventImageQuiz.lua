local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

-------------------------------------
-- class UI_Forest
-------------------------------------
UI_EventImageQuiz = class(PARENT,{
        m_dragonAnimator = 'animator',
        m_currentProblemNumber = 'number', -- 문제 1번부터 시작
        m_dragonInfoList = 'list',
        m_problemList = 'list',
        m_currentAnswer = 'number', -- 정담
        m_difficulty = 'number', -- 난이도
        m_answerCount = 'number',
        m_wrongAnswerCount = 'number',
        m_answerBtnLayer1 = 'layerColor',
        m_answerBtnLayer2 = 'layerColor',
        m_answerBtnLayer3 = 'layerColor',
        m_dragonNodeOriginalPositionX = 'number',
        m_dragonNodeOriginalPositionY = 'number',
        m_spotlightAction = 'action',
        m_blindButtonAction = 'action',
        m_blindTileAction = 'action',
        m_blindTileTable = '',
        m_button1PositionX = 'number',
        m_button2PositionX = 'number',
        m_button3PositionX = 'number',
        m_buttonPositionY = 'number', -- Y좌표는 모두 같음
        devBtn1 = 'boolean', -- 개발용 버튼
        devBtn2 = 'boolean',
        devBtn3 = 'boolean',
        devBtn4 = 'boolean',
        devBtn5 = 'boolean',
        devBtn6 = 'boolean',
        devBtn7 = 'boolean',
        devBtn8 = 'boolean',
        devBtn9 = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuiz:init()
    local vars = self:load('event_image_quiz.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_EventImageQuiz')

    self:sceneFadeInAction()

    self:initUI()
    self:initButton()
    self:refresh()
    
    -- 변수 초기화
    self.m_currentProblemNumber= 1
    self.m_difficulty= 1
    self.m_wrongAnswerCount = 0
    self.m_answerCount = 0
    self.m_dragonInfoList = self:getAllDragonInfo()
    self.m_problemList = self:makeProblem()
    self.m_blindTileTable = {}
    self.m_button1PositionX = vars['answerBtn1']:getPositionX()
    self.m_button2PositionX = vars['answerBtn2']:getPositionX()
    self.m_button3PositionX = vars['answerBtn3']:getPositionX()
    self.m_buttonPositionY = vars['answerBtn1']:getPositionY()

    -- 드래곤 실리소스
    if vars['dragonNode'] then
        self.m_dragonAnimator = UIC_DragonAnimator()
        vars['dragonNode']:addChild(self.m_dragonAnimator.m_node)
    end

    self:startGame()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuiz:initUI()
    local vars = self.vars
    
    local dragon_node = vars['dragonNode']    
    self.m_dragonNodeOriginalPositionX = dragon_node:getPositionX()
    self.m_dragonNodeOriginalPositionY = dragon_node:getPositionY()
    
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuiz:initButton()
    local vars = self.vars

    vars['answerBtn1']:registerScriptTapHandler(function() self:click_answerBtn1() end)
    vars['answerBtn2']:registerScriptTapHandler(function() self:click_answerBtn2() end)
    vars['answerBtn3']:registerScriptTapHandler(function() self:click_answerBtn3() end)
    self:devSetButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuiz:refresh()
end

-------------------------------------
-- function getAllDragonInfo
-- 현존하는 모든 드래곤을 가져온다.
-- @param attr_type string 드래곤 속성(earth, water, fire, light, dark)
-- @return did_name_list 순차 리스트를 리턴한다.
-------------------------------------
function UI_EventImageQuiz:getAllDragonInfo(attr_type)
    local did_name_list = {}
    local role_type = 'all'
    local l_item_list = g_bookData:getBookList(role_type, attr_type, true)

    for k, v in pairs(l_item_list) do
        if (v['bookType'] == 'dragon') then
            -- c_name이 nil이면 슬라임이다.
            local content_table = {}
            content_table['c_name'] = v['c_name']
            content_table['did'] = v['did']
            table.insert(did_name_list, content_table)
        end
    end

    return did_name_list
end

-------------------------------------
-- function makeProblem
-- @brief 90개의 문제를 만든다.
-- @return problem_number_list 문제 목록 리스트
-------------------------------------
function UI_EventImageQuiz:makeProblem()
    local problem_limit = 50
    local problem_number_list = {}
    
    local max_problem_number = table.count(self.m_dragonInfoList)
    while table.count(problem_number_list) < problem_limit do
        local rand = math_random(max_problem_number)

        -- problem_number_list에 이미 rand가 추가되었는지 확인
        local has_rand = false
        for _, v in ipairs(problem_number_list) do
            if (v == rand) then
                has_rand = true
            end
        end

        -- rand가 추가 안 되었다면 problem_number_list에 추가
        if (not has_rand) then
            table.insert(problem_number_list, rand)
        end
    end

    return problem_number_list
end

-------------------------------------
-- function startGame
-- @param 퀴즈 게임 시작
-------------------------------------
function UI_EventImageQuiz:startGame()
    local dragon_info_list = self.m_dragonInfoList
    local problem_list = self.m_problemList

    self:setGame(self.m_difficulty)
end

-------------------------------------
-- function setGame
-- @param 퀴즈 게임 한 단계
-------------------------------------
function UI_EventImageQuiz:setGame()
    local vars = self.vars
    local max_problem_number = table.count(self.m_problemList)
    self:resetGameSetting()
    self:setAnswerCountLabel()
    self:setDifficulty()

    if (self.m_currentProblemNumber - 1 == max_problem_number) then
        UIManager:toastNotificationGreen('게임 끝.')
    else
        vars['answerBtn1']:setVisible(true)
        vars['answerBtn2']:setVisible(true)
        vars['answerBtn3']:setVisible(true)

        wrong_answer_list = self:getAllRandomWrongAnswer()
        self:setAnswerButton(wrong_answer_list)

        self:setDragon()
        self.m_dragonAnimator:setTalkEnable(false)
        
        self:devStartGame()
        --self:blindImage()
        --self:blindTile()
        --self:spotlightScaleUp()
        --self:spotlightScan()
        --self:dragonSlide()
        --self:dragonIcon() -- 사용하지 않음
        --self:DragonScaleUp()
        --self:setButtonColor(false) -- fake_color
        --self:setButtonColor(true) -- true_color
        --self:setAnswerButtonBlind()
        --self:moveButtons()

        self.m_currentProblemNumber = self.m_currentProblemNumber + 1
    end
end

-------------------------------------
-- function resetGameSetting
-- @brief 게임 세팅 초기화
-------------------------------------
function UI_EventImageQuiz:resetGameSetting()
    local vars = self.vars
    vars['dragonNode']:setScale(1)
    vars['dragonNode']:setPositionX(self.m_dragonNodeOriginalPositionX)
    vars['dragonNode']:setPositionY(self.m_dragonNodeOriginalPositionY)
    vars['curtain']:setPositionX(0)
    vars['curtain']:setPositionY(0)
    vars['curtain']:setVisible(false)
    vars['spotlight']:setVisible(false)
    vars['blockLayer1']:setVisible(false)
    vars['blockLayer2']:setVisible(false)
    vars['blockLayer3']:setVisible(false)
    vars['answerBtn1']:stopAllActions()
    vars['answerBtn2']:stopAllActions()
    vars['answerBtn3']:stopAllActions()
end

-------------------------------------
-- function getAllRandomWrongAnswer
-- @param 속성, 이름 관계없이 랜덤으로 오답 2개 선택
-- @return 랜덤인 이름 두개 list
-------------------------------------
function UI_EventImageQuiz:getAllRandomWrongAnswer()
    local problem_number_list = self.m_problemList
    local wrong_answer_limit = 2
    local wrong_answer_list = {}
    
    local max_problem_number = table.count(self.m_dragonInfoList)
    while table.count(wrong_answer_list) < wrong_answer_limit do
        local rand = math_random(max_problem_number)

        -- problem_number_list에 이미 rand가 추가되었는지 확인
        local has_rand = false
        for _, v in ipairs(problem_number_list) do
            if (v == rand) then
                has_rand = true
            end
        end

        -- rand가 추가 안 되었고, 정답이 아니라면 problem_number_list에 추가
        if (not has_rand and self.m_currentAnswer ~= rand) then
            table.insert(wrong_answer_list, rand)
        end
    end
    
    return wrong_answer_list
end

-------------------------------------
-- function setButtonColor
-- @brief 속성과 버튼 색을 일치시킨다. 불 -> 빨강. 물 -> 파랑
-------------------------------------
function UI_EventImageQuiz:setButtonColor(is_same)
    local vars = self.vars
    
    local answer1 = vars['answerDidLabel1']:getString()
    local answer2 = vars['answerDidLabel2']:getString()
    local answer3 = vars['answerDidLabel3']:getString()
    
    local answer_color1 = string.sub(answer1, 6, 6)
    local answer_color2 = string.sub(answer2, 6, 6)
    local answer_color3 = string.sub(answer3, 6, 6)
    
    local difficulty = self.m_difficulty
    if (is_same == true) then
        local color1 = self:getButtonColorByLastDid(answer_color1)
        vars['answerLayer1']:setColor(color1)
        local color2 = self:getButtonColorByLastDid(answer_color2)
        vars['answerLayer2']:setColor(color2)
        local color3 = self:getButtonColorByLastDid(answer_color3)
        vars['answerLayer3']:setColor(color3)
    elseif (is_same == false) then
        local color1 = self:getRandomButtonColor()
        vars['answerLayer1']:setColor(color1)
        local color2 = self:getRandomButtonColor()
        vars['answerLayer2']:setColor(color2)
        local color3 = self:getRandomButtonColor()
        vars['answerLayer3']:setColor(color3)
    end
end

-------------------------------------
-- function getButtonColorByLastDid
-- @brief did의 마지막 숫자에 따라 색깔 반환
-------------------------------------
function UI_EventImageQuiz:getButtonColorByLastDid(last_did)
    local last_did = tonumber(last_did)
	local color = cc.c3b(0, 0, 0)

    if (last_did == 1) then -- 땅
        color = cc.c3b(96, 198, 13)
    elseif (last_did == 2) then -- 물
        color = cc.c3b(0, 115, 255)
    elseif (last_did == 3) then -- 불
        color = cc.c3b(255, 37, 0)        
    elseif (last_did == 4) then -- 빛
        color = cc.c3b(255, 221, 7)
    else -- 어둠
        color = cc.c3b(154, 11, 247)
    end

    return color
end

-------------------------------------
-- function getRandomButtonColor
-- @brief 랜덤한 색깔 반환
-------------------------------------
function UI_EventImageQuiz:getRandomButtonColor()
    local rand = math_random(5)
	local color = cc.c3b(0, 0, 0)

    if (rand == 1) then -- 땅
        color = cc.c3b(96, 198, 13)
    elseif (rand == 2) then -- 물
        color = cc.c3b(0, 115, 255)
    elseif (rand == 3) then -- 불
        color = cc.c3b(255, 37, 0)        
    elseif (rand == 4) then -- 빛
        color = cc.c3b(255, 221, 7)
    else -- 어둠
        color = cc.c3b(154, 11, 247)
    end

    return color
end

-------------------------------------
-- function moveButtons
-- @brief 랜덤한 버튼 위치. 버튼이 가운데로 움직이기 때문에 잘 작동하지 않음.
-------------------------------------
function UI_EventImageQuiz:moveButtons(button_name)
    self:moveButton('answerBtn1')
    self:moveButton('answerBtn2')
    self:moveButton('answerBtn3')
end

-------------------------------------
-- function moveButton
-- @brief 랜덤한 버튼 위치. 버튼이 가운데로 움직이기 때문에 잘 작동하지 않음.
-------------------------------------
function UI_EventImageQuiz:moveButton(button_name)
    local vars = self.vars
    local answer_btn = vars[button_name] -- button
    local button_x = 0
    if (button_name == 'answerBtn1') then
        button_x = self.m_button1PositionX
    elseif (button_name == 'answerBtn2') then
        button_x = self.m_button2PositionX
    elseif (button_name == 'answerBtn3') then
        button_x = self.m_button3PositionX
    end
    local button_y = self.m_buttonPositionY
    local duration = 1
    local interval = 25
    

    local action1 = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(button_x + interval, button_y + interval)))
    local action2 = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(button_x + interval, button_y - interval)))
    local action3 = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(button_x - interval, button_y - interval)))
    local action4 = cc.Sequence:create(cc.MoveTo:create(duration, cc.p(button_x - interval, button_y + interval)))
    local sequence = cc.Sequence:create(action1, action2, action3, action4)
    local repeat_action = cc.RepeatForever:create(sequence)

    answer_btn:runAction(repeat_action)
end

-------------------------------------
-- function spotlightScan
-- @brief 스포트라이트 효과
-------------------------------------
function UI_EventImageQuiz:spotlightScan()
    local vars = self.vars
    local duration = 0.5
    
    vars['spotlight']:stopAction(self.m_spotlightAction)
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
    local action_scale = cc.ScaleTo:create(duration, 5)
    local sequence = cc.Sequence:create(l_action[1], l_action[2], l_action[3], action_scale)
    self.m_spotlightAction = sequence

    vars['spotlight']:runAction(sequence)
end

-------------------------------------
-- function spotlightScaleUp
-- @brief 스포트라이트 scale up 효과. 중앙에서 커지기만함
-------------------------------------
function UI_EventImageQuiz:spotlightScaleUp()
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
-- @brief 타일 효과
-------------------------------------
function UI_EventImageQuiz:blindTile()
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
-- @brief 타일 한 개 한 개 지우기
-------------------------------------
function UI_EventImageQuiz:removeBlindTileUnit()
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
        self.m_blindTileAction = blind_tile_action
        node:runAction(blind_tile_action)
    end
end

-------------------------------------
-- function DragonScaleUp
-- @brief 드래곤 확대
-------------------------------------
function UI_EventImageQuiz:DragonScaleUp(from)
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
-- @brief 화면의 상/하/좌/우에서 나타남
-- @param from 1:위, 2:아래, 3:왼쪽, 4:오른쪽 (상하좌우)
-------------------------------------
function UI_EventImageQuiz:dragonSlide()
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
-- @brief 커튼 이미지에 가려 있다가 커튼이 좌/우로 이동하며 등장
-- @param to 1:왼쪽으로, 2:오른쪽으로
-------------------------------------
function UI_EventImageQuiz:blindImage(to)
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

-- 사용하지 않음
-- 1. 카드에 속성이 찍혀있음
-- 2. 오류 발생 (해결 가능)
--    오류 : 초기 레벨 1, 2인 몬스터가 나타날 때 오류가 발생함
--    해결 : 초기 레벨 1, 2인 몬스터가 나타나면 새로 문제를 생성함.
-- 사용하지 않는 이유 : 1. 카드에 속성이 찍혀있음
-------------------------------------
-- function dragonIcon
-- @brief 드래곤 아이콘 띄워주기
-------------------------------------
--function UI_EventImageQuiz:dragonIcon()
    --local vars = self.vars
    --local table_item = TableItem()
    --local did = self.m_dragonInfoList[self.m_problemList[self.m_currentProblemNumber]]['did']
    --local item_id = table_item:getItemIDByDid(did)
--
    --local item_card = UI_ItemCard(item_id, 1)
	--vars['dragonNode']:addChild(item_card.root)
--end

-------------------------------------
-- function setAnswerButton
-- @param 정답 버튼 생성
-------------------------------------
function UI_EventImageQuiz:setAnswerButton(wrong_answer_list)
    local vars = self.vars
    local dragon_info_list = self.m_dragonInfoList
    local problem_list = self.m_problemList
    local current_problem_number = self.m_currentProblemNumber
    local answer_button_number = math_random(3)

    local wrong_answer_number = 1
    for i = 1, 3 do
        if (i == answer_button_number) then
            self.m_currentAnswer = i
            local dragon_name = dragon_info_list[problem_list[current_problem_number]]['c_name']
            local dragon_id = dragon_info_list[problem_list[current_problem_number]]['did']
            local label = Str(dragon_name)
            vars['answerLabel' .. i]:setString(label)
            vars['answerDidLabel' .. i]:setString(dragon_id)
        else
            local dragon_name = dragon_info_list[wrong_answer_list[wrong_answer_number]]['c_name']
            local dragon_id = dragon_info_list[wrong_answer_list[wrong_answer_number]]['did']
            local label = Str(dragon_name)
            vars['answerLabel' .. i]:setString(label)
            vars['answerDidLabel' .. i]:setString(dragon_id)
            wrong_answer_number = wrong_answer_number + 1
        end
    end
end
-------------------------------------
-- function setAnswerButtonBlind
-- @brief 랜덤한 색깔 반환
-------------------------------------
function UI_EventImageQuiz:setAnswerButtonBlind()
    local vars = self.vars
    local node = vars['tempNodeForBlockLayerColor']
    node:stopAction(self.m_blindButtonAction)
    local random_color = math_random(3)

    if (random_color == 1) then
        vars['blockLayer1']:setVisible(true)
    elseif (random_color == 2) then
        vars['blockLayer2']:setVisible(true)
    else
        vars['blockLayer3']:setVisible(true)
    end

    local function clearBlind()
        vars['blockLayer1']:setVisible(false)
        vars['blockLayer2']:setVisible(false)
        vars['blockLayer3']:setVisible(false)
    end

    local blind_button_action = cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(clearBlind))
    self.m_blindButtonAction = blind_button_action
    node:runAction(blind_button_action)
end

-------------------------------------
-- function setDragon
-------------------------------------
function UI_EventImageQuiz:setDragon()
    local problem_list = self.m_problemList
    local dragon_info_list = self.m_dragonInfoList
    local evolution = math_random(3)
    local flv = 0
    local current_problem_number = self.m_currentProblemNumber
    local did = dragon_info_list[problem_list[current_problem_number]]['did']

    self.m_dragonAnimator:setDragonAnimator(did, evolution, flv)
end

-------------------------------------
-- function click_Btn
-------------------------------------
function UI_EventImageQuiz:click_exitBtn()
	self:setExitEnbaled(false)

    local is_use_loading = true
    local scene = SceneLobby(is_use_loading)
    scene:runScene()
end

-------------------------------------
-- function click_answerBtn1
-------------------------------------
function UI_EventImageQuiz:click_answerBtn1()
    self:isRightAnswer(1)
end

-------------------------------------
-- function click_answerBtn2
-------------------------------------
function UI_EventImageQuiz:click_answerBtn2()
    self:isRightAnswer(2)
end

-------------------------------------
-- function click_answerBtn3
-------------------------------------
function UI_EventImageQuiz:click_answerBtn3()
    self:isRightAnswer(3)
end

-------------------------------------
-- function isRightAnswer
-- @brief 정답인지 확인
-------------------------------------
function UI_EventImageQuiz:isRightAnswer(answer)
    local is_right_answer = false

    if (self.m_currentAnswer == answer) then
        UIManager:toastNotificationGreen('정답입니다.')
        self.m_answerCount = self.m_answerCount + 1
        is_right_answer = true
    else
        UIManager:toastNotificationGreen('바부...')
        self.m_wrongAnswerCount = self.m_wrongAnswerCount + 1
        is_right_answer = false
    end

    self:successOrFail(is_right_answer, answer)
end

-------------------------------------
-- function successOrFail
-- @brief 성공 -> 다음 게임 / 실패 -> 버튼 invisible
-------------------------------------
function UI_EventImageQuiz:successOrFail(is_right_answer, number)
    local vars = self.vars

    if (is_right_answer) then
        self:setGame()
    else
        vars['answerBtn' .. number]:setVisible(false)
    end
end

-------------------------------------
-- function setAnswerCountLabel
-- @brief 정답인지 확인
-------------------------------------
function UI_EventImageQuiz:setAnswerCountLabel()
    local vars = self.vars
    vars['scoreLabel']:setString('정답 갯수 : ' .. tostring(self.m_answerCount) .. ' 오답 갯수 : ' .. tostring(self.m_wrongAnswerCount))
end

-------------------------------------
-- function devSetButton
-- @brief 개발용 버튼 등록
-------------------------------------
function UI_EventImageQuiz:devSetButton()
    local vars = self.vars
    vars['devBtn1']:registerScriptTapHandler(function() self:click_devBtn(1) end)
    vars['devBtn2']:registerScriptTapHandler(function() self:click_devBtn(2) end)
    vars['devBtn3']:registerScriptTapHandler(function() self:click_devBtn(3) end)
    vars['devBtn4']:registerScriptTapHandler(function() self:click_devBtn(4) end)
    vars['devBtn5']:registerScriptTapHandler(function() self:click_devBtn(5) end)
    vars['devBtn6']:registerScriptTapHandler(function() self:click_devBtn(6) end)
    vars['devBtn7']:registerScriptTapHandler(function() self:click_devBtn(7) end)
    vars['devBtn8']:registerScriptTapHandler(function() self:click_devBtn(8) end)
    vars['devBtn9']:registerScriptTapHandler(function() self:click_devBtn(9) end)
    self.devBtn1 = false
    self.devBtn2 = false
    self.devBtn3 = false
    self.devBtn4 = false
    self.devBtn5 = false
    self.devBtn6 = false
    self.devBtn7 = false
    self.devBtn8 = false
    self.devBtn9 = false
end

-------------------------------------
-- function click_devBtn
-- @brief 개발용 버튼 누를 때
-------------------------------------
function UI_EventImageQuiz:click_devBtn(num)
    local vars = self.vars
    if (num == 1) then
        self.devBtn1 = not self.devBtn1
        vars['devLayer1']:setVisible(self.devBtn1)
    elseif (num == 2) then
        self.devBtn2 = not self.devBtn2
        vars['devLayer2']:setVisible(self.devBtn2)
    elseif (num == 3) then
        self.devBtn3 = not self.devBtn3
        vars['devLayer3']:setVisible(self.devBtn3)
    elseif (num == 4) then
        self.devBtn4 = not self.devBtn4
        vars['devLayer4']:setVisible(self.devBtn4)
    elseif (num == 5) then
        self.devBtn5 = not self.devBtn5
        vars['devLayer5']:setVisible(self.devBtn5)
    elseif (num == 6) then
        self.devBtn6 = not self.devBtn6
        vars['devLayer6']:setVisible(self.devBtn6)
    elseif (num == 7) then
        self.devBtn7 = not self.devBtn7
        vars['devLayer7']:setVisible(self.devBtn7)
    elseif (num == 8) then
        self.devBtn8 = not self.devBtn8
        vars['devLayer8']:setVisible(self.devBtn8)
    else
        self.devBtn9 = not self.devBtn9
        vars['devLayer9']:setVisible(self.devBtn9)
    end
end

-------------------------------------
-- function devStartGame
-- @brief 개발용 버튼 설정에 따른 게임 시작
-------------------------------------
function UI_EventImageQuiz:devStartGame()
    if (self.devBtn1) then
        self:blindImage()
    end
    if (self.devBtn2) then
        self:blindTile()
    end
    if (self.devBtn3) then
        self:spotlightScaleUp()
    end
    if (self.devBtn4) then
        self:spotlightScan()
    end
    if (self.devBtn5) then
        self:dragonSlide()
    end
    if (self.devBtn6) then
        self:DragonScaleUp()
    end
    if (self.devBtn7) then
        self:setButtonColor(false)
    else
        self:setButtonColor(true)
    end
    if (self.devBtn8) then
        self:setAnswerButtonBlind()
    end
    if (self.devBtn9) then
        self:moveButtons()
    end
    --self:blindImage()
    --self:blindTile()
    --self:spotlightScaleUp()
    --self:spotlightScan()
    --self:dragonSlide()
    --self:dragonIcon() -- 사용하지 않음
    --self:DragonScaleUp()
    --self:setButtonColor(false) -- fake_color
    --self:setButtonColor(true) -- true_color
    --self:setAnswerButtonBlind()
    --self:moveButtons()
end

-------------------------------------
-- function setDifficulty
-- @brief 정답인지 확인
-------------------------------------
function UI_EventImageQuiz:setDifficulty()
    local problem_number = self.m_currentProblemNumber
    if (problem_number < 10) then
        self.m_difficulty = 1
    elseif (problem_number < 20) then
        self.m_difficulty = 2
    elseif (problem_number < 40) then
        self.m_difficulty = 3
    elseif (problem_number < 60) then
        self.m_difficulty = 4
    else
        self.m_difficulty = 5
    end
end