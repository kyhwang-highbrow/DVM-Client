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

    -- 현재 서버 데이터를 이용하여 순위 정보 표기
    self:refreshScore('total', vars['rankLabel'], vars['scoreLabel'])
    self:refreshScore('light', vars['rankLabel1'], vars['scoreLabel1'])
    self:refreshScore('fire', vars['rankLabel2'], vars['scoreLabel2'])
    self:refreshScore('water', vars['rankLabel3'], vars['scoreLabel3'])
    self:refreshScore('earth', vars['rankLabel4'], vars['scoreLabel4'])
    self:refreshScore('dark', vars['rankLabel5'], vars['scoreLabel5'])
end

-------------------------------------
-- function refreshScore
-- @param attr : 속성값으로 해당 값으로 점수와 랭크 받음
-- @param rank_label : UI 파일에서 랭크를 적을 라벨
-- @param score_label : UI 파일에서 점수를 적을 라벨
-------------------------------------
function UI_EventIncarnationOfSins:refreshScore(attr, rank_label, score_label)
    local vars = self.vars

    -- 현재 서버 데이터를 이용하여 순위 정보 표기
    local rank = g_eventIncarnationOfSinsData:getMyRank(attr)
    local score = g_eventIncarnationOfSinsData:getMyScore(attr)
	
	-- 내 랭킹이 0보다 작으면 {-위} 로 노출
    -- 0보다 큰 의미있는 값이면 그대로 노출
    if (rank < 0) then
        rank_label:setString(Str('{1}위', '-'))
    else
        rank_label:setString(Str('{1}위', rank))
    end
	
	-- 내 스코어가 0보다 작으면 {-위} 로 노출
    -- 0보다 큰 의미있는 값이면 그대로 노출
    if (score < 0) then
        score_label:setString(Str('{1}위', '-'))
    else
        score_label:setString(Str('{1}점', score))
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
end