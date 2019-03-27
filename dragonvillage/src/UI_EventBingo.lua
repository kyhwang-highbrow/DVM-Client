local PARENT = UI

-------------------------------------
-- class UI_EventBingo
-------------------------------------
UI_EventBingo = class(PARENT,{
        m_lBingoNumber = 'list', -- 획득한 빙고 숫자 리스트
        m_lBingoCntReward = '_UI_EventBingoRewardListItem', -- 빙고 횟수에 따른 보상 UI
        m_lBingoLineReward = '_UI_EventBingoRewardListItem', -- 빙고 라인 보상 UI

        m_container = 'ScrolView Container',
        m_containerTopPosY = 'number',
        m_isContainerMoving = 'bool',
    })

local BINGO_TYPE = {['HORIZONTAL'] = 1, ['VERTICAL'] = 2, ['CROSS_RIGHT_TO_LEFT'] = 3, ['CROSS_LEFT_TO_RIGHT'] = 4}

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingo:init()
    local vars = self:load('event_bingo.ui')

    self:initUI()
    self:initButton()
    self:refresh()
    self:refresh_bingoCntReward()
    self:refresh_bingoReward()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingo:initUI()
    local vars = self.vars
    local struct_bingo = g_eventBingoData.m_structBingo
    
    -- 선택한 번호로 확정 뽑기
    local func_click_bingoNum = function(selected_num)
        self:request_selectedDraw(selected_num)
        self:setCancelActive(vars['goraMenu3'], false)
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
    end

    self.m_lBingoNumber = {}
    -- 빙고 칸 세팅
    for i = 1, 25 do
        local ui = _UI_EventBingoListItem(i, func_click_bingoNum)
        local node = vars['bingoNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_lBingoNumber, ui)
        end
    end

    local click_bingo_reward_cb = function(ind)
            self:click_rewardBingo(ind)
    end

    self.m_lBingoLineReward = {}
    -- 빙고 라인 보상 세팅
    local l_bingo_reward = struct_bingo:getBingoLineRewardList()
    for i, data in ipairs(l_bingo_reward) do
        local node_ind = data['bingo_num']
        local item_str = data['reward']
        local node = vars['itemNode' .. node_ind]      
        local ui = UI_EventBingoRewardListItem(node_ind, item_str, click_bingo_reward_cb)            
        if (node) and (ui) then
            node:addChild(ui.root)
            table.insert(self.m_lBingoLineReward, ui)
        end
    end

    local click_bingo_cnt_cb = function(ind)
        self:click_cntRewardBingo(ind)
    end
    
    -- 빙고 갯수 보상
    self.m_lBingoCntReward = {}
    local l_reward_item = struct_bingo:getBingoRewardList()
    for ind, data in ipairs(l_reward_item) do
        local ui = UI_EventBingoRewardListItem(ind, data['reward_str'], click_bingo_cnt_cb, true, data['reward_index']) -- reward_ind, reward_item_str, click_cb, is_bingo_reward, sub_data
        vars['rewardIconNode']:addChild(ui.root)
        if (#l_reward_item == ind) then
            ui.vars['lastRewardVisual']:setVisible(true)
            ui.vars['lastRewardVisual']:setIgnoreLowEndMode(true)
        end
        table.insert(self.m_lBingoCntReward, ui)
    end

    -- 완성된 빙고 표기
    vars['visualNode']:removeAllChildren()
    local m_bingo_line = struct_bingo:getBingoLine()
    for line_number, state in pairs(m_bingo_line) do
        self:setBingo(line_number)
    end

    vars['ggSprite']:setPercentage(0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingo:initButton()
    local vars = self.vars

    vars['playBtn1']:registerScriptTapHandler(function() self:click_drawNumberBtn() end)
    vars['playBtn2']:registerScriptTapHandler(function() self:click_chooseNumberBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['cancleBtn']:registerScriptTapHandler(function() self:click_cancelPick() end)
    vars['cancleBtn']:setVisible(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventBingo:refresh()
    local vars = self.vars
    
    local remain_time = g_eventBingoData:getStatusText()
    local struct_bingo = g_eventBingoData:getStructEventBingo()

    local bingo_line_cnt = struct_bingo:getBingoLineCnt()
    vars['timeLabel']:setString(remain_time)
    
    local cur_cnt = struct_bingo:getTodayEventItemCnt()
    local max_cnt = struct_bingo:getTodayMaxEventItemCnt()
    vars['numberLabel1']:setString(Str('{1}/{2}개', comma_value(cur_cnt), comma_value(max_cnt)))
    vars['obtainLabel']:setString(Str('일일 최대 {1}개 획득 가능', comma_value(max_cnt)))
    vars['rewardLabel']:setString(Str('{1} 빙고 보상', bingo_line_cnt))
    vars['progressLabel']:setString(Str('진행도: {1}/12', bingo_line_cnt))

    local eventCnt = struct_bingo:getEventItemCnt()
    local eventPickCnt = struct_bingo:getPickEventItemCnt()
    vars['numberLabel2']:setString(Str('{1}개', comma_value(eventCnt)))
    vars['numberLabel3']:setString(Str('{1}개', comma_value(eventPickCnt))) 
    vars['rewardLabel']:setString(Str('{1} 빙고', bingo_line_cnt))
    vars['tokenPrice']:setString(struct_bingo.event_price)
    vars['pickTokenPrice']:setString(struct_bingo.event_pick_price)


    local l_cnt_reward = struct_bingo:getBingoRewardList()
    local next_step = 12
    for ind, data in ipairs(l_cnt_reward) do
        if (bingo_line_cnt < data['reward_index']) then
            next_step = data['reward_index']
            break
        end
    end

    vars['progressLabel']:setString(Str('다음 보상까지 {1}빙고 남았습니다.', next_step - bingo_line_cnt))
    if (next_step - bingo_line_cnt == 0) then
        vars['progressLabel']:setVisible(false)
    end

    -- 누적 보상 게이지
    local reward_cnt = bingo_line_cnt
    local max_reward = 12
    local percentage = reward_cnt/max_reward * 100
    vars['ggSprite']:runAction(cc.ProgressTo:create(0.2, percentage))

    -- 획득한 빙고 숫자 표기
    local l_bingo_number = struct_bingo:getBingoNumberList()
    for i, number in ipairs(l_bingo_number) do
        local is_pick = false
        self.m_lBingoNumber[tonumber(number)]:setActiveNumber(is_pick)
    end

    -- 빙고 12개 완료 되었을 경우
    if (struct_bingo:getBingoLineCnt() == 12) then
        self:completeBingo()
    end

    local eventPickCnt = struct_bingo:getPickEventItemCnt()
    local is_pickable = eventPickCnt >= 10
    vars['playBtn2']:setEnabled(is_pickable)
end

-------------------------------------
-- function getBingoType
-- @brief 
-------------------------------------
function UI_EventBingo:getBingoType(bingo_line_number)
    local bingo_line_number = tonumber(bingo_line_number)
    if (bingo_line_number == 7) then
        return BINGO_TYPE.CROSS_LEFT_TO_RIGHT, nil
    elseif (bingo_line_number == 1) then
        return BINGO_TYPE.CROSS_RIGHT_TO_LEFT, nil    
    elseif (bingo_line_number>=2 and bingo_line_number<=6) then
        return BINGO_TYPE.HORIZONTAL, bingo_line_number - 1
    elseif (bingo_line_number>=8 and bingo_line_number<=12) then
        return BINGO_TYPE.VERTICAL, 13 - bingo_line_number
    end
end

-------------------------------------
-- function refresh_bingoCntReward
-- @brief 
-------------------------------------
function UI_EventBingo:refresh_bingoCntReward()
    local l_bingo_cnt = self.m_lBingoCntReward
    local struct_bingo = g_eventBingoData.m_structBingo
    local bingo_cnt = struct_bingo:getBingoRewardCnt()

    local one_enabled = false
    for ind, ui_data in ipairs(l_bingo_cnt) do
        local reward_state = struct_bingo:getBingoCntRewardState(ui_data.m_rewardInd)
        ui_data:setBtnEnabled(false)
        -- 획득 완료
        if (reward_state == 1) then
            ui_data.vars['checkSprite']:setVisible(true)
            ui_data.vars['receiveBtn']:setVisible(false)
        -- 획득 가능
        elseif (reward_state == 0) then
            -- 받을 수 있는 버튼 한 개만 눌리도록
            if (one_enabled == false) then
                if (bingo_cnt >= ui_data.m_sub_data) then
                    ui_data.vars['checkSprite']:setVisible(false)
                    ui_data.vars['receiveBtn']:setVisible(true)
                    ui_data:setBtnEnabled(true)
                    one_enabled = true
                end
            end           
        end
    end
end

-------------------------------------
-- function refresh_bingoReward
-------------------------------------
function UI_EventBingo:refresh_bingoReward()
    local l_bingo_cnt = self.m_lBingoLineReward
    local struct_bingo = g_eventBingoData.m_structBingo

    for ind, ui_data in pairs(l_bingo_cnt) do
        local reward_state = struct_bingo:getBingoLineRewardState(ui_data.m_rewardInd)
        -- 획득 완료
        if (reward_state == 1) then
            ui_data.vars['completeSprite']:setVisible(true)
            ui_data.vars['receiveVisual']:setVisible(false)
            ui_data:setBtnEnabled(false)
        -- 획득 가능
        elseif (reward_state == 0) then
            ui_data.vars['completeSprite']:setVisible(false)
            ui_data.vars['receiveVisual']:setVisible(true)
            ui_data:setBtnEnabled(true)
        else
            ui_data:setBtnEnabled(false)
        end       
    end
end

-------------------------------------
-- function setBingo
-- @brief 빙고가 성립됨
-------------------------------------
function UI_EventBingo:setBingo(bingo_line_number) -- HORIZONTAL, VERTICAL, CROSS
    local vars = self.vars
    local bingo_type, line = self:getBingoType(bingo_line_number)
    -- 보상 버튼 활성화

    -- a2d 빙고 표시 애니메이션
    local ani = MakeAnimator('res/ui/a2d/event_bingo/event_bingo.vrp')
    vars['visualNode']:addChild(ani.m_node)

    local pos_x, pos_y = self:getLinePos(bingo_type, line)
    ani:setPosition(pos_x, pos_y)

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then
        ani:changeAni('horizontal')
    elseif (bingo_type == BINGO_TYPE.VERTICAL) then
        ani:changeAni('vertical')    
    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then
        ani:changeAni('cross_right_to_left')
    else
        ani:changeAni('cross_left_to_right')
    end

    -- 후속 연출
	ani:addAniHandler(function()
	    self:refresh_bingoCntReward()
        self:refresh_bingoReward()
    end)

end

-------------------------------------
-- function getLinePos
-------------------------------------
function UI_EventBingo:getLinePos(bingo_type, line) -- param 의미 : 가로 3 번 째줄, 세로 1 번 째줄
    local vars = self.vars

    local pos_x, pos_y = 0, 0
    local offset = 50 -- 빙고칸 절반크기 조금 안되는 위치

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then        -- 가로 빙고 : line 첫 칸 - offsetX
        local _line = 1 + (line-1) * 5
        pos_x, pos_y = vars['bingoNode'.._line]:getPosition()
        pos_x = pos_x - 60

    elseif (bingo_type == BINGO_TYPE.VERTICAL) then       -- 세로 빙고 : line 첫 줄 + offsetY
        pos_x, pos_y = vars['bingoNode'..line]:getPosition()
        pos_y = pos_y + 60

    elseif (bingo_type == BINGO_TYPE.CROSS_LEFT_TO_RIGHT) then  -- 대각선 빙고(left_to_right) : 1번 칸 - offsetX + offsetY
        pos_x, pos_y = vars['bingoNode1']:getPosition()
        pos_x = -230
        pos_y = 230

    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then  -- 대각선 빙고(right_to_left) : 1번 칸 + offsetX + offsetY
        pos_x, pos_y = vars['bingoNode5']:getPosition()
        pos_x = 230
        pos_y = 230
    end

    return pos_x, pos_y
end

-------------------------------------
-- function pickNumberAction
-- @brief 숫자들이 막 바뀌다가 고정되는 액션
-------------------------------------
function UI_EventBingo:pickNumberAction(number, finish_cb)
    local vars = self.vars
    local change_speed = 0.06
    local repeat_cnt = 12
    local delete_time = 0.7

    if (not vars['pickAniSprite']) then
        return
    end
    
    vars['pickAniSprite']:setVisible(true)
    vars['bingoSprite']:setVisible(true)

    local random_frunc = function()
        local num = math_random(24) + 1
        local _num = string.format('%03d', num) --ex) 001, ..023 3자리 형식
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end
    
    local end_frunc = function()
        local num = number
        local _num = string.format('%03d', num) --ex) 001, ..023 3자리 형식
        local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
        vars['pickAniSprite']:setTexture(num_sprite_name)
    end
    
    local delete_frunc = function()
        vars['pickAniSprite']:setVisible(false)
        vars['bingoSprite']:setVisible(false)
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
        self:refresh()
        if (finish_cb) then
            finish_cb()
        end
    end
    

    -- 랜덤으로 바뀌는 효과
    local random_action = cc.CallFunc:create(random_frunc)
    local delay_action = cc.DelayTime:create(change_speed)

    local repeat_sequence_action = cc.Sequence:create(random_action, delay_action)
    local repeat_action = cc.Repeat:create(repeat_sequence_action, repeat_cnt)
    local accel_repeat = cc.EaseIn:create(repeat_action, 0.5)
    local end_action = cc.CallFunc:create(end_frunc)
    local delete_delay_action = cc.DelayTime:create(delete_time)
    local delete_action = cc.CallFunc:create(delete_frunc)
    
    local sequence_action = cc.Sequence:create(accel_repeat, end_action, delete_delay_action, delete_action)

    cca.runAction(self.root, sequence_action, nil)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventBingo:click_infoBtn()
    local ui = UI()
    ui:load('event_exchange_info_popup.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'event_chuseok_info_popup')
    UIManager:open(ui, UIManager.POPUP)
end

-------------------------------------
-- function click_drawNumberBtn
-------------------------------------
function UI_EventBingo:click_drawNumberBtn()
    local struct_bingo = g_eventBingoData.m_structBingo

    -- 빙고판이 보이도록 포커싱
    self:moveContainer(0)
    if (struct_bingo:getEventItemCnt() < struct_bingo.event_price) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('보유 토큰')))
        return
    end

    -- 통신 전, 블럭 팝업 생성
    local block_ui = UI_BlockPopup()

    local cb_func = function(ret)
        local finish_cb = function()
            local l_clear = ret['bingo_clear']
            local is_same_number = g_eventBingoData.m_isSameNumber
            if (is_same_number) then
                self:showSameNumberAction(ret['bingo_number'])
                self:showSameNumberGora()
            else
                self:showNewNumberGora()
            end
            
            for i, number in ipairs(l_clear) do
                self:setBingo(number)
            end

            block_ui:close()
        end
        
        self:pickNumberAction(tonumber(ret['bingo_number']), finish_cb)        
    end
    g_eventBingoData:request_DrawNumber(cb_func)
end

-------------------------------------
-- function bingoNumBtnEnabled
-------------------------------------
function UI_EventBingo:bingoNumBtnEnabled(is_enabled)
    local l_bingo_num = self.m_lBingoNumber

    for _, ui in ipairs(l_bingo_num) do
        ui:setBtnEnabled(is_enabled)
    end
end

-------------------------------------
-- function click_chooseNumberBtn
-------------------------------------
function UI_EventBingo:click_chooseNumberBtn()
    local vars = self.vars
    local l_bingo_num = self.m_lBingoNumber
    local struct_bingo = g_eventBingoData.m_structBingo

    -- 빙고판이 보이도록 포커싱
    self:moveContainer(0)

    if (struct_bingo:getPickEventItemCnt() < struct_bingo.event_pick_price) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('확정 뽑기 토큰')))
        return
    end
    
    for _, ui in ipairs(l_bingo_num) do
        ui:setBtnEnabled(true)
    end

    self:setCancelActive(vars['goraMenu3'], true)
