local PARENT = UI

-------------------------------------
-- class UI_EventBingo
-------------------------------------
UI_EventBingo = class(PARENT,{
        m_lBingoNumber = 'list', -- 획득한 빙고 숫자 리스트
        m_lBingoCntReward = 'table', -- 빙고 횟수에 따른 보상 테이블
        m_lBingoLineReward = 'table', -- 빙고 라인 보상 테이블

        m_packageName = '',

        m_lExchangeUI = 'UI_EventBingoExchangeListItem', -- 교환 상품 UI 리스트

        m_container = 'ScrolView Container',
        m_containerTopPosY = 'number',
        m_isContainerMoving = 'bool',


        -- 빙고 패키지 결제 팝업 버튼
        m_bingoPackageBtn = '',
        m_maskingUI = '',


        m_exchangeResult = '',
        m_exchangeItemIndex = ''
    })

local BINGO_TYPE = {['HORIZONTAL'] = 1, ['VERTICAL'] = 2, ['CROSS_RIGHT_TO_LEFT'] = 3, ['CROSS_LEFT_TO_RIGHT'] = 4}
local BINGO_FOCUS_POS = {['DEFUALT'] = -680, ['BINGO'] = -400, ['EXCHANGE'] = 0}

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingo:init()
    local vars = self:load('event_bingo.ui')

    self.m_packageName = 'package_bingo_token'

    self.m_bingoPackageBtn = vars['bingoBtn']
    self.m_exchangeResult = nil
    self.m_exchangeItemIndex = nil

    self:initUI()
    self:initButton()
    self:initExchangeReward()
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
    
    self:setBingoNumber() -- 빙고 칸 UI 세팅
    self:setBingoLineReward() -- 빙고 라인 보상 UI 세팅
    self:setBingoCntReward() -- 빙고 갯수 보상 UI 세팅
    
    -- 완성된 빙고 표기
    vars['visualNode']:removeAllChildren()
    local m_bingo_line = struct_bingo:getBingoLine()
    for line_number, state in pairs(m_bingo_line) do
        self:setBingo(line_number)
    end

    vars['ggSprite']:setPercentage(0)

    -- 빙고 완성 전에는 교환 버튼 비활성화
    vars['lockSprite']:setVisible(true)
    vars['exchangeBtn']:setEnabled(false)

    do -- 
        local masking_ui = UI_BlockPopup()
        local function touch_func(touch, event)
            self:exchange_callback()
        end

        local layer = cc.Layer:create()
        masking_ui.root:addChild(layer, -100)

        local listener = cc.EventListenerTouchOneByOne:create()

        listener:registerScriptHandler(function() return true end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touch_func, cc.Handler.EVENT_TOUCH_ENDED)

        local eventDispatcher = layer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        
        masking_ui.root:setVisible(false)
        self.m_maskingUI = masking_ui
    end

    
end

