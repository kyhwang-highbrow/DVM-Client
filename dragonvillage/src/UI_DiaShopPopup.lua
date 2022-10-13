--@inherit UI
local PARENT = UI

-------------------------------------
---@class UI_DiaShopPopup
-------------------------------------
UI_DiaShopPopup = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_structProductList = 'table', -- List<StructProduct>
})

-------------------------------------
-- function init
-------------------------------------
function UI_DiaShopPopup:init(struct_product_list, is_popup, package_name)
    self.m_uiName = 'UI_DiaShopPopup'
    self.m_resName = 'dia_shop_popup.ui'

    self.m_structProductList = struct_product_list
end

-------------------------------------
-- function init_after
-------------------------------------
function UI_DiaShopPopup:init_after(struct_product_list, is_popup, package_name)
    local vars = self:load(self.m_resName)

    if (is_popup == true) then
        vars['closeBtn']:setVisible(true)
        UIManager:open(self, UIManager.POPUP)
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, self.m_uiName)
    end

    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DiaShopPopup:initUI()
    local vars = self.vars

    self:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DiaShopPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DiaShopPopup:refresh()
    local vars = self.vars

end

-------------------------------------
-- function initTableView
-------------------------------------
function UI_DiaShopPopup:initTableView()
    local vars = self.vars
    require('UI_DiaShopPopupItem')

    local list_node = vars['listNode']

    local table_view = UIC_TableView(vars['listNode'])
    table_view:setCellUIClass(UI_DiaShopPopupItem)
    --table_view:setCellSizeToNodeSize(true)
    table_view.m_defaultCellSize = cc.size(245 + 5, 405)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    local item_list = self:getItemList()
    table_view:setItemList(item_list)
end

-------------------------------------
-- function getItemList
---@return table
-------------------------------------
function UI_DiaShopPopup:getItemList()
    return self.m_structProductList
end

-------------------------------------x
-- function click_closeBtn
-------------------------------------
function UI_DiaShopPopup:click_closeBtn()
    self:close()
end