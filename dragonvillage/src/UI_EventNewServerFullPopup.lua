local PARENT = UI

-------------------------------------
-- class UI_EventNewServerFullPopup
-------------------------------------
UI_EventNewServerFullPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventNewServerFullPopup:init()
    local vars = self:load('event_reward.ui')
    
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventNewServerFullPopup:initUI()
    local vars = self.vars
    self.m_uiName = 'UI_EventNewServerFullPopup'

    local is_event_open = UINavigatorDefinition:findOpendUI('UI_EventPopup')

    local str = g_eventIncarnationOfSinsData:getTimeText()
    vars['timeLabel']:setString(str)
    
    --이벤트 상점이 열려있으면 버튼을 꺼줌
    vars['linkBtn']:setVisible(not is_event_open)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventNewServerFullPopup:initButton()
    local vars = self.vars

    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventNewServerFullPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventNewServerFullPopup:onEnterTab()
end

-------------------------------------
-- function click_linkBtn
-- @brief
-------------------------------------
function UI_EventNewServerFullPopup:click_linkBtn()
    local vars = self.vars

    if (not g_eventIncarnationOfSinsData:isActive()) then
        return
    else
        local event_type = 'event_incarnation_of_sins'
        g_eventIncarnationOfSinsData.m_isOpened = true
        g_eventData:openEventPopup(event_type)
    end
end