-------------------------------------
-- function setBingoNumber
-------------------------------------
function UI_EventBingo:setBingoNumber()
    local vars = self.vars

    -- 확정 뽑기 클릭
    local func_click_bingoNum = function(selected_num)
        self:request_selectedDraw(selected_num)  -- 뽑은 숫자 통신
        self:setPickingMode(false)               -- 확정 뽑기 아닌 상태로 세팅
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
    end

    self.m_lBingoNumber = {}

    -- 빙고 칸 세팅
    for i = 1, 36 do
        local ui = UI_EventBingoListItem(i, func_click_bingoNum) -- 빙고 넘버, 확정 뽑기 눌렀을 때 콜백
        local node = vars['bingoNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_lBingoNumber, ui)
        end
    end
end

-------------------------------------
-- function setBingoLineReward
-------------------------------------
function UI_EventBingo:setBingoLineReward()
    local vars = self.vars
    local struct_bingo = g_eventBingoData.m_structBingo

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
        local ui = UI_EventBingoRewardListItem(node_ind, item_str, click_bingo_reward_cb) -- param : node, 12001;1, click_cb            
        if (node) and (ui) then
            node:addChild(ui.root)
            table.insert(self.m_lBingoLineReward, ui)
        end
    end

end

-------------------------------------
-- function setBingoCntReward
-------------------------------------
function UI_EventBingo:setBingoCntReward()
    local vars = self.vars
    local struct_bingo = g_eventBingoData.m_structBingo

    local click_bingo_cnt_cb = function(ind)
        self:click_cntRewardBingo(ind)
    end

    -- 빙고 갯수 보상
    self.m_lBingoCntReward = {}
    local l_reward_item = struct_bingo:getBingoRewardList()
    for ind, data in ipairs(l_reward_item) do
        local ui = UI_EventBingoRewardListItem(ind, data['reward_str'], click_bingo_cnt_cb, true, data['reward_index']) -- param : reward_ind, reward_item_str, click_cb, is_bingo_reward, sub_data
        vars['rewardIconNode']:addChild(ui.root)
        if (#l_reward_item == ind) then -- 마지막 보상은 강조를 위해 비쥬얼 추가
            ui.vars['lastRewardVisual']:setVisible(true)
            ui.vars['lastRewardVisual']:setIgnoreLowEndMode(true)
        end
        table.insert(self.m_lBingoCntReward, ui)
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_EventBingo:initButton()
    local vars = self.vars

    vars['playBtn1']:registerScriptTapHandler(function() self:click_drawNumberBtn() end)
    vars['playBtn1']:getParent():setSwallowTouch(false)
    
    vars['playBtn2']:registerScriptTapHandler(function() self:click_chooseNumberBtn() end)
    vars['playBtn2']:getParent():setSwallowTouch(false)

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['infoBtn']:getParent():setSwallowTouch(false)

    vars['cancleBtn']:registerScriptTapHandler(function() self:click_cancelPick() end) -- 확정뽑기 눌렀을 때, 확정 뽑기 취소할 수 있는 버튼
    vars['cancleBtn']:getParent():setSwallowTouch(false)

    vars['exchangeBtn']:registerScriptTapHandler(function() self:click_exchangeBtn() end)
    vars['exchangeBtn']:getParent():setSwallowTouch(false)

    if self:check_packagesOnTime() then 
        self.m_bingoPackageBtn:registerScriptTapHandler(function() self:click_packageBtn() end)
        self.m_bingoPackageBtn:getParent():setSwallowTouch(false)
        self.m_bingoPackageBtn:setAutoShake(true)
    else
        self.m_bingoPackageBtn:setVisible(false)
    end

    vars['cancleBtn']:setVisible(false)
    vars['cancleBtn']:getParent():setSwallowTouch(false)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventBingo:refresh()
    local vars = self.vars
    
    local remain_time = g_eventBingoData:getStatusText()
    local struct_bingo = g_eventBingoData:getStructEventBingo()

    local bingo_line_cnt = struct_bingo:getBingoLineCnt()
    local bingo_cnt = struct_bingo:getBingoNumberCnt()
    vars['timeLabel']:setString(remain_time)
    
    local cur_cnt = struct_bingo:getTodayEventItemCnt()
    local max_cnt = struct_bingo:getTodayMaxEventItemCnt()
    vars['numberLabel1']:setString(Str('{1}/{2}개', comma_value(cur_cnt), comma_value(max_cnt)))
    vars['obtainLabel']:setString(Str('일일 최대 {1}개 획득 가능', comma_value(max_cnt)))
    vars['rewardLabel']:setString(Str('{1} 빙고 보상', bingo_line_cnt))
    vars['progressLabel']:setString(Str('진행도: {1}/12', bingo_line_cnt))

    local eventCnt = struct_bingo:getEventItemCnt()
    local eventPickCnt = struct_bingo:getPickEventItemCnt()
    vars['numberLabel2']:setString(Str('{1}개', comma_value(eventCnt))) -- 보유 토큰
    vars['numberLabel3']:setString(Str('{1}개', comma_value(eventPickCnt))) -- 확정 뽑기 토큰
    vars['rewardLabel']:setString(Str('{1} 칸', bingo_cnt))
    vars['tokenPrice']:setString(struct_bingo.event_price)  -- 빙고 뽑기 1회 비용
    vars['pickTokenPrice']:setString(struct_bingo.event_pick_price) -- 확정 뽑기 1회 비용

    local eventCnt = struct_bingo:getEventItemCnt()
    local exchangePrice = struct_bingo:getExchangePrice() 
    vars['exchangePrice']:setString(Str('{1}/{2}', comma_value(eventCnt), exchangePrice))

    -- 누적 보상 다음 스텝 정보 : ex) 다음 빙고까지 ~ 남았다
    -- 빙고갯수보다 많은 누적 보상 스텝 = next_step
    local l_cnt_reward = struct_bingo:getBingoRewardList()
    local next_step = struct_bingo:getLastRewardCnt()
    for ind, data in ipairs(l_cnt_reward) do
        if (bingo_cnt < data['reward_index']) then
            next_step = data['reward_index']
            break
        end
    end

    vars['progressLabel']:setString(Str('다음 보상까지 {1}칸 남았습니다.', next_step - bingo_cnt))
    
    -- 남은 빙고 없다면 ~남았다는 라벨 비활성화
    if (next_step - bingo_cnt == 0) then
        vars['progressLabel']:setVisible(false)
    end

    -- 누적 보상 게이지
    local bingo_count = bingo_cnt
    local percentage = 0
    local prev_count = 0
    for i=1, 5 do
        local temp_count = struct_bingo.m_lSortedCntReward[i]['reward_index']
        local temp = prev_count
        prev_count = temp_count
        temp_count = (temp_count - temp)

        if (temp_count <= bingo_count) then
            percentage = (percentage + (1/5))
        else
            percentage = (percentage + (bingo_count/temp_count/5))
            break
        end
        bingo_count = (bingo_count - temp_count)
    end
    percentage = math_clamp((percentage * 100), 0, 100)
    vars['ggSprite']:runAction(cc.ProgressTo:create(0.2, percentage)) 
   
    -- 획득한 빙고 숫자 표기
    local l_bingo_number = struct_bingo:getBingoNumberList()
    for i, number in ipairs(l_bingo_number) do
        local is_pick = false
        self.m_lBingoNumber[tonumber(number)]:setActiveNumber(is_pick)
    end

    -- 확정 뽑기 가능할 때만 버튼 활성화
    local eventPickCnt = struct_bingo:getPickEventItemCnt()
    local is_pickable = eventPickCnt >= struct_bingo.event_pick_price
    vars['playBtn2']:setEnabled(is_pickable)

    -- 빙고 모두 완료 되었을 경우
    if (bingo_cnt == 36) then
        self:completeBingo()
    end
end

-------------------------------------
-- function getBingoType
-- @return BINGO_TYPE, ex) 가로에서 n번째 라인
-------------------------------------
function UI_EventBingo:getBingoType(bingo_line_number)
    local bingo_line_number = tonumber(bingo_line_number)
    
    -- 빙고 7번은 대각선 빙고(왼쪽->오른쪽)
    if (bingo_line_number == 7) then
        return BINGO_TYPE.CROSS_LEFT_TO_RIGHT, nil
    -- 빙고 1번은 대각선 빙고(오른쪽->왼쪽)
    elseif (bingo_line_number == 14) then
        return BINGO_TYPE.CROSS_RIGHT_TO_LEFT, nil    
    -- 빙고 2-6번은 가로 빙고
    elseif (bingo_line_number >= 1 and bingo_line_number <= 6) then
        return BINGO_TYPE.HORIZONTAL, bingo_line_number
    -- 빙고 8-12번은 세로 빙고
    elseif (bingo_line_number >= 8 and bingo_line_number <= 13) then
        return BINGO_TYPE.VERTICAL, 13 - bingo_line_number
    end
