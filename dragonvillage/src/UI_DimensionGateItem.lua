local PARENT = class(UI, ITableViewCell:getCloneTable())


UI_DimensionGateItem = class(PARENT, {
    m_data = '',
})


-------------------------------------
-- function init
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:init(data) 
    local vars = self:load('dmgate_scene_item_top.ui')
    self.m_data = data
    ccdump(self.m_data)
end

-------------------------------------
-- function initUI
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:initUI() end


-------------------------------------
-- function initButton
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:initButton() end


-------------------------------------
-- function refresh
-- @brief virtual function of UI
-------------------------------------
function UI_DimensionGateItem:refresh() 
    self.root:setOpacity(0)
    self.root:runAction(cc.FadeIn:create(1))
end


