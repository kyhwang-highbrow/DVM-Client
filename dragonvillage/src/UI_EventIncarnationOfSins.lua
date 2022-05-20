local PARENT = UI

-------------------------------------
-- class UI_EventIncarnationOfSins
-------------------------------------
UI_EventIncarnationOfSins = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSins:init()
    local vars = self:load('event_incarnation_of_sins.ui')
    
    self:initUI()
    self:initButton()
    self:refresh()

    local event_type = 'event_newserver'
    
    if not g_eventIncarnationOfSinsData.m_isOpened then
        g_fullPopupManager:showFullPopup(event_type)
        g_eventIncarnationOfSinsData.m_isOpened = true
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSins:initUI()
    local vars = self.vars

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)

    local noti = g_eventIncarnationOfSinsData:getRankNoti()
    vars['notiSprite']:setVisible(noti)

    vars['dayLabel1']:setString(g_eventIncarnationOfSinsData:getOpenAttrStr('light'))
    vars['dayLabel2']:setString(g_eventIncarnationOfSinsData:getOpenAttrStr('fire'))
    vars['dayLabel3']:setString(g_eventIncarnationOfSinsData:getOpenAttrStr('water'))
    vars['dayLabel4']:setString(g_eventIncarnationOfSinsData:getOpenAttrStr('earth'))
    vars['dayLabel5']:setString(g_eventIncarnationOfSinsData:getOpenAttrStr('dark'))
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSins:initButton()
    local vars = self.vars

    vars['eventBtn']:registerScriptTapHandler(function() self:click_eventBtn() end)
    vars['rankBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)

    vars['buyBtn1']:registerScriptTapHandler(function() self:click_attrBtn('light') end)
    vars['buyBtn2']:registerScriptTapHandler(function() self:click_attrBtn('fire') end)
    vars['buyBtn3']:registerScriptTapHandler(function() self:click_attrBtn('water') end)
    vars['buyBtn4']:registerScriptTapHandler(function() self:click_attrBtn('earth') end)
    vars['buyBtn5']:registerScriptTapHandler(function() self:click_attrBtn('dark') end)
    vars['bannerBtn']:registerScriptTapHandler(function() self:click_bannerBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSins:refresh()
    local vars = self.vars

    local noti = g_eventIncarnationOfSinsData:getRankNoti()
    vars['notiSprite']:setVisible(noti)

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
function UI_EventIncarnationOfSins:refreshButton(attr, rank_label, score_label, lock_menu)
    local vars = self.vars

    -- 글로벌 서버의 경우 예외 처리
    if g_localData:isGlobalServer() and (attr == 'total') then
        attr = 'max'
    end

    
    -- 현재 서버 데이터를 이용하여 순위 정보 표기
    local rank = g_eventIncarnationOfSinsData:getMyRank(attr)
    local score = g_eventIncarnationOfSinsData:getMyScore(attr)
    
	-- 내 랭킹이 0보다 작으면 {-위} 로 노출
    -- 0보다 큰 의미있는 값이면 그대로 노출
    if (rank < 0) then
        rank_label:setString(Str('순위 없음'))
    else
        local ratio = g_eventIncarnationOfSinsData:getMyRate(attr)
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
    if (attr ~= 'total') and (attr ~= 'max') then
        if (g_eventIncarnationOfSinsData:isOpenAttr(attr)) then
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

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventIncarnationOfSins:onEnterTab()
    local vars = self.vars
end

----------------------------------------------------------------------
-- function updateTimer
----------------------------------------------------------------------
function UI_EventIncarnationOfSins:updateTimer(dt)
    local vars = self.vars

    local str = g_eventIncarnationOfSinsData:getTimeText()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_eventBtn()
    local vars = self.vars

    local event_type = 'event_incarnation_of_sins_popup'
    g_fullPopupManager:showFullPopup(event_type)
end

-------------------------------------
-- function click_bannerBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_bannerBtn()
    local vars = self.vars

    local event_type = 'event_newserver'
    g_fullPopupManager:showFullPopup(event_type)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_rankBtn()
    local vars = self.vars

    g_eventIncarnationOfSinsData:setRankNoti(false)
    self:refresh()

    local ui = UI_EventIncarnationOfSinsRankingPopup()
end

-------------------------------------
-- function click_attrBtn
-- @brief 각 속성의 화신 버튼 클릭에 대한 콜백 함수
-- @param attr : 속성 (string)
-------------------------------------
function UI_EventIncarnationOfSins:click_attrBtn(attr)
    local vars = self.vars

    if (not g_eventIncarnationOfSinsData:isOpenAttr(attr)) then
        UIManager:toastNotificationRed(Str('입장 가능한 시간이 아닙니다.'))
        return
    end

    local ui = UI_EventIncarnationOfSinsEntryPopup(attr)
    
    local function close_cb()
        self:refresh()
    end
    
    ui:setCloseCB()
end