end

-------------------------------------
-- function refresh_bingoCntReward
-- @brief 빙고 누적 보상, 획득 완료/가능 표시
-------------------------------------
function UI_EventBingo:refresh_bingoCntReward()
    local l_bingo_cnt = self.m_lBingoCntReward
    local struct_bingo = g_eventBingoData.m_structBingo
    local bingo_cnt = struct_bingo:getBingoNumberCnt()

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
-- @brief 빙고 라인보상 획득 완료/가능 표시
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
function UI_EventBingo:setBingo(bingo_line_number)
    local vars = self.vars
    local bingo_type, line = self:getBingoType(bingo_line_number) -- 빙고 라인 넘버
    local sample_ui_name = ''

    -- a2d 빙고 표시 애니메이션
    local ani = MakeAnimator('res/ui/a2d/event_bingo/event_bingo.vrp')
    vars['visualNode']:addChild(ani.m_node)

    local pos_x, pos_y = self:getLinePos(bingo_type, line)
    ani.m_node:setPosition(pos_x, pos_y)


    if (bingo_type == BINGO_TYPE.HORIZONTAL) then
        ani:changeAni('horizontal')
        sample_ui_name = 'widthSample'
    
    elseif (bingo_type == BINGO_TYPE.VERTICAL) then
        ani:changeAni('vertical')
        sample_ui_name = 'heightSample'

    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then
        ani:changeAni('cross_right_to_left')
        sample_ui_name = 'rtlSample'
        
    else
        ani:changeAni('cross_left_to_right')
        sample_ui_name = 'ltrSample'
    end

    if (vars[sample_ui_name]) then
        local scale_x = vars[sample_ui_name]:getScaleX()
        local scale_y = vars[sample_ui_name]:getScaleY()
        ani.m_node:setScaleX(scale_x)
        ani.m_node:setScaleY(scale_y)
    end

    -- 후속 연출, 선이 그어지고 나서 보상 받을 수 있게 활성화
	ani:addAniHandler(function()
	    self:refresh_bingoCntReward()
        self:refresh_bingoReward()
    end)

