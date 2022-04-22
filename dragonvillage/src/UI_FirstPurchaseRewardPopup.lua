local PARENT = UI

-------------------------------------
-- class UI_FirstPurchaseRewardPopup
-- @brief 깜짝 할인 상품 팝업
-------------------------------------
UI_FirstPurchaseRewardPopup = class(PARENT,{
        m_eventId = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_FirstPurchaseRewardPopup:init(event_id)
    self.m_eventId = event_id

    self.m_uiName = 'UI_FirstPurchaseRewardPopup'
    
    local ui_res = self:getDataByKey('popup_ui') or 'event_first_purchase_newbie.ui'
    local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_FirstPurchaseRewardPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_FirstPurchaseRewardPopup:initUI()
    local vars = self.vars

    -- 보상 아이콘 출력
    local reward_str = self:getDataByKey('reward') or ''
    local reward_item_list = ServerData_Item:parsePackageItemStr(reward_str)

    for i,v in ipairs(reward_item_list) do
        local luaname = string.format('itemNode%.2d', i)
        local node = vars[luaname]
        if node then
            local card = UI_ItemCard(v['item_id'], v['count'])
            card.root:setSwallowTouch(false)
            node:addChild(card.root)        

            do -- 드래곤이면
                local item_id = v['item_id']
                local did = tonumber(TableItem:getDidByItemId(item_id))
                if did and (0 < did) then
                    card.vars['clickBtn']:registerScriptTapHandler(function() UI_BookDetailPopup.openWithFrame(did, nil, 3, 0.8, true) end)
                end
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_FirstPurchaseRewardPopup:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['shopBtn'] then
        vars['shopBtn']:registerScriptTapHandler(function() self:click_shopBtn() end)
    end

    if vars['rewardBtn'] then
        vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_FirstPurchaseRewardPopup:refresh()
    local vars = self.vars
    local status = self:getDataByKey('status') -- -1, 0, 1

    
    vars['shopBtn']:setVisible(status == -1)
    vars['rewardBtn']:setVisible(status == 0)
    vars['completeNode']:setVisible(status == 1)
end

-------------------------------------
-- function update
-------------------------------------
function UI_FirstPurchaseRewardPopup:update(dt)
    local vars = self.vars

    local end_date = (self:getDataByKey('end_date') or 0) / 1000 -- timestamp 1585839600000
    local curr_time = Timer:getServerTime()

    -- 1. 남은 시간 표시 (기간제일 경우에만)
    local time_label = vars['timeLabel']
    if time_label then
        if (0 < end_date) and (curr_time < end_date) then
            --local time_millisec = (end_date - curr_time) * 1000
            --local str = datetime.makeTimeDesc_timer(time_millisec)
            local time = (end_date - curr_time)
            local str = Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function click_shopBtn
-------------------------------------
function UI_FirstPurchaseRewardPopup:click_shopBtn()
    self:close()

    -- 초보자 선물 상점이 활성화일 경우
    local ui = g_newcomerShop:openNewcomerShop()
    if (ui ~= nil) then
        return
    end

    g_shopData:openShopPopup()
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_FirstPurchaseRewardPopup:click_rewardBtn()
    local event_id = tonumber(self.m_eventId)

    local function finish_cb(ret)
        self:refresh()
        g_serverData:confirm_reward(ret)
    end

    local function fail_cb(ret)

    end

    g_firstPurchaseEventData:request_firstPurchaseRewardInfo(event_id, finish_cb, fail_cb)
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_FirstPurchaseRewardPopup:click_contractBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function getDataByKey
-------------------------------------
function UI_FirstPurchaseRewardPopup:getDataByKey(key)
    if (self.m_eventId == nil) then
        return nil
    end

    local t_info = g_firstPurchaseEventData:getFirstPurchaseEventInfoByEventId(self.m_eventId)
    -- "10102":{
    --   "popup_ui":"event_first_purchase_newbie.ui",
    --   "t_name":"첫 충전 선물",
    --   "end_date":1586790000000,
    --   "status":-1,
    --   "btn_ui":"button_first_purchase_reward.ui",
    --   "start_date":1585839600000,
    --   "reward":"770405;1,700001;2000"
    -- }
    if (not t_info) then
        return nil
    end

    return t_info[key]
end

--@CHECK
UI:checkCompileError(UI_FirstPurchaseRewardPopup)
