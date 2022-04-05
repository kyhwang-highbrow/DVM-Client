local PARENT = UI

-------------------------------------
-- class UI_EventGoldDungeon
-------------------------------------
UI_EventGoldDungeon = class(PARENT,{
        m_eventDataUI = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventGoldDungeon:init()
    local vars = self:load('event_gold_dungeon.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventGoldDungeon:initUI()
    local vars = self.vars
    local event_data = g_eventGoldDungeonData
    
    -- 이벤트 종료 시간
    vars['timeLabel']:setString(event_data:getStatusText())

    -- 현재 입장권 개수
    local stamina_cnt = event_data:getStaminaCount()
    vars['numberLabel1']:setString(Str('{1}개', comma_value(stamina_cnt)))

    -- 필요 입장권 개수
    vars['staminaLabel']:setString('1')

    -- 모드별 입장권 획득 개수
    local stamina_info = event_data:getStaminaInfo()
    if (stamina_info) then
        local total_ticket = 1 -- 하루에 한개는 충전되므로 1 default
        local max_total_ticket = 1
        for mode, data in pairs(stamina_info) do
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

    -- 누적 플레이 횟수
    local play_cnt = event_data:getPlayCount()
    vars['numberLabel2']:setString(Str('{1}회', comma_value(play_cnt)))

    -- 누적 보상 정보
    local product_info = event_data:getProductInfo()
    table.sort(product_info, function(a, b)
        return tonumber(a['step']) < tonumber(b['step'])
    end)

    self.m_eventDataUI = {}
    for i, v in ipairs(product_info) do
        local ui = UI_EventGoldDungeonListItem(v)
        local node = vars['itemNode'..i]
        if node then
            node:removeAllChildren()
            node:addChild(ui.root)
            table.insert(self.m_eventDataUI, ui)
        end
    end

    -- 입장 버튼 활성화/비활성화 처리
    local stamina_cnt = event_data:getStaminaCount()
    vars['dungeonBtn']:setEnabled(stamina_cnt > 0)

    vars['upMenu']:setSwallowTouch(false)
    vars['downMenu']:setSwallowTouch(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventGoldDungeon:initButton()
    local vars = self.vars
    vars['dungeonBtn']:registerScriptTapHandler(function() self:click_dungeonBtn() end)
    vars['dungeonInfoBtn']:registerScriptTapHandler(function() self:click_dungeonInfoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventGoldDungeon:refresh()
    local vars = self.vars
    local event_data = g_eventGoldDungeonData

    -- 누적 보상 갱신
    local play_cnt = event_data:getPlayCount()
    local reward_info = event_data:getProductInfo()
    local reward_line = 6 -- 한줄에 표시되는 보상 갯수

    for i, info in ipairs(reward_info) do
        local need_cnt = info['price']
        if (play_cnt < need_cnt) then
            local pre_need = (i == 1) and 0 or reward_info[(i - 1)]['price']
            local need_cnt = need_cnt - pre_need
            local event_cnt = play_cnt - pre_need
            local div = 100/reward_line
            local per = div * (i - 1) + (div * (event_cnt/(need_cnt)))
            
            if (i > reward_line) then
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

    vars['goldTotalLabel']:setString(event_data:getTotalGold())
end

-------------------------------------
-- function click_dungeonBtn
-- @brief 던전 입장
-------------------------------------
function UI_EventGoldDungeon:click_dungeonBtn()
    UI_ReadySceneNew(EVENT_GOLD_STAGE_ID)


    -- 전투 준비 화면에서 1일 1회 황금 던전 설명 팝업 띄움
    local save_key = 'event_gold_dungeon'
    local is_view = g_settingData:get('event_full_popup', save_key) or false
    if (is_view == true) then
        return
    end

    local function cb_func()
        g_settingData:applySettingData(true, 'event_full_popup', save_key)
    end

    local ui = UI_EventGoldDungeonPopup()
    ui:setCloseCB(cb_func)
end

-------------------------------------
-- function click_dungeonInfoBtn
-- @brief 황금 던전 설명 팝업
-------------------------------------
function UI_EventGoldDungeon:click_dungeonInfoBtn()
    UI_EventGoldDungeonPopup()
end