end

-------------------------------------
-- function getLinePos
-- param 의미 : 가로 3 번 째줄, 세로 1 번 째줄
-------------------------------------
function UI_EventBingo:getLinePos(bingo_type, line)
    local vars = self.vars

    local pos_x, pos_y = 0, 0
    local offset = 76 -- 빙고칸 크기

    if (bingo_type == BINGO_TYPE.HORIZONTAL) then        -- 가로 빙고
        pos_x, pos_y = vars['widthSample']:getPosition()               -- 가로 1번 째 칸 위치 하드코딩
        pos_y = pos_y - offset*(line - 1)

    elseif (bingo_type == BINGO_TYPE.VERTICAL) then       -- 세로 빙고
        pos_x, pos_y = vars['heightSample']:getPosition()               -- 세로 6번 째 칸 위치 하드코딩
        pos_x = pos_x + offset*(line - 5)

    elseif (bingo_type == BINGO_TYPE.CROSS_LEFT_TO_RIGHT) then  -- 대각선 빙고(left_to_right)
        pos_x, pos_y = vars['ltrSample']:getPosition()

    elseif (bingo_type == BINGO_TYPE.CROSS_RIGHT_TO_LEFT) then  -- 대각선 빙고(right_to_left)
        pos_x, pos_y = vars['rtlSample']:getPosition()
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
    local repeat_cnt = 25
    local delete_time = 0.5

    if (not vars['pickAniSprite']) then
        return
    end
    
    vars['pickAniSprite']:setVisible(true)
    vars['bingoSprite']:setVisible(true)

    local random_frunc = function()
        local num = math_random(35) + 1
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
        vars['pickAniSprite']:setColor(cc.c3b(255, 255, 255))
        vars['pickAniSprite']:setScale(2)
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
        self:refresh()
        self:refresh_bingoCntReward()
        if (finish_cb) then
            finish_cb()
        end
    end
    
    local change_func = function()
        vars['pickAniSprite']:setColor(cc.c3b(255,215,0))
        vars['pickAniSprite']:setScale(2.35)
    end

    -- 랜덤으로 바뀌는 효과
    local random_action = cc.CallFunc:create(random_frunc)
    local delay_action = cc.DelayTime:create(change_speed)

    local repeat_sequence_action = cc.Sequence:create(random_action, delay_action)
    local repeat_action = cc.Repeat:create(repeat_sequence_action, repeat_cnt)
    local accel_repeat = cc.EaseIn:create(repeat_action, 0.1)
    local end_action = cc.CallFunc:create(end_frunc)
    local delete_delay_action = cc.DelayTime:create(delete_time)
    local change_color = cc.CallFunc:create(change_func)
    local delete_action = cc.CallFunc:create(delete_frunc)
    
    local sequence_action = cc.Sequence:create(accel_repeat, end_action, delete_delay_action, change_color, delete_delay_action, delete_action)

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
-- function click_exchangeBtn
-------------------------------------
function UI_EventBingo:exchange_callback()
    if self.m_exchangeResult ~= nil and self.m_exchangeItemIndex ~= nil then
        self.root:stopAllActions()

        for index, ui in ipairs(self.m_lExchangeUI) do
            if index == self.m_exchangeItemIndex then
                ui:setHighlight(true)
            else
                ui:setHighlight(false)
            end
        end

        self:confirm_reward(self.m_exchangeResult)

        
        UIManager:blockBackKey(false)
        self.m_maskingUI.root:setVisible(false)
        
        self.m_exchangeResult = nil
        self.m_exchangeItemIndex = nil
    end
