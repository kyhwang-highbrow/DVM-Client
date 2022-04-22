local PARENT = UI

-------------------------------------
-- class UI_ExchangeEvent
-------------------------------------
UI_ExchangeEvent = class(PARENT,{
        m_eventDataUI = 'list',
    })

local NEED_EXCHANGE = 300

-------------------------------------
-- function init
-------------------------------------
function UI_ExchangeEvent:init()
    local vars = self:load('event_exchange.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ExchangeEvent:initUI()
    local vars = self.vars
    self.m_eventDataUI = {}

    -- 이벤트 종료 시간
    vars['timeLabel']:setString(g_exchangeEventData:getStatusText())

    -- 누적 보상 정보
    local product_info = g_exchangeEventData.m_productInfo
    table.sort(product_info, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)

    for i, v in ipairs(product_info) do
        local ui = UI_ExchangeEventListItem(v)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_eventDataUI, ui)
        end
    end

    for i = 1, 3 do
        local event_item_icon_res = TableItem:getItemIcon(ITEM_ID_EVENT)
        local event_item_icon = IconHelper:getIcon(event_item_icon_res)
        vars['exchangeItemNode' .. i]:addChild(event_item_icon)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ExchangeEvent:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['boxBtn']:registerScriptTapHandler(function() self:click_boxBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ExchangeEvent:refresh()
    local vars = self.vars

    -- 획득량
    local cur_cnt = g_exchangeEventData.m_nMaterialCnt
    vars['numberLabel1']:setString(Str('{1}개', comma_value(cur_cnt)))

    -- 일일 획득량
    local max_cnt = g_exchangeEventData.m_nMaterialMax
    local today_cnt = g_exchangeEventData.m_nMaterialGet
    vars['obtainLabel']:setString(Str('일일 최대 {1}/{2}개 획득 가능', comma_value(today_cnt), comma_value(max_cnt)))

    -- 소모량
    local use_cnt = g_exchangeEventData.m_nMaterialUse
    vars['numberLabel2']:setString(Str('{1}개', comma_value(use_cnt)))
    
    -- 교환 버튼
    vars['boxLabel']:setString(Str('{1}개', comma_value(NEED_EXCHANGE)))

    -- 누적 보상 갱신
    local reward_info = g_exchangeEventData.m_productInfo

    local reward_line = 6 -- 한줄에 표시되는 보상 갯수
    local gauge_line = (#reward_info > reward_line) and 2 or 1 -- 누적 게이지 한줄, 두줄

    for i, info in ipairs(reward_info) do
        local cur_need = info['price']
        if (use_cnt < cur_need) then
            local pre_need = (i == 1) and 0 or reward_info[(i - 1)]['price']
            local need_cnt = cur_need - pre_need
            local event_cnt = use_cnt - pre_need
            local div = 100/reward_line
            local per = div * (i - 1) + (div * (event_cnt/(need_cnt)))
            
            if (gauge_line >= 2 and i > reward_line) then
                per = per - 100
                per = math_min(per, 100)
                vars['timeGauge']:setPercentage(100)
                vars['timeGauge2']:setPercentage(per)
            else
                per = math_min(per, 100)
                vars['timeGauge']:setPercentage(per)
                vars['timeGauge2']:setPercentage(0)
            end
            break
        else
            vars['timeGauge']:setPercentage(100)
            vars['timeGauge2']:setPercentage(100)
        end
    end

    for i, ui in ipairs(self.m_eventDataUI) do
        ui:refresh()
    end

    -- 선물 상자 갱신
    local randombox_info = g_exchangeEventData.m_randomBoxInfo

    for i, info in ipairs(randombox_info) do
        local item_id = info['item_id']
        local cnt = info['val']
        local icon = IconHelper:getItemIcon(item_id)

        vars['rewardNode' .. i]:addChild(icon)
        vars['rewardLabel' .. i]:setString(comma_value(cnt))
    end

    
end

-------------------------------------
-- function click_infoBtn
-- @brief 획득 방법
-------------------------------------
function UI_ExchangeEvent:click_infoBtn()
    local ui = UI()
    ui:load('event_exchange_info_popup.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'event_chuseok_info_popup')
    UIManager:open(ui, UIManager.POPUP)
end

-------------------------------------
-- function click_boxBtn
-- @brief 교환
-------------------------------------
function UI_ExchangeEvent:click_boxBtn()
    local curr_cnt = g_exchangeEventData.m_nMaterialCnt
    if (curr_cnt < NEED_EXCHANGE) then
        UIManager:toastNotificationRed(Str('이벤트 아이템이 부족합니다.'))
        return
    end

    local function finish_cb()
        self:refresh()
    end

    g_exchangeEventData:request_eventUse(finish_cb)
end