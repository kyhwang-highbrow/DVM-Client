local PARENT = UI

-------------------------------------
-- class UI_NewcomerShop
-- @brief 초보자 선물 (신규 유저 전용 상점)
-------------------------------------
UI_NewcomerShop = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NewcomerShop:init()
    self.m_uiName = 'UI_NewcomerShop'
    
    local ui_res = 'newcomer_shop.ui'
    local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_NewcomerShop')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NewcomerShop:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NewcomerShop:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NewcomerShop:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_NewcomerShop:update(dt)
    local vars = self.vars
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_NewcomerShop:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_NewcomerShop)