end



-------------------------------------
-- function click_exchangeBtn
-------------------------------------
function UI_EventBingo:click_exchangeBtn()
    local struct_bingo = g_eventBingoData.m_structBingo
    local eventCnt = struct_bingo:getEventItemCnt()
    local exchangePrice = struct_bingo:getExchangePrice()
    if (eventCnt < exchangePrice) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('보유 토큰')))
        return
    end

    -- 통신 전, 블럭 팝업 생성
    --local block_ui = UI_BlockPopup()
    
    UIManager:blockBackKey(true)
    self.m_maskingUI.root:setVisible(true)
    self.m_maskingUI.root:setOpacity(0)

    local cb_func = function(ret)
        -- 번호 뽑힌 후 콜백
        local finish_cb = function()
            --block_ui:close()
            UIManager:blockBackKey(false)
            self.m_maskingUI.root:setVisible(false)
            self:confirm_reward(ret)

            self.m_exchangeResult = nil
            self.m_exchangeItemIndex = nil
        end

        self:refresh()
        -- 랜덤하게 보여주다가, 뽑힌 번호 보여주는 액션
        local picked_item_number = self:getExchangeNumber(ret)

        self.m_exchangeResult = ret
        self.m_exchangeItemIndex = picked_item_number

        self:startExchangePickAction(picked_item_number, finish_cb)  
    end

    -- 통신
    g_eventBingoData:request_exchangeDraw(cb_func)
end

-------------------------------------
-- function getExchangeNumber
-------------------------------------
function UI_EventBingo:getExchangeNumber(ret)
    if (not ret) then
        return 1
    end

    local item_info = ret['item_info']
    if (not item_info) then
        return 1
    end

    local item_id = item_info['item_id']
    if (not item_id) then
        return 1
    end

    local item_cnt = item_info['count']
    if (not item_cnt) then
        return 1
    end

    local l_exchange = self.m_lExchangeUI
    for ind, ui in ipairs(l_exchange) do
        if (ui:isSameItem(item_id, item_cnt)) then
             return ind
        end
    end

    return 1
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function UI_EventBingo:confirm_reward(ret)
    if ret then
        local item_info = ret['item_info'] or nil
        if (item_info) then
            UI_MailRewardPopup(item_info)
        else
            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)

            g_highlightData:setHighlightMail()
        end
    end
end

-------------------------------------
-- function click_drawNumberBtn
-------------------------------------
function UI_EventBingo:click_drawNumberBtn()
    local struct_bingo = g_eventBingoData.m_structBingo

    -- 빙고판이 보이도록 포커싱
    self:moveContainer(BINGO_FOCUS_POS.BINGO)
    if (struct_bingo:getEventItemCnt() < struct_bingo.event_price) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('보유 토큰')))
        return
    end

    -- 통신 전, 블럭 팝업 생성
    local block_ui = UI_BlockPopup()

    local cb_func = function(ret)
        -- 번호 뽑힌 후 콜백
        local finish_cb = function()
            local l_clear = ret['bingo_clear']

            local is_same_number = g_eventBingoData.m_isSameNumber
            
            -- 같은 번호 뽑았을 경우
            if (is_same_number) then
                self:showSameNumberAction(ret['bingo_number'])
                self:showSameNumberGora()
            -- 새로운 번호 뽑았을 경우
            else
                self:showNewNumberGora()
            end
            
            -- 추가된 빙고 라인 그려줌
            for i, number in ipairs(l_clear) do
                self:setBingo(number)
            end

            block_ui:close()
        end      
        -- 랜덤하게 보여주다가, 뽑힌 번호 보여주는 액션
        self:pickNumberAction(tonumber(ret['bingo_number']), finish_cb)   
    end

    -- 통신
    g_eventBingoData:request_DrawNumber(cb_func)
