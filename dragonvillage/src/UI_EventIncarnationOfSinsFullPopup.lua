local PARENT = UI

-------------------------------------
-- class UI_EventIncarnationOfSinsFullPopup
-------------------------------------
UI_EventIncarnationOfSinsFullPopup = class(PARENT,{
    })


UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME = 'scen_event_incarnation_of_sins'

-------------------------------------
-- function init
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:init()
    local vars = self:load('event_incarnation_of_sins_popup.ui')
    
    self:initUI()
    self:initButton()
    self:refresh()

    -- 이벤트 시나리오를 아직 보지 않은 경우 자동 재생
    local b_is_view_scen = g_scenarioViewingHistory:isViewed(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)
    if (not b_is_view_scen) then
        self:playEventScenario()
    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:initButton()
    local vars = self.vars

    vars['scenarioBtn']:registerScriptTapHandler(function() self:playEventScenario() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:refresh()
    local vars = self.vars

    -- 이벤트 시나리오를 이미 본 경우 시나리오 버튼을 눌러 볼 수 있음
    local b_is_view_scen = g_scenarioViewingHistory:isViewed(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)
    if (b_is_view_scen) then
        vars['scenarioBtn']:setVisible(true)
    else
        vars['scenarioBtn']:setVisible(false)
    end
end

-------------------------------------
-- function playEventScenario
-- @brief 이벤트 시나리오를 재생시킨다
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:playEventScenario()
    local vars = self.vars

    local function finish_cb()
        self:refresh()
    end

    local ui = UI_ScenarioPlayer(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)
    if ui then
        g_scenarioViewingHistory:addViewed(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)
        ui:setCloseCB(finish_cb)
        ui:next()
        return 
    end
end