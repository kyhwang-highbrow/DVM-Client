local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchasePoint
-------------------------------------
UI_EventPopupTab_PurchasePoint = class(PARENT,{
        m_eventVersion = '',
        m_rewardUIList = '',
        m_rewardBoxUIList = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchasePoint:init(event_version)
    self.m_eventVersion = event_version
    self:load('event_purchase_point.ui')

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_EventPopupTab_PurchasePoint:initUI()
    local vars = self.vars

    local version = self.m_eventVersion
    local step_count = g_purchasePointData:getPurchasePoint_stepCount(version)

    self.m_rewardUIList = {}
    self.m_rewardBoxUIList = {}
    for step=1, step_count do
        local parent_node = vars['rewardNode' .. step]
        if parent_node then
            local ui = UI_PurchasePointListItem(version, step)
            parent_node:addChild(ui.root)
            ui.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
            table.insert(self.m_rewardUIList, ui)
        end

        -- 진행도 게이지 상자
        --local box_node = vars['boxNode' .. step]
        local last_step_point = g_purchasePointData:getPurchasePoint_lastStepPoint(version)
        local box_node = vars['boxNode']
        if box_node then
            local ui = UI()
            ui:load('event_purchase_point_item_02.ui')
            box_node:addChild(ui.root)

            local point = g_purchasePointData:getPurchasePoint_step(version, step)
            ui.vars['boxLabel']:setString(comma_value(point))

            local x_rate = (step / step_count) --(point / last_step_point)
            ui.root:setAnchorPoint(cc.p(1 - x_rate, 0.5))
            
            table.insert(self.m_rewardBoxUIList, ui)
        end
    end

    vars['purchaseGg']:setPercentage(0)

end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchasePoint:initButton()
    local vars = self.vars
    vars['helpBtn']:registerScriptTapHandler(function() self:click_helpBtn() end)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePoint:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchasePoint:refresh()
    local vars = self.vars
    
    local version = self.m_eventVersion

    -- 이벤트 종료까지 남은 시간
    local str = g_purchasePointData:getPurchasePointEventRemainTimeText(version)
    vars['timeLabel']:setString(str)

    -- 누적 결제 점수
    local purchase_point = g_purchasePointData:getPurchasePoint(version)
    local str = Str('누적 결제 점수') .. ' : ' .. Str('{1}점', comma_value(purchase_point))
    vars['scoreLabel']:setString(str)

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
end

-------------------------------------
-- function refresh_rewardUIList
-------------------------------------
function UI_EventPopupTab_PurchasePoint:refresh_rewardUIList()
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
function UI_EventPopupTab_PurchasePoint:refresh_rewardBoxUIList()
    if (not self.m_rewardBoxUIList) then
        return
    end

    local version = self.m_eventVersion

    for step,ui in pairs(self.m_rewardBoxUIList) do
        local vars = ui.vars
        local t_step, reward_state = g_purchasePointData:getPurchasePoint_rewardStepInfo(version, step)

        vars['checkSprite']:setVisible(false)
        vars['receiveVisual']:setVisible(false)
        vars['openSprite']:setVisible(false)
        vars['closeSprite']:setVisible(false)
        

        -- 획득 완료
        if (reward_state == 1) then
            vars['checkSprite']:setVisible(true)
            vars['openSprite']:setVisible(true)
    
        -- 획득 가능
        elseif (reward_state == 0) then
            vars['openSprite']:setVisible(true)
            vars['receiveVisual']:setVisible(true)

        -- 획득 불가
        --elseif (reward_state == -1) then
        else
            vars['closeSprite']:setVisible(true)
        end
    end
end


-------------------------------------
-- function click_helpBtn
-- @brief 도움말
-------------------------------------
function UI_EventPopupTab_PurchasePoint:click_helpBtn()
    UI_GuidePopup_PurchasePoint()
end

-------------------------------------
-- function click_receiveBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchasePoint:click_receiveBtn(reward_step)
    local version = self.m_eventVersion

    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)

        self:refresh()
        self:refresh_rewardUIList()
        self:refresh_rewardBoxUIList()
    end

    g_purchasePointData:request_purchasePointReward(version, reward_step, cb_func)
end

--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchasePoint)