end

-------------------------------------
-- function bingoNumBtnEnabled
-- @brief 빙고 번호들 눌릴 수 있도록 세팅
-------------------------------------
function UI_EventBingo:bingoNumBtnEnabled(is_enabled)
    local l_bingo_num = self.m_lBingoNumber

    for _, ui in ipairs(l_bingo_num) do
        ui:setBtnEnabled(is_enabled)
    end
end

-------------------------------------
-- function click_chooseNumberBtn
-- @brief 확정뽑기 버튼 눌렀을 때
-------------------------------------
function UI_EventBingo:click_chooseNumberBtn()
    local vars = self.vars
    local l_bingo_num = self.m_lBingoNumber
    local struct_bingo = g_eventBingoData.m_structBingo

    -- 빙고판이 보이도록 포커싱
    self:moveContainer(BINGO_FOCUS_POS.BINGO)

    if (struct_bingo:getPickEventItemCnt() < struct_bingo.event_pick_price) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('확정 뽑기 토큰')))
        return
    end
    
    for _, ui in ipairs(l_bingo_num) do
        ui:setBtnEnabled(true)
    end

    self:setPickingMode(true)
end

-------------------------------------
-- function resetGoraAction
-------------------------------------
function UI_EventBingo:resetGoraAction()
    self.vars['goraMenu1']:setPosition(cc.p(-200, 50)) -- cc.p(-200, 50) 골드라고라 안 보이는 위치 하드코딩
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
-- @brief 확정 뽑기로 숫자 골랐을 때
-------------------------------------
function UI_EventBingo:request_selectedDraw(selected_num)    
     -- 통신 전, 블럭 팝업 생성
     local block_ui = UI_BlockPopup()

     local cb_func = function(ret)
        self:bingoNumBtnEnabled(false)

        local l_clear = ret['bingo_clear']
        -- 추가된 빙고라인 그리기
        for i, number in ipairs(l_clear) do
            self:setBingo(number)
        end

        self:refresh()
        self:refresh_bingoCntReward()
        block_ui:close()
     end  
     
     g_eventBingoData:request_DrawNumber(cb_func, selected_num)
end

-------------------------------------
-- function click_cntRewardBingo
-- @brief 누적 빙고 보상 받기 버튼
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
-- @brief 빙고 라인 보상
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
-- @brief 확정뽑기 취소
-------------------------------------
function UI_EventBingo:click_cancelPick()
    local vars = self.vars
    self:bingoNumBtnEnabled(false)
    self:setPickingMode(false)
end

-------------------------------------
-- function click_packageBtn
-------------------------------------
function UI_EventBingo:click_packageBtn()
    --UI_EventBingoPackagePopup()
    -- 빙고 패키지 팝업 
    PackageManager:getTargetUI(self.m_packageName, true)
end


-------------------------------------
-- function check_packagesOnTime
-------------------------------------
function UI_EventBingo:check_packagesOnTime()
    package_pids = TablePackageBundle:getPidsWithName(self.m_packageName)
    
    return g_shopData:isOnTimePackage(package_pids)
end

-------------------------------------
-- function completeBingo
-------------------------------------
function UI_EventBingo:completeBingo()
    local vars = self.vars
    vars['completeNode']:setVisible(true)
    vars['playBtn1']:setEnabled(false)
    vars['playBtn2']:setEnabled(false)
    vars['lockSprite']:setVisible(false)
    vars['exchangeBtn']:setEnabled(true)
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
-- function showGoraAnimation
-- @brief 만드라 고라 나타났다가, 일정 시간 후 다시 들어감
-------------------------------------
function UI_EventBingo:showGoraAnimation(node)
    node:setVisible(true)
    node:setPosition(cc.p(-200, 50))
    
    local delete_func = function()
        node:setVisible(false)
    end

    -- 만드라 고라 나타났다가, 일정 시간 후 다시 들어감
    local delete_delay_action = cc.DelayTime:create(5)
    local move_action_1 = cc.EaseOut:create(cc.MoveTo:create(0.05, cc.p(4.5, 50)), 0.3)
    local move_action_2 = cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(-200, 50)), 0.3)
    local delete_action = cc.CallFunc:create(delete_func)
    local sequence_action = cc.Sequence:create(move_action_1, delete_delay_action, move_action_2, delete_action)
    node:runAction(sequence_action)
