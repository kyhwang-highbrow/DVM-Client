local PARENT = UI

-------------------------------------
-- class UI_EventPopupTab_HBShop
-------------------------------------
UI_EventPopupTab_HBShop = class(PARENT,{
        m_hbItemList = 'table',
        m_tableView = 'UIC_TableView',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_EventPopupTab_HBShop:init()
    local vars = self:load('event_capsule.ui')

    self.m_hbItemList = g_highbrowData:getHBItemList()

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventPopupTab_HBShop:initUI()
    local vars = self.vars
    self:init_tableView()

    -- �ð� ǥ������ �ʴ´�.
    vars['timeLabel']:setVisible(false)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventPopupTab_HBShop:initButton()
	local vars = self.vars
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventPopupTab_HBShop:refresh()
	local vars = self.vars
    
    -- ĸ�� ��
    vars['capsuleLabel']:setString(g_userData:get('capsule'))
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_EventPopupTab_HBShop:init_tableView()
    local node = self.vars['itemNode']

    local l_item_list = self.m_hbItemList

    -- ���� �ݹ�
    local function create_func(ui, data)
        ui.vars['buyBtn']:registerScriptTapHandler(function()
            data:buyProduct(function() self:refresh() end)
        end)
    end

    -- ���̺� �� �ν��Ͻ� ����
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(920, 170 + 3)
    table_view:setCellUIClass(self.makeCellUI, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list, make_item)

    self.m_tableView = table_view
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_EventPopupTab_HBShop:onEnterTab()
    local vars = self.vars
end

-------------------------------------
-- function makeCellUI
-- @static
-- @brief ���̺� �� ����
-------------------------------------
function UI_EventPopupTab_HBShop.makeCellUI(t_data)
	local ui = class(UI, ITableViewCell:getCloneTable())()
	local vars = ui:load('event_capsule_item.ui')

    -- ��ǰ�� ���� ����
    vars['itemLabel']:setString(t_data:getName())
    vars['dscLabel']:setString(t_data:getDesc())
    vars['priceLabel']:setString(t_data:getPrice())

    local product_icon = t_data:getIcon()
    vars['itemNode']:addChild(product_icon)

	return ui
end

-------------------------------------
-- function refreshCell
-- @static
-- @brief ���̺� �� ����
-------------------------------------
function UI_MasterRoadPopup.refreshCell(ui, t_data)
    local vars = ui.vars
end