local PARENT = UI

-------------------------------------
-- class UI_PurchasePointRewardReceivePopup
-------------------------------------
UI_PurchasePointRewardReceivePopup = class(PARENT,{
        m_eventVersion = '',
        m_eventLast_Step = 'number',
        m_rewardIdx = 'number',
        m_bReceived = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_PurchasePointRewardReceivePopup:init(event_version, reward_idx, last_step)
    self.m_eventVersion = event_version
    self.m_eventLast_Step = last_step
    self.m_rewardIdx = reward_idx
    self.m_bReceived = false

    local vars = self:load('event_purchase_point_popup_receive_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_PurchasePointRewardReceivePopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(event_version, reward_idx)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @breif
-------------------------------------
function UI_PurchasePointRewardReceivePopup:initUI(event_version, reward_idx)
    local vars = self.vars

    local version = event_version
    local step = self.m_eventLast_Step

    local item_id, item_count = self:getRewardInfoByStep(version, step, reward_idx)

    do -- 아이템 아이콘
        local ui_card = UI_ItemCard(item_id, item_count)
        vars['itemNode']:addChild(ui_card.root)
    end

    do -- 아이템 이름 (수량)
        local item_name = TableItem:getItemName(item_id)
        if (item_count <= 1) then
            vars['itemLabel']:setString(item_name)
        else
            local str =  Str('{1} {2}개', item_name, comma_value(item_count))
            vars['itemLabel']:setString(str)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PurchasePointRewardReceivePopup:initButton()
    local vars = self.vars
    vars['selectBtn']:registerScriptTapHandler(function() self:selectBtn() end)
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PurchasePointRewardReceivePopup:refresh()
end

-------------------------------------
-- function getRewardInfoByStep
-------------------------------------
function UI_PurchasePointRewardReceivePopup:getRewardInfoByStep(version, step, reward_idx)
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
-- function selectBtn
-------------------------------------
function UI_PurchasePointRewardReceivePopup:selectBtn()
    local version = self.m_eventVersion
    local reward_step = self.m_eventLast_Step
    local reward_idx = self.m_rewardIdx

    local function cb_func(ret)
        -- 보상 획득
        ItemObtainResult(ret)
        self.m_bReceived = true
        self:close()
    end

    g_purchasePointData:request_purchasePointReward(version, reward_step, reward_idx, cb_func)
end

--@CHECK
UI:checkCompileError(UI_PurchasePointRewardReceivePopup)
