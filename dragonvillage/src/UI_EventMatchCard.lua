local PARENT = UI

-------------------------------------
-- class UI_EventMatchCard
-------------------------------------
UI_EventMatchCard = class(PARENT,{
        m_accessTimeDataUI = '',
        m_productDataUI = '',
        m_lastAccessTime = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventMatchCard:init()
    local vars = self:load('event_match_card.ui')

    self.m_uiName = 'UI_EventMatchCard'

    self:initUI()
    self:initButton()
    self:refresh()

    self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMatchCard:initUI()
    local vars = self.vars

    -- 남은 시간 
    vars['limitTimeLabel']:setString(g_eventMatchCardData:getStatusText())

    -- @dhkim 2023.01.09 마지막 접속시간 초기화
    self.m_lastAccessTime = g_accessTimeData:getTime(true)

    -- 접속 보상 정보
    local access_time_info = g_eventMatchCardData.m_accessTimeInfo
    table.sort(access_time_info, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)
 
    -- 접속시간 이벤트 보상 리스트
    self.m_accessTimeDataUI = {}
    for i, v in ipairs(access_time_info) do
        local ui = UI_EventMatchCardTimeListItem(v)
        local node = vars['timeNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_accessTimeDataUI, ui)
        end
    end

    -- 누적 보상 정보
    self.m_productDataUI = {}
    local product_info = g_eventMatchCardData.m_productInfo
    table.sort(product_info, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)

    for i, v in ipairs(product_info) do
        local ui = UI_EventMatchCardListItem(v)
        local node = vars['exchangeNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_productDataUI, ui)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventMatchCard:initButton()
    local vars = self.vars
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventMatchCard:refresh()

end

-------------------------------------
-- function update
-------------------------------------
function UI_EventMatchCard:update(dt)
    local vars = self.vars
    local play_second = g_accessTimeData:getTime()
    
    -- 오늘 접속 시간
    if (play_second >= (60 * 60)) then
        vars['timeLabel']:setString(Str('완료'))
    else
        local is_minute = true
        local play_min = g_accessTimeData:getTime(is_minute)
        vars['timeLabel']:setString(Str('{1}분', play_min))

        if (self.m_lastAccessTime ~= play_min) then
            -- @dhkim 2023.01.09 분이 바뀔 때 마다 리퀘스트
            self.m_lastAccessTime = play_min

            -- @dhkim 2023.01.09 접속 종료할 시 로컬에서 계산하던 게임 접속시간을 서버로 전달.
            --                    이를 통해 접속시간 관련 이벤트에서 로비에 입장하지 않고 바로 끄면 접속시간이 갱신이 안되는 문제 해결
            g_accessTimeData:request_saveTime()
            -- cclog('request_saveTime')
        end
    end

    -- 접속시간 이벤트 보상 리스트 갱신
    for i, ui in ipairs(self.m_accessTimeDataUI) do
        ui:refresh()
    end

    -- 보상 리스트 갱신
    for i, ui in ipairs(self.m_productDataUI) do
        ui:refresh()
    end

    local ticket = g_eventMatchCardData.m_ticket or 0
    vars['number1']:setString(Str('보유 이용권 : {1}개', comma_value(ticket)))

    local card_gift = g_eventMatchCardData.m_cardGift or 0
    vars['number2']:setString(Str('보유 카드 : {1}개', comma_value(card_gift)))

    -- 게임 시작 버튼 활성화 / 비활성화
    local ticket = g_eventMatchCardData.m_ticket or 0
    vars['startBtn']:setEnabled(ticket > 0)
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_EventMatchCard:click_startBtn()
    local play_func = function()
        UI_EventMatchCardPlay()
    end
    g_eventMatchCardData:request_playStart(play_func)
end

--@CHECK
UI:checkCompileError(UI_EventMatchCard)
