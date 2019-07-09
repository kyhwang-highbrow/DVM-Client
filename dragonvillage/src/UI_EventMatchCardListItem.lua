local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventMatchCardListItem
-------------------------------------
UI_EventMatchCardListItem = class(PARENT, {
        m_dataInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCardListItem:init(data_info)
    self.m_dataInfo = data_info
    local vars = self:load('event_match_card_exchange_item.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMatchCardListItem:initUI()
    local vars = self.vars
    local data_info = self.m_dataInfo
    local step = data_info['step']
    local price = data_info['price']

    -- 교환 갯수
    vars['numberLabel']:setString(Str('{1}개', comma_value(price)))

    -- 보상 정보
    local l_reward = seperate(data_info['reward'], ';')
    if (not l_reward) then
        return
    end
    
    local id = tonumber(l_reward[1])
    local cnt = tonumber(l_reward[2])

    local item_card = UI_ItemCard(id, cnt)
    vars['itemNode']:addChild(item_card.root)
    item_card.root:setSwallowTouch(false)

    -- 보상버튼
    vars['receiveBtn']:registerScriptTapHandler(function() 
        g_eventMatchCardData:request_productReward(step, function() self:refresh() end)
    end)

    vars['itemMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCardListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCardListItem:refresh()
    local vars = self.vars
    local data_info = self.m_dataInfo

    local step = data_info['step']
    local need_price = data_info['price']
    local curr_price = g_eventMatchCardData.m_cardGift

    -- 받은 보상인지
    local buy_cnt = g_eventMatchCardData:getBuyCnt(step)
    local max_buy_cnt = data_info['max_buy_cnt']
    local is_buy_all = (max_buy_cnt - buy_cnt == 0)
    local color_key = is_buy_all and '{@impossible}' or '{@available}'
    local str = Str('교환 가능 {1}/{2}', max_buy_cnt - buy_cnt, max_buy_cnt)
    local rich_str = color_key .. str
    vars['buyCountLabel']:setString(rich_str)

    -- 버튼 활성화
    local is_available_buy = buy_cnt < max_buy_cnt
    local condition = (curr_price >= need_price) and (is_available_buy) 
    vars['receiveBtn']:setEnabled(condition)
    vars['readySprite']:setVisible(not condition)
end
