local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchasePointNew
-------------------------------------
UI_EventPopupTab_PurchasePointNew = class(PARENT,{
        m_eventVersion = '',
        m_rewardUIList = '',
        m_rewardBoxUIList = '',

        m_selectedLastRewardIdx = 'number', -- 선택된 마지막 보상 idx

        m_tabButtonCallback = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:init(event_version)
    self.m_selectedLastRewardIdx = 1
    self.m_eventVersion = event_version
    self:load('event_purchase_point_new.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:initUI()
    local vars = self.vars

    local version = self.m_eventVersion
    local step_count = g_purchasePointData:getPurchasePoint_stepCount(version)

    self.m_rewardUIList = {}
    self.m_rewardBoxUIList = {}
    
    -- 0 은 0점
    vars['scoreLabel0']:setString(Str('{1}점', 0))

    -- 보상 아이템 카드
    for step=1, step_count do
        local last_step_point = g_purchasePointData:getPurchasePoint_lastStepPoint(version)
        local item_node = vars['itemNode'..step]
        if item_node then
            item_node:setVisible(true)
            -- 아이템 프레임
            local ui_frame = UI()
            ui_frame:load('event_purchase_point_item_new_01.ui')
            ui_frame.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
            item_node:addChild(ui_frame.root)
            
            local item_id, count = self:getRewardInfoByStep(version, step)

            -- 아이템 카드
            local ui_card = UI_ItemCard(item_id, count)
             
            -- 만약 드래곤 카드라면 드래곤 정보 팝업
            local did = tonumber(TableItem:getDidByItemId(item_id))
            if did and (0 < did) then
                ui_card.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
            end

            ui_frame.vars['iconNode']:addChild(ui_card.root)
            ui_frame.root:setScale(1.2)
            ui_card.root:setScale(0.7)

            -- 보상 점수
            local point = g_purchasePointData:getPurchasePoint_step(version, step)
            vars['scoreLabel' .. step]:setString(Str('{1}점', comma_value(point)))
            --vars['scoreLabel' .. step]:setString(comma_value(point))
            cclog(point)
            table.insert(self.m_rewardBoxUIList, ui_frame)
        end
    end

    vars['purchaseGg']:setPercentage(0)

    
    -- 타입에 따른 누적 결제 배경UI
    local last_reward_type = g_purchasePointData:getLastRewardType(version)
    local last_reward_item_id, count = self:getRewardInfoByStep(version, step_count)
    require('UI_PurchasePointBgNew')
    local ui_bg = UI_PurchasePointBgNew(last_reward_type, last_reward_item_id, count, version)
    if (ui_bg) then
        vars['productNode']:addChild(ui_bg.root)
    end

    do -- 4단계 보상 3개 버튼 생성
        local step = step_count
        for reward_idx=1, 3 do
            local item_id, item_cnt = self:getRewardInfoByStep(version, step, reward_idx)
            local ui = UI()
            ui:load('event_purchase_point_item_new_03.ui')
            do -- 아이템 카드
                local ui_card = UI_ItemCard(item_id, item_cnt)
                ui_card:setEnabledClickBtn(false) -- 아이콘 클릭 안되게
                ui.vars['itemNode']:addChild(ui_card.root)
            end
            do -- 아이템 이름 (수량)
                local item_name = TableItem:getItemName(item_id)
                if (item_cnt <= 1) then
                    ui.vars['itemLabel']:setString(item_name)
                else
                    local str =  Str('{1} {2}개', item_name, comma_value(item_cnt))
                    ui.vars['itemLabel']:setString(str)
                end
            end
            do -- 버튼
                ui.vars['clickBtn']:registerScriptTapHandler(function() self:click_lastRewardIdx(reward_idx) end)
            end
            vars['clickNode' .. reward_idx]:addChild(ui.root) -- clickNode1, clickNode2, clickNode3
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:initButton()
    local vars = self.vars
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function getRewardInfoByStep
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:getRewardInfoByStep(version, step, reward_idx)
    local reward_idx = (reward_idx or 1)

    local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)
    local package_item_str = t_step['item']
    if (reward_idx ~= 1) then
        package_item_str = t_step['item_' .. tostring(reward_idx)]
    end
    local l_reward = ServerData_Item:parsePackageItemStr(package_item_str)
    
    -- 구조상 다중 보상 지급이 가능하나, 현재로선 하나만 처리 중 sgkim 2018.10.17
    local first_item = l_reward[1]
    local item_id = first_item['item_id']
    local count = first_item['count']

    return item_id, count
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh()
    local vars = self.vars
    
    local version = self.m_eventVersion

    -- 이벤트 종료까지 남은 시간
    local str = g_purchasePointData:getPurchasePointEventRemainTimeText(version)
    vars['timeLabel']:setString(str)
    vars['timeLabel']:setVisible(true)

    -- 누적 결제 점수
    local purchase_point = g_purchasePointData:getPurchasePoint(version)
    local str = Str('누적 결제 점수: {1}점', comma_value(purchase_point))
    vars['scoreLabel']:setString(str)

	--[[
    -- 누적 결제 시간 안내
    local time_str = g_purchasePointData:getPurchasePointTime(version)
    vars['timeLabel']:setString(time_str)
	--]]


    -- 보상 수령 상태 안내 메세지
    local last_step = g_purchasePointData:getPurchasePoint_stepCount(version)
    local curr_step = g_purchasePointData:getPurchaseRewardStep(version)
    local str = ''
    if (last_step <= curr_step) then
        str = Str('보상 수령 완료')
    else
        local next_purchase_point = g_purchasePointData:getPurchasePoint_step(version, (curr_step + 1))
        local value = (next_purchase_point - purchase_point)
        if (value < 0) then
            str = Str('보상 수령 가능')
        else
            str = Str('다음 보상까지 {1}점 남았습니다.', comma_value(value))
        end
    end
    vars['nextStepLabel']:setString(str)

    -- 결제 포인트 게이지
    local _purchase_point = purchase_point
    local percentage = 0
    local prev_point = 0
    for i=1, last_step do
        local _point = g_purchasePointData:getPurchasePoint_step(version, i)
        local temp = prev_point
        prev_point = _point
        _point = (_point - temp)

        if (_point <= _purchase_point) then
            percentage = (percentage + (1/last_step))
        else
            percentage = (percentage + (_purchase_point/_point/last_step))
            break
        end
        _purchase_point = (_purchase_point - _point)
    end
    percentage = math_clamp((percentage * 100), 0, 100)
    vars['purchaseGg']:runAction(cc.ProgressTo:create(0.2, percentage)) 

    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function refresh_rewardUIList
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh_rewardUIList()
    if (not self.m_rewardUIList) then
        return
    end

    for _,ui in pairs(self.m_rewardUIList) do
        ui:refresh()
    end
end

-------------------------------------
-- function refresh_rewardBoxUIList
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:refresh_rewardBoxUIList()
    if (not self.m_rewardBoxUIList) then
        return
    end

    local version = self.m_eventVersion

    for step,ui in pairs(self.m_rewardBoxUIList) do
        local vars = ui.vars
        local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)
        vars['checkSprite']:setVisible(false)
        vars['receiveBtn']:setVisible(false)

        -- 획득 완료
        if (reward_state == 1) then
            vars['checkSprite']:setVisible(true)
            vars['receiveBtn']:setVisible(false)
        -- 획득 가능
        elseif (reward_state == 0) then
            vars['checkSprite']:setVisible(false)
            vars['receiveBtn']:setVisible(true)

        -- 획득 불가
        --elseif (reward_state == -1) then
        else
            --vars['closeSprite']:setVisible(true)
        end

    end
end


-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_helpBtn()
    UI_GuidePopup_PurchasePoint()
end

-------------------------------------
-- function click_receiveBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_receiveBtn(reward_step)

    if (reward_step == 4) then
        require('UI_PurchasePointRewardSelectPopup')
        local ui = UI_PurchasePointRewardSelectPopup(self.m_eventVersion)
        ui:setCloseCB(function() self:refresh() end)
        return
    end

    local version = self.m_eventVersion

    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)

        self:refresh()

        if self.m_tabButtonCallback then
            self.m_tabButtonCallback()
        end
    end

    g_purchasePointData:request_purchasePointReward(version, reward_step, 1, cb_func)
