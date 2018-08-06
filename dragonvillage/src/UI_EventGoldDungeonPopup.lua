local PARENT = UI

-------------------------------------
-- class UI_EventGoldDungeonPopup
-------------------------------------
UI_EventGoldDungeonPopup = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventGoldDungeonPopup:init()
    local vars = self:load('event_gold_dungeon_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_EventGoldDungeonPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventGoldDungeonPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventGoldDungeonPopup:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventGoldDungeonPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_EventGoldDungeonPopup:click_closeBtn()
	self:close()
end

--@CHECK
UI:checkCompileError(UI_EventGoldDungeonPopup)
