local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_EventImageQuizListItem
-------------------------------------
UI_EventImageQuizListItem = class(PARENT, {
        m_dataInfo = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuizListItem:init(data_info)
    self.m_dataInfo = data_info
    local vars = self:load('event_image_quiz_item_02.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuizListItem:initUI()
    local vars = self.vars
    local data_info = self.m_dataInfo
    local step = data_info['step']
    local price = data_info['price']

    -- 교환 갯수
    vars['numberLabel']:setString(Str('{1}회', comma_value(price)))

    -- 보상 정보
    local l_reward = g_itemData:parsePackageItemStr(data_info['reward'])
    for i, v in ipairs(l_reward) do
        local id = v['item_id']
        local cnt = v['count']

        local item_card = UI_ItemCard(id, cnt)
        vars['itemNode']:addChild(item_card.root)
        item_card.root:setSwallowTouch(false)
    end

    -- 보상버튼
    vars['receiveBtn']:registerScriptTapHandler(function() 
        g_eventImageQuizData:request_clearReward(step, 'score', function() self:refresh() end)
    end)

    vars['itemMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuizListItem:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuizListItem:refresh()
    local vars = self.vars
    local data_info = self.m_dataInfo

    local step = data_info['step']
    local need_cnt = data_info['price']
    local curr_play_cnt = g_eventImageQuizData:getPlayCount()
    
    -- 받은 보상인지
    local is_get = g_eventImageQuizData:isGetReward(step, 'score')
    vars['checkSprite']:setVisible(is_get)
    
    -- 버튼 활성화
    local condition = (curr_play_cnt >= need_cnt) and (not is_get) 
    vars['receiveBtn']:setEnabled(condition)
    vars['readySprite']:setVisible(not condition)
end