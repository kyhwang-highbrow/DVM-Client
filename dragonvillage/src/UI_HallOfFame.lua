local PARENT = UI

-------------------------------------
-- class UI_HallOfFame
-------------------------------------
UI_HallOfFame = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_HallOfFame:init()
    local vars = self:load('hall_of_fame_scene.ui')
    UIManager:open(self, UIManager.SCENE)
    
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_HallOfFame')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    --self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_HallOfFame:initUI()
    local vars = self.vars
    for i=1, 5 do
        --vars['itemNode' .. i]:addChild
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_HallOfFame:initButton()
    local vars = self.vars
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
	vars['rankingBtn']:registerScriptTapHandler(function() self:click_rankBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_HallOfFame:click_infoBtn()
    UI_HallOfFameHelp()
end

-------------------------------------
-- function click_rankBtn
-------------------------------------
function UI_HallOfFame:click_rankBtn()
    UI_HallOfFameRank()
end
