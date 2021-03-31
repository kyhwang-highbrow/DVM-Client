local PARENT = UI

--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
-------------------------------------
-- class UI_BattlePassInfoPopup
-- @brief 
-------------------------------------
UI_DimensionGateInfoPopup = class(PARENT,{
    })
 
-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateInfoPopup:init()
	self.m_uiName = 'UI_DimensionGateInfoPopup'

    local vars = self:load('dmgate_info_popup.ui ')
    UIManager:open(self, UIManager.POPUP)

    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DimensionGateInfoPopup')
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateInfoPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateInfoPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateInfoPopup:refresh()
end




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--//  
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////

-------------------------------------
-- class UI_DimensionGateBlessPopup
-- @brief 
-------------------------------------
UI_DimensionGateBlessPopup = class(PARENT,{
})

-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateBlessPopup:init()
self.m_uiName = 'UI_DimensionGateBlessPopup'

local vars = self:load('dmgate_bless_popup.ui ')
UIManager:open(self, UIManager.POPUP)

-- @UI_ACTION
--self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
self:doActionReset()
self:doAction(nil, false)

-- backkey 지정
g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DimensionGateBlessPopup')
vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateBlessPopup:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateBlessPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateBlessPopup:refresh()
end