end

-------------------------------------
-- function moveFrontGoraAnimation
-- @brief 만드라 고라 나타나기만 함
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
-- @brief 만드라 고라 들어감
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
-- function setPickingMode
-- @brief 확정 뽑기 고를 때 is_active = true, 확정 뽑기 고르는 거 끝났을 때 is_active = false
-------------------------------------
function UI_EventBingo:setPickingMode(is_active)
    local vars = self.vars
    
    -- 취소버튼, 토큰 뽑기 버튼 활성화 세팅
    vars['cancleBtn']:setVisible(is_active)
    vars['playBtn1']:setEnabled(not is_active)

    -- 확정 뽑기 고를 때, 다른 골드라고라 움직임 리셋+고르라고라 나타남
    if (is_active) then
        self:resetGoraAction()
        self:moveFrontGoraAnimation(vars['goraMenu3'])
    -- 확정 뽑기 끝났을 때,고르라고라를 옆으로 뺌
    else
        self:moveBackGoraAnimation(vars['goraMenu3'])
    end
end

-------------------------------------
-- function showSameNumberAction
-- @brief 같은 번호 뽑았을 때, 확정뽑기 버튼 잠깐 흔들어 주는 액션
-------------------------------------
function UI_EventBingo:showSameNumberAction(number)
    local vars = self.vars
    local cb_func = function()
        vars['cashNode2']:setScale(1)     
    end

    local struct_bingo = g_eventBingoData.m_structBingo
    local scale_action = cca.stampShakeActionLabel_action(vars['cashNode2'], 2, 0.1, 0, 0)
    local cb_action = cc.CallFunc:create(cb_func)
	local sequence_action = cc.Sequence:create(scale_action, cb_action)
    vars['cashNode2']:runAction(sequence_action)

    -- 아이템 갯수 갱신
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

-------------------------------------
-- function initExchangeReward
-------------------------------------
function UI_EventBingo:initExchangeReward()
    local vars = self.vars
    local struct_bingo = g_eventBingoData.m_structBingo
    
    self.m_lExchangeUI = {}
    local l_exchange = struct_bingo:getExchangeItemList()
    for ind, t_data in ipairs(l_exchange) do
        local node = vars['exchangeNode'..ind]
        if (node) then
            local ui_card = UI_EventBingoExchangeListItem(t_data)
            node:addChild(ui_card.root)
            table.insert(self.m_lExchangeUI, ui_card)
        end
    end
end

