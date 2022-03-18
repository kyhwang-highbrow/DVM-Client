local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_ShopPackageScene = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_scrollView = 'cc.ScrollView',


    m_targetButton = 'UIC_Button',
})

----------------------------------------------------------------------
-- function initParentVariable
----------------------------------------------------------------------
function UI_ShopPackageScene:initParentVariable()
    self.m_uiName = 'UI_ShopPackageScene'
    self.m_titleStr = Str('패키지')
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end


----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_ShopPackageScene:init(package_name)
    local vars = self:load('shop_package.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPackageScene')
    
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI(package_name)
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_ShopPackageScene:initUI(package_name)
    local vars = self.vars

    self:createPackageScrollView()

    self:createButtonTableView(package_name)
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_ShopPackageScene:initButton()

end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_ShopPackageScene:refresh()

    if (not self.m_targetButton) then
        local item = self.m_tableView:getItemFromIndex(1)
        self.m_targetButton = item['ui'] or item['generated_ui']
    end
    self.m_targetButton:click_btn()

    local index = self.m_targetButton:getCellIndex()
    
    self.m_tableView:relocateContainerFromIndex(index)
end


----------------------------------------------------------------------
-- function createPackageScrollView
-- brief : 
----------------------------------------------------------------------
function UI_ShopPackageScene:createPackageScrollView()

    local content_size = self.vars['contentsListNode']:getContentSize()

    local scroll_view = cc.ScrollView:create()
    scroll_view:setDockPoint(CENTER_POINT)
    scroll_view:setAnchorPoint(CENTER_POINT)
    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    scroll_view:setNormalSize(content_size)
    scroll_view:setContentSize(content_size)
    self.vars['contentsListNode']:addChild(scroll_view)

    self.m_scrollView = scroll_view
end

----------------------------------------------------------------------
-- function createButtonTableView
----------------------------------------------------------------------
function UI_ShopPackageScene:createButtonTableView(package_name)

    if self.m_tableView then
        self.m_tableView:removeAllChildren()
        self.m_tableView = nil
    end
    local item_list = g_shopDataNew:getActivatedPackageList()
 
    local create_func = function(ui, data)
        ui.vars['listLabel']:setString(Str(data['t_desc']))
        ui.m_scrollView = self.m_scrollView
        ui.m_contractBtn = self.vars['contractBtn']
        ui.m_parent = self

        if (data['t_name'] == package_name) then
            self.m_targetButton = ui
        end

        ui:refresh()
    end

    local table_view = UIC_TableView(self.vars['listNode'])
    table_view:setCellSizeToNodeSize()
    table_view:setGapBtwCells(3)
    table_view:setCellUIClass(UI_PackageCategoryButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)

    self.m_tableView = table_view
end

----------------------------------------------------------------------
-- function click_exitBtn
----------------------------------------------------------------------
function UI_ShopPackageScene:click_exitBtn()
    self:close()
end





------------------------------------------------------

