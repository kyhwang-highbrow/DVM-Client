local PARENT = UI

-------------------------------------
-- class UI_EventMatchCard
-------------------------------------
UI_EventMatchCard = class(PARENT,{
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
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventMatchCard:initUI()
    local vars = self.vars
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
