local PARENT = class(UI, ITabUI:getCloneTable())
-------------------------------------
-- class UI_EventDealkingTab
-------------------------------------
UI_EventDealkingTab = class(PARENT,{
    m_bossType = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventDealkingTab:init(boss_type)
    self.m_bossType = boss_type
    self:load(string.format('event_dealking_%d_tab.ui', boss_type))
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingTab:initUI()
    local vars = self.vars
    local boss_name = g_eventDealkingData:getEventBossName(self.m_bossType)
    vars['bossNameLabel']:setString(boss_name)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventDealkingTab:initButton()
    local vars = self.vars

    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn(self.m_bossType) end)
    vars['rankTotalBtn']:registerScriptTapHandler(function() self:click_rankBtn(0) end)


    vars['buyBtn1']:registerScriptTapHandler(function() self:click_attrBtn('light') end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_attrBtn('fire') end)
    vars['buyBtn3']:registerScriptTapHandler(function() self:click_attrBtn('water') end)
    vars['buyBtn4']:registerScriptTapHandler(function() self:click_attrBtn('earth') end)
    vars['buyBtn5']:registerScriptTapHandler(function() self:click_attrBtn('dark') end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventDealkingTab:onEnterTab(is_first)
    local vars = self.vars
    if (is_first == true) then
        self:initUI()
        self:initButton()
        self:refresh()

        self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
    end
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventDealkingTab:onExitTab()
    local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventDealkingTab:refresh()
    local vars = self.vars

    -- 현재 서버 데이터를 이용하여 버튼 설정
    self:refreshButton('total', vars['rankLabel'], vars['scoreLabel'], nil)
    self:refreshButton('light', vars['rankLabel1'], vars['scoreLabel1'], vars['lockMenu1'])
    self:refreshButton('fire', vars['rankLabel2'], vars['scoreLabel2'], vars['lockMenu2'])
    self:refreshButton('water', vars['rankLabel3'], vars['scoreLabel3'], vars['lockMenu3'])
    self:refreshButton('earth', vars['rankLabel4'], vars['scoreLabel4'], vars['lockMenu4'])
    self:refreshButton('dark', vars['rankLabel5'], vars['scoreLabel5'], vars['lockMenu5'])

    AlignUIPos({vars['infoLabel'], vars['rankLabel'], vars['scoreLabel']}, 'HORIZONTAL', 'CENTER', 60)
end

-------------------------------------
-- function refreshButton
-- @param attr : 속성값으로 해당 값으로 점수와 랭크 받음
-- @param rank_label : UI 파일에서 랭크를 적을 라벨
-- @param score_label : UI 파일에서 점수를 적을 라벨
-- @param lock_menu : 해당 속성 잠금 자물쇠 스프라이트, 없는 경우(total) nil로 설정
-------------------------------------
function UI_EventDealkingTab:refreshButton(attr, rank_label, score_label, lock_menu)
    local vars = self.vars

    -- 현재 서버 데이터를 이용하여 순위 정보 표기
    local rank = g_eventDealkingData:getMyRank(attr)
    local score = g_eventDealkingData:getMyScore(attr)
    
	-- 내 랭킹이 0보다 작으면 {-위} 로 노출
    -- 0보다 큰 의미있는 값이면 그대로 노출
    if (rank < 0) then
        rank_label:setString(Str('순위 없음'))
    else
        local ratio = g_eventDealkingData:getMyRate(attr)
        local percent_text = string.format('%.2f', ratio * 100)
        rank_label:setString(Str('{1}위 ({2}%)', comma_value(rank), percent_text))
    end
	
    -- 점수
    if (score < 0) then
        score_label:setString(Str('{1}점', 0))
    else
        score_label:setString(Str('{1}점', comma_value(score)))
    end

    -- 버튼 설정
    if (attr ~= 'total') then
        if (g_eventDealkingData:isOpenAttr(attr)) then
            if (lock_menu ~= nil) then
                lock_menu:setVisible(false)
            end
        else
            if (lock_menu ~= nil) then
                lock_menu:setVisible(true)
            end
        end
    end
end


----------------------------------------------------------------------
-- function update
----------------------------------------------------------------------
function UI_EventDealkingTab:update(dt)
    local vars = self.vars
    local str = g_eventDealkingData:getRemainTimeString()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_EventDealkingTab:click_eventBtn()
    local vars = self.vars
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventDealkingTab:click_rankBtn(boss_type)
    local vars = self.vars
    local ui = UI_EventDealkingRankingPopup(boss_type)
end

-------------------------------------
-- function click_attrBtn
-- @brief 각 속성의 화신 버튼 클릭에 대한 콜백 함수
-- @param attr : 속성 (string)
-------------------------------------
function UI_EventDealkingTab:click_attrBtn(attr)
    local vars = self.vars
    local ui = UI_EventDealkingEntryPopup(attr, self.m_bossType)
end