end

-------------------------------------
-- function click_lastRewardIdx
-- @brief 마지막 보상 선택 버튼
-------------------------------------
function UI_EventPopupTab_PurchasePointNew:click_lastRewardIdx(reward_idx)
    if (self.m_selectedLastRewardIdx == reward_idx) then
        return
    end
    self.m_selectedLastRewardIdx = reward_idx

    local vars = self.vars

    do -- 배경 생성
        vars['productNode']:removeAllChildren()

        local version = self.m_eventVersion
        local step_count = g_purchasePointData:getPurchasePoint_stepCount(version)

        -- 타입에 따른 누적 결제 배경UI
        local last_reward_type = g_purchasePointData:getLastRewardType(version, reward_idx)
        if (last_reward_type == nil) then
            last_reward_type = 'item'
        end
        local last_reward_item_id, count = self:getRewardInfoByStep(version, step_count, reward_idx)
        require('UI_PurchasePointBgNew')
        local ui_bg = UI_PurchasePointBgNew(last_reward_type, last_reward_item_id, count, version)
        if (ui_bg) then
            vars['productNode']:addChild(ui_bg.root)
        end
    end

    do -- 아이템 프레임
        local version = self.m_eventVersion

        local step = 4
        local item_node = vars['itemNode'..step]
        item_node:removeAllChildren()
        local ui_frame = UI()
        ui_frame:load('event_purchase_point_item_new_01.ui')
        ui_frame.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
        item_node:addChild(ui_frame.root)
        self.m_rewardBoxUIList[step] = ui_frame
            
        local item_id, count = self:getRewardInfoByStep(version, step, reward_idx)

        -- 아이템 카드
        local ui_card = UI_ItemCard(item_id, count)
         
        -- 만약 드래곤 카드라면 드래곤 정보 팝업
        local did = tonumber(TableItem:getDidByItemId(item_id))
        if did and (0 < did) then
            ui_card.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
        end

        ui_frame.vars['iconNode']:addChild(ui_card.root)
        ui_frame.root:setScale(1.2)
        ui_card.root:setScale(0.7)
    end

    self:refresh_rewardBoxUIList()
end

--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchasePointNew)