end

-------------------------------------
-- function resetGoraAction
-------------------------------------
function UI_EventBingo:resetGoraAction()
    self.vars['goraMenu1']:setPosition(cc.p(-200, 50))
    self.vars['goraMenu2']:setPosition(cc.p(-200, 50))
    self.vars['goraMenu3']:setPosition(cc.p(-200, 50))

    self.vars['goraMenu1']:stopAllActions()
    self.vars['goraMenu2']:stopAllActions()
    self.vars['goraMenu3']:stopAllActions()

    self.vars['goraMenu1']:setVisible(false)
    self.vars['goraMenu2']:setVisible(false)
    self.vars['goraMenu3']:setVisible(false)
end

-------------------------------------
-- function request_selectedDraw
-------------------------------------
function UI_EventBingo:request_selectedDraw(selected_num)    
     -- 통신 전, 블럭 팝업 생성
     local block_ui = UI_BlockPopup()

     local cb_func = function(ret)
        self:bingoNumBtnEnabled(false)

        local l_clear = ret['bingo_clear']
        for i, number in ipairs(l_clear) do
            self:setBingo(number)
        end

        self:refresh()
        block_ui:close()
     end  
     
     g_eventBingoData:request_DrawNumber(cb_func, selected_num)
end

-------------------------------------
-- function click_cntRewardBingo
-------------------------------------
function UI_EventBingo:click_cntRewardBingo(reward_ind)
    local struct_bingo = g_eventBingoData.m_structBingo
    local is_received = struct_bingo:getBingoCntRewardState(reward_ind)
    if (is_received == 1) then
       return
    end
    
    -- 통신 전, 블럭 팝업 생성
    local block_ui = UI_BlockPopup()
    
    local cb_func = function(ret)
        self:refresh_bingoReward()
        self:refresh_bingoCntReward()
        block_ui:close()
    end

    g_eventBingoData:request_rewardBingo('step', reward_ind, cb_func)
