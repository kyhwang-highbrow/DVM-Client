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
    m_titleNode = '',
    m_infoNode = '',
})

-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateBlessPopup:init()
self.m_uiName = 'UI_DimensionGateBlessPopup'
local vars = self:load('dmgate_bless_popup.ui ')

UIManager:open(self, UIManager.POPUP)

self.m_titleNode = vars['blessLabel']
self.m_infoNode = vars['blessInfoLabel']

-- @UI_ACTION
--self:addAction(self.root, UI_ACTION_TYPE_SCALE, 0, 0.2)
self:doActionReset()
self:doAction(nil, false)

-- backkey 지정
g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_DimensionGateBlessPopup')
vars['closeBtn']:registerScriptTapHandler(function() self:close() end)


self:initUI()
self:initButton()
self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateBlessPopup:initUI()

    local buff_list = g_dimensionGateData:getBuffList(DIMENSION_GATE_MANUS)
    self.m_titleNode:setString('주간 축복')
    self.m_infoNode:setString(Str(buff_list[1]['t_desc'], buff_list[1]['effect_val']))
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