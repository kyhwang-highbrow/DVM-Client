-------------------------------------
-- class UI_EventImageQuizResult
-------------------------------------
UI_EventImageQuizResult = class(UI, {
        m_score = 'number',
        m_leftTime = 'string',
     })

local ITEM_CARD_SCALE = 0.65
-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuizResult:init(score, left_time_str)
    self.m_score = score
    self.m_leftTime = left_time_str

    local vars = self:load('event_image_quiz_ingame_clear.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_EventImageQuizResult'

    self:doActionReset()
    self:doAction()

    -- TimeScale
    cc.Director:getInstance():getScheduler():setTimeScale(1)

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_EventImageQuizResult')

    self:initUI()
    self:initButton()
--    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuizResult:initUI()
    local vars = self.vars
    vars['numberLabel']:setString(comma_value(self.m_score))
    vars['timeLabel']:setString(self.m_leftTime)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuizResult:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuizResult:refresh()
end