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