end

-------------------------------------
-- function click_rewardBingo
-------------------------------------
function UI_EventBingo:click_rewardBingo(reward_ind)
    local struct_bingo = g_eventBingoData.m_structBingo
    local is_received = struct_bingo:getBingoLineRewardState(reward_ind)

    -- 받은 보상이라면 통신x
    if (is_received == 1) then
        return
    end

    -- 통신 전, 블럭 팝업 생성
    local block_ui = UI_BlockPopup()
    
    local cb_func = function(ret)
        self:refresh_bingoReward()
        self:refresh_bingoCntReward()
        block_ui:close()
    end
    g_eventBingoData:request_rewardBingo('bingo', reward_ind, cb_func)
end

-------------------------------------
-- function click_cancelPick
-------------------------------------
function UI_EventBingo:click_cancelPick()
    local vars = self.vars
    self:bingoNumBtnEnabled(false)
    self:setCancelActive(vars['goraMenu3'], false)
end

-------------------------------------
-- function completeBingo
-------------------------------------
function UI_EventBingo:completeBingo()
    local vars = self.vars
    vars['completeNode']:setVisible(true)
    vars['playBtn1']:setEnabled(false)
    vars['playBtn2']:setEnabled(false)
end

-------------------------------------
-- function showSameNumberGora
-------------------------------------
function UI_EventBingo:showSameNumberGora()
    local vars = self.vars
    self:resetGoraAction()
    self:showGoraAnimation(vars['goraMenu2'])
