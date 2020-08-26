local PARENT = UI

-------------------------------------
-- class UI_EventImageQuiz
-------------------------------------
UI_EventImageQuiz = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuiz:init()
    local vars = self:load('event_image_quiz.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuiz:initUI()
    local vars = self.vars
    local event_data = g_eventImageQuizData
    
    -- 이벤트 종료 시간
    vars['timeLabel']:setString(event_data:getEndTimeText())

    -- 모드별 입장권 획득 개수
    local ticket_info = event_data:getTicketInfo()
    if (ticket_info) then
        local total_ticket = 1 -- 하루에 한개는 충전되므로 1 default
        local max_total_ticket = 1
        for mode, data in pairs(ticket_info) do
            local curr_play = data['play'] or 0
            local max_play = data['max_play'] or 0

            vars[mode..'CntLabel']:setString(Str('({1}/{2})', curr_play, max_play))

            local curr_ticket = data['ticket'] or 0
            total_ticket = total_ticket + curr_ticket

            local max_ticket = data['max_ticket'] or 0
            max_total_ticket = max_total_ticket + max_ticket

            vars[mode..'TicketLabel']:setString(Str('(일일 최대 {1}/{2})', curr_ticket, max_ticket))
        end

        vars['totalTicketLabel']:setString(Str('(일일 최대 {1}/{2}개 획득 가능)', total_ticket, max_total_ticket))
    end

    -- 누적 플레이 보상과 누적 점수 보상 아이템
    require('UI_EventImageQuizListItem')
    self.m_eventDataUI = {}

    -- 누적 플레이 보상 정보
    local product_info_play = event_data:getProductInfo('play')
    for i, v in ipairs(product_info_play) do
        local ui = UI_EventImageQuizListItem_play(v)
        local node = vars['costumeNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_eventDataUI, ui)
        end
    end

    -- 누적 점수 보상 정보
    local product_info = event_data:getProductInfo('score')
    for i, v in ipairs(product_info) do
        local ui = UI_EventImageQuizListItem(v)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_eventDataUI, ui)
        end
    end

    -- 버튼 스크롤 처리
    vars['infoBtn']:getParent():setSwallowTouch(false)
    vars['startBtn']:getParent():setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuiz:initButton()
    local vars = self.vars

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuiz:refresh()
    local vars = self.vars

    local event_data = g_eventImageQuizData

    -- 현재 입장권 개수
    local ticket_cnt = event_data:getTicketCount()
    vars['numberLabel1']:setString(Str('{1}개', comma_value(ticket_cnt)))
    -- 입장 버튼 활성화/비활성화 처리
    vars['startBtn']:setEnabled(ticket_cnt > 0)

    -- 누적 플레이 횟수
    local play_cnt = event_data:getPlayCount()
    vars['numberLabel2']:setString(Str('{1}회', comma_value(play_cnt)))
    -- 누적 점수
    local score = event_data:getScore()
    vars['numberLabel3']:setString(comma_value(score))

    -- 누적 점수 보상 갱신
    local reward_info = event_data:getProductInfo('score')
    local reward_line = 5 -- 한줄에 표시되는 보상 갯수

    for i, info in ipairs(reward_info) do
        local need_cnt = info['price']
        if (score < need_cnt) then
            local pre_need = (i == 1) and 0 or reward_info[(i - 1)]['price']
            local need_cnt = need_cnt - pre_need
            local event_cnt = score - pre_need
            local div = 100 / reward_line
            local per = div * (i - 1) + (div * (event_cnt/need_cnt))
            
            if (i > reward_line) then
                per = per - 100
                per = math_min(per, 100)
                vars['timeGauge1']:setPercentage(100)
                vars['timeGauge2']:setPercentage(per)
            else
                per = math_min(per, 100)
                vars['timeGauge1']:setPercentage(per)
                vars['timeGauge2']:setPercentage(0)
            end
            break
        else
            vars['timeGauge1']:setPercentage(100)
            vars['timeGauge2']:setPercentage(100)
        end
    end

    for i, ui in ipairs(self.m_eventDataUI) do
        ui:refresh()
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventImageQuiz:click_infoBtn()
    local ui = UI()
    local vars = ui:load('event_image_quiz_info_popup.ui')
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_EventImageQuizInfoPopup (FakeUI)')
    vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_EventImageQuiz:click_startBtn()
    g_eventImageQuizData:request_eventImageQuizStart(function()
        require('UI_EventImageQuizIngame')
        local ui = UI_EventImageQuizIngame()
        ui:setCloseCB(function() self:refresh() end)
    end)
end