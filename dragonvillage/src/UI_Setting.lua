local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_Setting
-------------------------------------
UI_Setting = class(PARENT, {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_Setting:init()
    local vars = self:load('setting_popup_new.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey ě§ě 
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Setting')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Setting:initUI()
    local vars = self.vars
    self:initTab()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Setting:initButton()
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Setting:refresh()
    local vars = self.vars
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Setting:click_closeBtn()
    self:close()
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_Setting:initTab()
    local tab_list = {}
    table.insert(tab_list, 'game')
    table.insert(tab_list, 'account')
    table.insert(tab_list, 'alarm')
    table.insert(tab_list, 'info')
    table.insert(tab_list, 'dev')

    local vars = self.vars
    for i,v in ipairs(tab_list) do
        local key = v
        local btn = vars[v .. 'Btn']
        local menu = vars[v .. 'Menu']
        self:addTab(key, btn, menu)
    end
    
    self:setTab('game')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_Setting:onChangeTab(tab, first)
    if first then
        local func_name = 'init_' .. tab .. 'Tab'
        self[func_name](self)
    end
end