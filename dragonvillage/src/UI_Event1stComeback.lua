local PARENT = UI

-------------------------------------
-- class UI_Event1stComeback
-- @desc 1주년 이벤트 : 복귀 유저 환영 이벤트
-------------------------------------
UI_Event1stComeback = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_Event1stComeback:init()
    local vars = self:load('event_1st_comeback.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Event1stComeback:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Event1stComeback:initButton()
    local vars = self.vars
    --vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    --vars['boxBtn']:registerScriptTapHandler(function() self:click_boxBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Event1stComeback:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_infoBtn
-- @brief 획득 방법
-------------------------------------
function UI_Event1stComeback:click_infoBtn()

end