end
-------------------------------------
-- function showNewNumberGora
-------------------------------------
function UI_EventBingo:showNewNumberGora()
    local vars = self.vars
    self:resetGoraAction()
    self:showGoraAnimation(vars['goraMenu1'])
end

-------------------------------------
-- function showAnimation
-------------------------------------
function UI_EventBingo:showGoraAnimation(node)
    node:setVisible(true)
    node:setPosition(cc.p(-200, 50))
    
    local delete_func = function()
        node:setVisible(false)
    end

    -- 만드라 고라 나타나는 효과
    local delete_delay_action = cc.DelayTime:create(5)
    local move_action_1 = cc.EaseOut:create(cc.MoveTo:create(0.05, cc.p(4.5, 50)), 0.3)
    local move_action_2 = cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(-200, 50)), 0.3)
    local delete_action = cc.CallFunc:create(delete_func)
    local sequence_action = cc.Sequence:create(move_action_1, delete_delay_action, move_action_2, delete_action)
    node:runAction(sequence_action)
end

-------------------------------------
-- function moveFrontGoraAnimation
-------------------------------------
function UI_EventBingo:moveFrontGoraAnimation(node)
    node:setVisible(true)
    node:setPosition(cc.p(-200, 50))

    -- 만드라 고라 옆에서 나오는 효과
    local delete_delay_action = cc.DelayTime:create(1)
    local move_action_1 = cc.EaseOut:create(cc.MoveTo:create(0.05, cc.p(4.5, 50)), 0.3)
    node:runAction(move_action_1)
