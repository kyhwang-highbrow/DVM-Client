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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSins:initUI()
    local vars = self.vars

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSins:refresh()
    local vars = self.vars

    -- 현재 서버 데이터를 이용하여 버튼 설정
    self:refreshButton('total', vars['rankLabel'], vars['scoreLabel'], nil, nil)
    self:refreshButton('light', vars['rankLabel1'], vars['scoreLabel1'], vars['buyBtn1'], vars['lockSprite1'])
    self:refreshButton('fire', vars['rankLabel2'], vars['scoreLabel2'], vars['buyBtn2'], vars['lockSprite2'])
    self:refreshButton('water', vars['rankLabel3'], vars['scoreLabel3'], vars['buyBtn3'], vars['lockSprite3'])
    self:refreshButton('earth', vars['rankLabel4'], vars['scoreLabel4'], vars['buyBtn4'], vars['lockSprite4'])
    self:refreshButton('dark', vars['rankLabel5'], vars['scoreLabel5'], vars['buyBtn5'], vars['lockSprite5'])
end

-------------------------------------
-- function refreshButton
-- @param attr : 속성값으로 해당 값으로 점수와 랭크 받음
-- @param rank_label : UI 파일에서 랭크를 적을 라벨
-- @param score_label : UI 파일에서 점수를 적을 라벨
-- @param attr_btn : 해당 속성 버튼, 없는 경우(total) nil로 설정
-- @param lock_sprite : 해당 속성 잠금 스프라이트, 없는 경우(total) nil로 설정
-------------------------------------
function UI_EventIncarnationOfSins:refreshButton(attr, rank_label, score_label, attr_btn, lock_sprite)
    local vars = self.vars

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
        rank_label:setString(Str('{1}위 ({2}%)', comma_value(score), percent_text))
    end
	
    -- 점수
    if (score < 0) then
        score_label:setString(Str('{1}점', 0))
    else
        score_label:setString(Str('{1}점', comma_value(score)))
    end

    -- 버튼 설정
    if (attr ~= 'total') then
        if (g_eventIncarnationOfSinsData:isOpenAttr(attr)) then
            if (lock_sprite ~= nil) then
                lock_sprite:setVisible(false)
            end

            if (attr_btn ~= nil) then
                attr_btn:setEnabled(true)
            end
        
        else
            if (lock_sprite ~= nil) then
                lock_sprite:setVisible(true)
            end

            if (attr_btn ~= nil) then
                attr_btn:setEnabled(false)
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

-------------------------------------
-- function click_eventBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_eventBtn()
    local vars = self.vars

    local event_type = 'event_incarnation_of_sins'
    g_fullPopupManager:showFullPopup(event_type)
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_EventIncarnationOfSins:click_rankBtn()
    local vars = self.vars

    local ui = UI_EventIncarnationOfSinsRankingPopup()
end

-------------------------------------
-- function click_attrBtn
-- @brief 각 속성의 화신 버튼 클릭에 대한 콜백 함수
-- @param attr : 속성 (string)
-------------------------------------
function UI_EventIncarnationOfSins:click_attrBtn(attr)
    local vars = self.vars

    local ui = UI_EventIncarnationOfSinsEntryPopup(attr)
    
    local function close_cb()
        self:refresh()
    end
    
    ui:setCloseCB()
end