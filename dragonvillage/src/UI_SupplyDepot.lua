local PARENT = UI

-------------------------------------
-- class UI_SupplyDepot
-- @brief 깜짝 할인 상품 팝업
-------------------------------------
UI_SupplyDepot = class(PARENT,{
        m_eventId = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyDepot:init()
    self.m_eventId = event_id

    self.m_uiName = 'UI_SupplyDepot'
    
    local ui_res = 'supply_depot.ui'
    local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SupplyDepot')

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
function UI_SupplyDepot:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyDepot:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyDepot:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_SupplyDepot:update(dt)
end

--@CHECK
UI:checkCompileError(UI_SupplyDepot)
