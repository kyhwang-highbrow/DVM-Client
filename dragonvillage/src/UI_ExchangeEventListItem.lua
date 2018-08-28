local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ExchangeEventListItem
-------------------------------------
UI_ExchangeEventListItem = class(PARENT, {
        m_dataInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExchangeEventListItem:init(data_info)
    self.m_dataInfo = data_info
    local vars = self:load('event_exchange_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExchangeEventListItem:initUI()
    local vars = self.vars
    local data_info = self.m_dataInfo
    local step = data_info['step']
    local price = data_info['price']

    -- 교환 갯수
    vars['numberLabel']:setString(Str('{1}개', comma_value(price)))

    -- 보상 정보
    local l_reward = g_itemData:parsePackageItemStr(data_info['reward'])
    for i, v in ipairs(l_reward) do
        local id = v['item_id']
        local cnt = v['count']

        local item_card = UI_ItemCard(id, cnt)
        vars['itemNode'..i]:addChild(item_card.root)
        item_card.root:setSwallowTouch(false)
    end

    -- 보상버튼
    vars['receiveBtn']:registerScriptTapHandler(function() 
        g_exchangeEventData:request_eventReward(step, function() self:refresh() end)
    end)

    vars['itemMenu']:setSwallowTouch(false)

    -- 1주년 스페셜 (케이크)
    if (step == 12) then
        vars['1stAnniversarySprite']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExchangeEventListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExchangeEventListItem:refresh()
    local vars = self.vars
    local data_info = self.m_dataInfo

    local step = data_info['step']
    local need_price = data_info['price']
    local curr_price = g_exchangeEventData.m_nMaterialUse

    -- 받은 보상인지
    local is_get = g_exchangeEventData:isGetReward(step)
    vars['checkSprite']:setVisible(is_get)
    
    -- 버튼 활성화
    local condition = (curr_price >= need_price) and (not is_get) 
    vars['receiveBtn']:setEnabled(condition)
    vars['readySprite']:setVisible(not condition)
end
