local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchasePoint
-------------------------------------
UI_EventPopupTab_PurchasePoint = class(PARENT,{
        m_eventVersion = '',
        m_rewardUIList = '',
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
    for step=1, step_count do
        local parent_node = vars['rewardNode' .. step]
        if parent_node then
            local ui = UI_PurchasePointListItem(version, step)
            parent_node:addChild(ui.root)
            ui.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
            table.insert(self.m_rewardUIList, ui)
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
    local last_step_point = g_purchasePointData:getPurchasePoint_lastStepPoint(version)
    local percentage = math_clamp((purchase_point / last_step_point) * 100, 0, 100)
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
    end

    g_purchasePointData:request_purchasePointReward(version, reward_step, cb_func)
end

--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchasePoint)