end

------------------------------------
-- function moveBackGoraAnimation
-------------------------------------
function UI_EventBingo:moveBackGoraAnimation(node)
    local delete_func = function()
        node:setVisible(false)
    end

    -- 만드라 고라 옆으로 나가는 효과
    local move_action_2 = cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(-200, 50)), 0.3)
    local delete_action = cc.CallFunc:create(delete_func)
    local sequence_action = cc.Sequence:create( move_action_2, delete_action)
    node:runAction(sequence_action)
end

------------------------------------
-- function setCancelActive
-------------------------------------
function UI_EventBingo:setCancelActive(node, is_active)
    local vars = self.vars
    
    if (not node) then
        return nil
    end
    
    vars['cancleBtn']:setVisible(is_active)
    vars['playBtn1']:setEnabled(not is_active)

    if (is_active) then
        self:resetGoraAction()
        self:moveFrontGoraAnimation(node)
    else
        self:moveBackGoraAnimation(node)
    end
end

-------------------------------------
-- function showSameNumberAction
-------------------------------------
function UI_EventBingo:showSameNumberAction(number)
    local vars = self.vars

    local struct_bingo = g_eventBingoData:getStructEventBingo()
    cca.stampShakeActionLabel(vars['cashNode2'], 2, 0.1, 0, 0)
    vars['pickTokenPrice']:setString(struct_bingo.event_pick_price)
    
    self.m_lBingoNumber[number]:setSameNumberAction()
