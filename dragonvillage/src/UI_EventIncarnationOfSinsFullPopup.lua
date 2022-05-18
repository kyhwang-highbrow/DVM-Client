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

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:updateTimer(dt) end, 0)
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
    vars['scenarioBtn']:runAction(cca.buttonShakeAction(2, 2))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:refresh()
    local vars = self.vars
end

-------------------------------------
-- function updateTimer
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:updateTimer(dt)
    local vars = self.vars

    local str = g_eventIncarnationOfSinsData:getTimeText()
    vars['timeLabel']:setString(str)
end

-------------------------------------
-- function playEventScenario
-- @brief 이벤트 시나리오를 재생시킨다
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:playEventScenario()
    local vars = self.vars

    local ui = UI_ScenarioPlayer(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)
    if (ui == nil) then
        return
    end

    local function finish_cb()
    -- 시나리오 재생 내역에 저장
        g_scenarioViewingHistory:addViewed(UI_EventIncarnationOfSinsFullPopup.SCENARIO_NAME)

        -- 시나리오 재생 전 bgm 다시 재생
        SoundMgr:playBGM('bgm_lobby')
    end
    
    ui:setCloseCB(finish_cb)
    ui:next()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventIncarnationOfSinsFullPopup:onEnterTab()
end