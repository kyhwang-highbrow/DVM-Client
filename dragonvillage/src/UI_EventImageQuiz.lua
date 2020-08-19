local PARENT = UI

-------------------------------------
-- class UI_EventImageQuiz
-------------------------------------
UI_EventImageQuiz = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventImageQuiz:init()
    local vars = self:load('event_image_quiz.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventImageQuiz:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventImageQuiz:initButton()
    local vars = self.vars

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventImageQuiz:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventImageQuiz:click_infoBtn()
    local ui = UI()
    local vars = ui:load('event_image_quiz_info_popup.ui')
    UIManager:open(ui, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(ui, function() ui:close() end, 'UI_EventImageQuizInfoPopup (FakeUI)')
    vars['okBtn']:registerScriptTapHandler(function() ui:close() end)
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_EventImageQuiz:click_startBtn()
    UI_EventImageQuizIngame()
end