UI_PackageCategoryButton = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'StructPackage',
    m_scrollView = '',
    m_contractBtn = '',
    m_parent = '',
})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_PackageCategoryButton:init(data)
    self.m_data = data
    local vars = self:load('shop_package_list.ui')

    vars['listBtn']:registerScriptTapHandler(function() self:click_btn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_PackageCategoryButton:refresh()
    local vars = self.vars
    local product_list = self.m_data:getProductList()

    local is_changed = false

    local is_noti_visible = false
    for index, struct_product in pairs(product_list) do
        
        local purchased_num = g_shopDataNew:getBuyCount(struct_product:getProductID())
        local limit = struct_product:getMaxBuyCount()

        -- 특가 상품이 구매제한 초과 시 기존상품(dependency)으로 교체
        if purchased_num and limit and (purchased_num >= limit) then
            local dependent_product_id = struct_product:getDependency()

            if dependent_product_id then

                is_changed = true
                struct_product = g_shopDataNew:getTargetProduct(dependent_product_id)
                product_list[index] = struct_product
            end
        end        
        
        -- 구매 가능한지 노티 체크
        if (struct_product:getPrice() == 0) and (struct_product:isItBuyable()) then
            is_noti_visible = true
        end
    end

    if vars['notiSprite'] then
        vars['notiSprite']:setVisible(is_noti_visible)
    end

    if vars['badgeNode'] then
        vars['badgeNode']:removeAllChildren()

        for _, struct_product in pairs(product_list) do
            local badge = struct_product:makeBadgeIcon()
            if badge then
                vars['badgeNode']:addChild(badge)
                break
            end
        end
    end


    if is_changed then
        self:click_btn()
    end
end



----------------------------------------------------------------------
-- function click_btn
----------------------------------------------------------------------
function UI_PackageCategoryButton:click_btn()
    local vars = self.vars

    self.m_parent.m_targetButton.vars['listBtn']:setEnabled(true)

    self.m_parent.m_targetButton = self
    vars['listBtn']:setEnabled(false)

    local scroll_node

    if (self.m_data['type'] == 'group') then
        scroll_node = self.m_parent.vars['contentsListNode']
        
    else
        scroll_node = self.m_parent.vars['contentsNode']
    end
    
    local content_size = scroll_node:getContentSize()

    self.m_scrollView:setDockPoint(TOP_CENTER)
    self.m_scrollView:setAnchorPoint(TOP_CENTER)

    if (self.m_data['scroll_direction'] == 'vertical') then
        self.m_scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    else
        self.m_scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    end
    self.m_scrollView:setNormalSize(content_size)
    self.m_scrollView:setContentSize(content_size)
    self.m_scrollView:retain()
    self.m_scrollView:removeFromParent()
    scroll_node:addChild(self.m_scrollView)

    self:createTableView()

    
    if self.m_scrollView:getContainer():getChildrenCount() > 1 and g_localData:isKoreaServer() then
        self.m_contractBtn:setVisible(true)
        self.m_contractBtn:registerScriptTapHandler(function() GoToAgreeMentUrl() end)
    else
        self.m_contractBtn:setVisible(false)
    end
end

----------------------------------------------------------------------
-- function createTableView
----------------------------------------------------------------------
function UI_PackageCategoryButton:createTableView()
    local vars = self.vars

    local product_list = self.m_data:getProductList()
    local container = self.m_scrollView:getContainer()

    if container then 
        container:removeAllChildren()
    else 
        return 
    end

    
    -- struct_package
    self.m_data:setTargetUI(container, function() self:refresh() end, true)

    ------------------------------------------------------------------------

    ui_list = container:getChildren()

    local product_num = #product_list
    local row_num

    local margin = 10

    local is_dock_center = (self.m_data['dock_point'] == 1)
    -- For now, we don't use dock_point, so just set to false
    is_dock_center = false

    if (self.m_data['row_num'] ~= '') then
        row_num = tonumber(self.m_data['row_num'])
        -- WHY?
        margin = 5

        if (product_num < row_num) then
            row_num = product_num
        end
    else
        row_num = product_num
    end

    local col_num = math.floor(product_num / row_num)

    if (self.m_data['type'] == '') or (self.m_data['type'] == 'bundle') then
        row_num = 1
        col_num = 1
    end

    ------------------------------------------------------------------------
    local temp_x
    local temp_y

    if ((row_num % 2) == 1) then -- odd
        temp_x = math.floor(row_num / 2)
    else -- even
        temp_x = (row_num) / 2 - 0.5
    end

    if ((col_num % 2) == 1) then -- odd
        temp_y = math.floor(col_num / 2)
    else -- even
        temp_y = (col_num) / 2 - 0.5
    end

    -- assume that size of all child UI is same
    local ui_size = ui_list[1]:getChildren()[1]:getContentSize()

    local init_pos_x = -(margin + ui_size.width) * temp_x
    local init_pos_y = (margin + ui_size.height) * temp_y

    ------------------------------------------------------------------------
    local normal_width, normal_height =  self.m_scrollView:getNormalSize()
    local content_size = self.m_scrollView:getContentSize()
    local scrollview_width = row_num * ui_size.width + (row_num - 1) * margin
    local scrollview_height = col_num * ui_size.height + (col_num - 1) * margin

    
    local is_larger
    if (self.m_scrollView:getDirection() == cc.SCROLLVIEW_DIRECTION_VERTICAL) then
        is_larger = (scrollview_height > normal_height)
        if is_larger or (not is_dock_center) then
            self.m_scrollView:setContentSize(scrollview_width, scrollview_height)
        else
            self.m_scrollView:setContentSize(scrollview_width, content_size.height)
        end
    else -- cc.SCROLLVIEW_DIRECTION_HORIZONTAL
        is_larger = (scrollview_width > normal_width)
        if is_larger or (not is_dock_center) then
            self.m_scrollView:setContentSize(scrollview_width, scrollview_height)
        else
            self.m_scrollView:setContentSize(content_size.width, scrollview_height)
        end    
    end
    self.m_scrollView:setTouchEnabled(is_larger)
    container:setPosition(0, 0)
    ------------------------------------------------------------------------

    for index, ui_root in pairs(ui_list) do
        if (index > 1) and (self.m_data['type'] ~= 'group') then
            break
        end
        local row = (index - 1) % row_num
        local col = math.floor((index - 1) / row_num)

        local result_x = init_pos_x + row * (margin + ui_size.width)
        local result_y = init_pos_y - col * (margin + ui_size.height)

        ui_root:setPosition(result_x, result_y)
    end

    

end


