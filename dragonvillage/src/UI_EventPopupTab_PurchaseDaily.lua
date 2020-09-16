local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_PurchaseDaily
-------------------------------------
UI_EventPopupTab_PurchaseDaily = class(PARENT,{
        m_eventVersion = '',
        
        m_rewardBoxUIList = '',

        m_todayRewardUI = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:init(event_version)
    self.m_eventVersion = event_version
    self:load('event_purchase_daily.ui')

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
function UI_EventPopupTab_PurchaseDaily:initUI()
    local vars = self.vars

    local version = self.m_eventVersion
    local step_count = g_purchaseDailyData:getTotalStep(version)

    self.m_rewardBoxUIList = {}
    
    -- 보상 아이템 카드
    for step = 1, step_count do
        local item_node = vars['itemNode'..step]
        if item_node then
            item_node:setVisible(true)
            
            -- 선물 박스 프레임
            local ui_frame = UI()
            ui_frame:load('event_purchase_daily_item_01.ui')
            ui_frame.vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn(step) end)
            ui_frame.vars['dayLabel']:setString(g_purchaseDailyData.LocalizedOrdinalDay(step))
            item_node:addChild(ui_frame.root)
            
            table.insert(self.m_rewardBoxUIList, ui_frame)
        end
    end

    -- 보상 점수
    local point = g_purchaseDailyData:getPurchasePoint()
    vars['scoreLabel']:setString(comma_value(point))

    -- 현재 스텝의 보상 초기화
    local curr_reward_node = vars['listNode']
    if (curr_reward_node) then
        local ui_today_reward = UI()
        ui_today_reward:load('event_purchase_daily_item_02.ui')
        ui_today_reward.vars['shopBtn']:registerScriptTapHandler(function() UINavigator:goTo('package_shop') end)
        
        self.m_todayRewardUI = ui_today_reward
        
        curr_reward_node:addChild(ui_today_reward.root)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() UI_GuidePopup_PurchasePoint('event_purchase_daily_popup.ui') end) 
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:onEnterTab()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refresh()
    local vars = self.vars
    local version = self.m_eventVersion

    -- 누적 결제 점수
    local purchase_point = g_purchaseDailyData:getPurchasePoint(version)
    local str = Str('누적 결제 점수: {1}점', comma_value(purchase_point))
    vars['scoreLabel']:setString(str)

    -- 누적 결제 남은 시간 안내
    local time_str = g_purchaseDailyData:getPurchasePointEventRemainTimeText(version)
    vars['timeLabel']:setString(time_str)

    self:refreshCurrentStepReward()
    self:refresh_rewardBoxUIList()
end

-------------------------------------
-- function refreshCurrentStepReward
-- @breif 현재 스텝의 상세 보상 정보 출력
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refreshCurrentStepReward()
    if (not self.m_todayRewardUI) then
        return
    end

    -- 현재 스텝의 상세 보상 정보
    local curr_step = g_purchaseDailyData:getCurrentStep(self.m_eventVersion)
    local reward_list = g_purchaseDailyData:getRewardList(self.m_eventVersion, curr_step)
    for i, t_item in ipairs(reward_list) do
        -- 아이템 카드
        local ui_card = UI_ItemCard(t_item['item_id'], t_item['count'])
        ui_card.root:setScale(0.7)
        self.m_todayRewardUI.vars['rewardNode' .. i]:removeAllChildren(true)
        self.m_todayRewardUI.vars['rewardNode' .. i]:addChild(ui_card.root)
    end
end

-------------------------------------
-- function refresh_rewardBoxUIList
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:refresh_rewardBoxUIList()
    if (not self.m_rewardBoxUIList) then
        return
    end

    local curr_step = g_purchaseDailyData:getCurrentStep(self.m_eventVersion)
    local clear_step = g_purchaseDailyData:getClearStep(self.m_eventVersion)

    for step, ui in pairs(self.m_rewardBoxUIList) do
        local vars = ui.vars

        -- 획득 완료
        if (g_purchaseDailyData:isRewardReceived(self.m_eventVersion, step)) then
            vars['checkSprite']:setVisible(true)
            vars['receiveBtn']:setVisible(false)
            vars['todaySprite']:setVisible(false)
            vars['boxVisual']:changeAni('box_0' .. step .. '_reward_after', true)

        -- 획득 가능한 상태
        else
            vars['checkSprite']:setVisible(false)
            vars['todaySprite']:setVisible(step == curr_step)

            -- 클리어 하여 보상 수령 가능
            if (clear_step >= step) then
                vars['boxVisual']:changeAni('box_0' .. step .. '_move', true)
                vars['receiveBtn']:setVisible(true)

            -- 클리어 하지 못함
            else
                vars['boxVisual']:changeAni('box_0' .. step, true)
                vars['receiveBtn']:setVisible(false)
            end
        end
    end
end

-------------------------------------
-- function click_receiveBtn
-- @brief
-------------------------------------
function UI_EventPopupTab_PurchaseDaily:click_receiveBtn(reward_step)
    local version = self.m_eventVersion

    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)

        self:refresh()
    end

    g_purchaseDailyData:request_purchasePointReward(version, reward_step, cb_func)
end

--@CHECK
UI:checkCompileError(UI_EventPopupTab_PurchaseDaily)