-------------------------------------
-- function startExchangePickAction
-------------------------------------
function UI_EventBingo:startExchangePickAction(number, finish_cb)
    local vars = self.vars

    local l_item_ui = self.m_lExchangeUI
    local struct_bingo = g_eventBingoData.m_structBingo
    local item_cnt = struct_bingo:getExchangeItemCnt()
    local pre_num = -1

    local change_speed = 0.1
    local repeat_cnt = 25
    local delete_time = 0.7

    local random_frunc = function()
        local num = math_random(1, item_cnt)
        if (pre_num == num) then
            num = math_random(1, item_cnt)
        end
        pre_num = num

        -- 전체 하이라이트 끔
        for _, ui in ipairs(l_item_ui) do
            ui:setHighlight(false)
        end
        -- 고른 ui만 하이라이트 킴
        l_item_ui[num]:setHighlight(true)
    end
    
    local end_frunc = function()
        local num = number
        -- 전체 하이라이트 끔
        for _, ui in ipairs(l_item_ui) do
            ui:setHighlight(false)
        end
        -- 고른 ui만 하이라이트 킴
        l_item_ui[num]:setHighlight(true)
    end
    
    local end_blinking_func = function()
        l_item_ui[number]:setColorChange()
    end

    local delete_frunc = function()
        -- 전체 하이라이트 끔
        for _, ui in ipairs(l_item_ui) do
            ui:setHighlight(false)
        end
        l_item_ui[number]:setColorDefault()
        SoundMgr:playEffect('UI', 'ui_dragon_level_up')
        if (finish_cb) then
            finish_cb()
        end
    end
    
    --notification.m_root:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 255), cc.DelayTime:create(4), cc.FadeTo:create(0.5, 0), cc.CallFunc:create(cb)))
    -- 랜덤으로 바뀌는 효과
    local random_action = cc.CallFunc:create(random_frunc)
    local delay_action = cc.DelayTime:create(change_speed)

    local repeat_sequence_action = cc.Sequence:create(random_action, delay_action)
    local repeat_action = cc.Repeat:create(repeat_sequence_action, repeat_cnt)
    local accel_repeat = cc.EaseIn:create(repeat_action, 0.1)
    local end_action = cc.CallFunc:create(end_frunc)
    local end_blinking = cc.CallFunc:create(end_blinking_func) 
    local delete_delay_action = cc.DelayTime:create(delete_time)
    local delete_action = cc.CallFunc:create(delete_frunc)
    
    local sequence_action = cc.Sequence:create(accel_repeat, end_action, delete_delay_action, end_blinking, delete_delay_action, delete_action)--, delete_delay_action, delete_action)

    cca.runAction(self.root, sequence_action, nil)
end











local PARENT = UI

--[[
    ['table']={
            ['pick_weight']=5;
            ['val']=180;
            ['category']='event_bingo';
            ['item_id']=700001;
            ['bid']=1010;
            ['val_min']='';
            ['val_max']='';
            ['grade']='';
            ['view']=1;
        };
--]]
-------------------------------------
-- class UI_EventBingoExchangeListItem
-------------------------------------
UI_EventBingoExchangeListItem = class(PARENT,{
        m_data = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventBingoExchangeListItem:init(t_data)
    local vars = self:load('event_bingo_item_04.ui')
    self.m_data = t_data
    self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventBingoExchangeListItem:initUI()
    local vars = self.vars

    if (not self.m_data['table']) then
        return
    end
    
    local data = self.m_data['table']
    if (not data) then
        return
    end

    local item_id = tonumber(data['item_id'])
    local item_cnt = tonumber(data['val'])

    local ui_card = UI_ItemCard(item_id, item_cnt)
    if (ui_card) then
        ui_card.root:setScale(0.66)
        ui_card:setSwallowTouch()
        vars['itemNode']:addChild(ui_card.root)
    end

    local pick_weight = data['pick_weight']
    vars['chanceLabel']:setString(string.format('%s', pick_weight) .. '%')
end

-------------------------------------
-- function setHighlight
-------------------------------------
function UI_EventBingoExchangeListItem:setHighlight(is_highlight)
    local vars = self.vars 
    vars['selectSprite']:setVisible(is_highlight)
    if (not is_highlight) then
        vars['selectSprite2']:setVisible(false)
    end
end

-------------------------------------
-- function isSameItem
-------------------------------------
function UI_EventBingoExchangeListItem:isSameItem(item_id, count)
    local data = self.m_data['table']
    if (not data) then
        return false
    end
    local _item_id = tonumber(data['item_id'])
    local _item_cnt = tonumber(data['val'])

    if (_item_id == item_id) and (count == _item_cnt) then
        return true
    end

    return false
end

-------------------------------------
-- function setBlink
-------------------------------------
function UI_EventBingoExchangeListItem:setBlink()
    self.vars['selectSprite']:runAction(cc.Repeat:create(cc.Sequence:create(cc.FadeTo:create(0.4, 0), cc.FadeTo:create(0.4, 100), func_action), 2))
end

-------------------------------------
-- function setColorDefault
-------------------------------------
function UI_EventBingoExchangeListItem:setColorDefault()
    self.vars['selectSprite']:setColor(cc.c3b(255, 255, 255))
end

-------------------------------------
-- function setColorChange
-------------------------------------
function UI_EventBingoExchangeListItem:setColorChange()
    self.vars['selectSprite2']:setVisible(true)
end