end

-------------------------------------
-- function moveContainer
-------------------------------------
function UI_EventBingo:moveContainer(pos_y, is_force)
    -- 컨테이너가 없거나 이동중이면 다시 움직이지 않는다.
    if (not is_force) then
        if (not self.m_container) then
            return
        end
        if (self.m_isContainerMoving) then
            return
        end
    end

    -- 현재의 좌표와 이동할 좌표가 같다면 이동하지 않음.. 강제는 가능
    if (not is_force) and (self.m_container:getPositionY() == pos_y) then
        return
    end
    self.m_container:stopAllActions()

    local duration = 0.5
    local move = cca.makeBasicEaseMove(duration, 0, pos_y)
    local cb = cc.CallFunc:create(function()
        self.m_isContainerMoving = false
    end)
    local sequence = cc.Sequence:create(move, cb)
    self.m_container:runAction(sequence)
    
    self.m_isContainerMoving = true
end

-------------------------------------
-- function setContainerAndPosY
-------------------------------------
function UI_EventBingo:setContainerAndPosY(container, pos_y)
    self.m_container = container
    self.m_containerTopPosY = pos_y
end














local PARENT = UI
-------------------------------------
-- class _UI_EventBingoListItem
-------------------------------------
_UI_EventBingoListItem = class(PARENT,{
        m_bingoInd = 'number',
        m_click_cb = 'function',
        m_isPickedNumber = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function _UI_EventBingoListItem:init(number, click_cb)
    local vars = self:load('event_bingo_item_01.ui')
    self.m_bingoInd = number
    self.m_click_cb = click_cb
    self.m_isPickedNumber = false

    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function _UI_EventBingoListItem:initUI()
    local vars = self.vars
    
    -- 1~ 25까지 세팅
    local _num = string.format('%03d', self.m_bingoInd) --ex) 001, ..023 3자리 형식
    local num_sprite_name = string.format('res/ui/icons/bingo/%s.png', _num)
    vars['numberSprite']:setTexture(num_sprite_name)
    vars['numberSprite']:setColor(cc.c3b(240,215,159))
end

-------------------------------------
-- function setActiveNumber
-- @brief 빙고 숫자를 활성화(유효하게)
-------------------------------------
function _UI_EventBingoListItem:setActiveNumber(is_pick)
    local vars = self.vars
    local action_speed = 0.1

    if (self.m_isPickedNumber) then
        return
    end

    local func_active = function()
        vars['clearSprite']:setVisible(true)
        vars['numberSprite']:setColor(cc.c3b(72,25,0))
    end 
    
    -- 카드 뒤집는 효과
    local flip_action = cc.ScaleTo:create(action_speed, 0, 1)
    local cb_frunc = cc.CallFunc:create(func_active)
    local flip_action_reverse = cc.ScaleTo:create(action_speed, 1, 1)
	local sequence_action = cc.Sequence:create(flip_action, cb_frunc, flip_action_reverse)
    cca.runAction(self.root, sequence_action, nil)
    self.m_isPickedNumber = true

    -- 확정 뽑기의 경우, 선택한 숫자 정보를 서버에 보냄
    if (is_pick) then
        self.m_click_cb(self.m_bingoInd)

    end
end

-------------------------------------
-- function initButton
-------------------------------------
function _UI_EventBingoListItem:initButton()
    local vars = self.vars

    vars['clickBtn']:registerScriptTapHandler(function() self:setActiveNumber(true) end)
    self:setBtnEnabled(false)
end

-------------------------------------
-- function setBtnEnabled
-- @breif 확정 뽑기를 위해 전체 버튼을 turn on/off
-------------------------------------
function _UI_EventBingoListItem:setBtnEnabled(is_enabled)
    local vars = self.vars

    -- 이미 골라진 숫자가 아닐 경우에만 버튼 on/off
    -- 버튼 누를 수 있는 상태 = 확정 버튼 누른 상태
    if (not self.m_isPickedNumber) then
        vars['clickBtn']:setEnabled(is_enabled)
        vars['pickSprite']:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 100))))
        vars['pickSprite']:setVisible(is_enabled)
    end

    -- 활성화 아닐때에는, 고를 수 있는 표시 무조건 끔
    if (not is_enabled) then
        vars['pickSprite']:setVisible(false)
    end
end

-------------------------------------
-- function setSameNumberAction
-------------------------------------
function _UI_EventBingoListItem:setSameNumberAction()
    local vars = self.vars
    local cb_func = function()
        vars['clearSprite']:setOpacity(255)
    end
    local func_action = cc.CallFunc:create(cb_func)
    vars['clearSprite']:runAction(cc.Repeat:create(cc.Sequence:create(cc.FadeTo:create(0.4, 0), cc.FadeTo:create(0.4, 100), func_action), 2))
end
