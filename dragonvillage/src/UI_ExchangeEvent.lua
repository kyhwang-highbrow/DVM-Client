local PARENT = UI

-------------------------------------
-- class UI_ExchangeEvent
-------------------------------------
UI_ExchangeEvent = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ExchangeEvent:init()
    local vars = self:load('event_chuseok.ui')

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

    -- 누적보상 리스트
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

    -- 소모량
    local use_cnt = g_exchangeEventData.m_nMaterialUse
    vars['numberLabel2']:setString(Str('{1}개', comma_value(use_cnt)))

    -- 교환 버튼
    local need_exchange = 500
    vars['boxLabel']:setString(Str('{1}개', comma_value(need_exchange)))
    vars['boxBtn']:setEnabled(cur_cnt >= need_exchange)

    -- 누적보상
    local reward_info = g_exchangeEventData.m_productInfo
    for i, info in ipairs(reward_info) do
        local cur_need = info['price']
        if (use_cnt < cur_need) then
            local pre_need = (i == 1) and 0 or reward_info[(i - 1)]['price']
            local need_cnt = cur_need - pre_need
            local event_cnt = use_cnt - pre_need
            local div = 100/#reward_info
            local per = div * (i - 1) + (div * (event_cnt/(need_cnt)))
            per = math_min(per, 100)
            vars['timeGauge']:setPercentage(per)
            break
        end
    end

    for i, ui in ipairs(self.m_eventDataUI) do
        ui:refresh()
    end
end

-------------------------------------
-- function click_infoBtn
-- @brief 획득 방법
-------------------------------------
function UI_ExchangeEvent:click_infoBtn()
    local ui = UI()
    ui:load('event_chuseok_info_popup.ui')
    ui.vars['closeBtn']:registerScriptTapHandler(function() ui:close() end)
    UIManager:open(ui, UIManager.POPUP)
end

-------------------------------------
-- function click_boxBtn
-- @brief 교환
-------------------------------------
function UI_ExchangeEvent:click_boxBtn()
    local function finish_cb()
        self:refresh()
    end

    g_exchangeEventData:request_eventUse(finish_cb)
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_ExchangeEvent:onEnterTab()
    local vars = self.vars
end