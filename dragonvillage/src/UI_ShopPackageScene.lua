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
-- function createButtonTableView
----------------------------------------------------------------------
function UI_ShopPackageScene:createButtonTableView(package_name)
    local packBundleTable = TABLE:get('table_package_bundle')

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
-- function click_exitBtn
----------------------------------------------------------------------
function UI_ShopPackageScene:click_exitBtn()
    self:close()
end





------------------------------------------------------

UI_PackageCategoryButton = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
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

    
    local product_list = self.m_data['product_list']

    if #product_list > 1 then
        local badge = product_list[1]:makeBadgeIcon()
        if badge then
            vars['badgeNode']:addChild(badge)
        end
    end
end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_PackageCategoryButton:refresh()
    local is_noti_visible = false
    for index, struct_product in pairs(self.m_data['product_list']) do
        if (struct_product:getPrice() == 0) and (struct_product:isItBuyable()) then
            is_noti_visible = true
        end
    end

    if self.vars['notiSprite'] then
        self.vars['notiSprite']:setVisible(is_noti_visible)
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
    else
        self.m_contractBtn:setVisible(false)
    end
end

-- ----------------------------------------------------------------------
-- -- function createTableView
-- ----------------------------------------------------------------------
function UI_PackageCategoryButton:createTableView()
    local vars = self.vars

    local product_list = self.m_data['product_list']
    local container = self.m_scrollView:getContainer()

    if container then 
        container:removeAllChildren()
    else 
        return 
    end

    local margin = 10
    local init_pos_x
    local init_pos_y
    local product_num = #product_list
    local row_num

    local is_dock_center
    if (self.m_data['dock_point'] == 1) then
        is_dock_center = true
    else
        is_dock_center = false
    end
    is_dock_center = false

    if (self.m_data['row_num'] ~= '') then
        row_num = tonumber(self.m_data['row_num'])
        margin = 5

        if product_num < row_num then 
            row_num = product_num 
        end
    else
        row_num = product_num
    end

    local col_num = math.floor(product_num / row_num)


    for index, struct_product in pairs(product_list) do
        local ui

        if (self.m_data['type'] == '') then
            if index > 1 then break end
            
            local package_name = TablePackageBundle:getPackageNameWithPid(struct_product['product_id'])
            product_num = 1
            row_num = 1
            col_num = 1
            ui = PackageManager:getTargetUI(package_name, false)

        -- elseif (self.m_data['type'] == 'single') then
        --     local product_list = {}
        --     table.insert(product_list, struct_product)
        --     ui = UI_Package(struct_product, false)
        else
            local package_class

            if struct_product['package_class'] and (struct_product['package_class'] ~= '')then
                if (not _G[struct_product['package_class']]) then
                    require(struct_product['package_class'])
                end
                package_class = _G[struct_product['package_class']]
            end
            
            if (not package_class) then
                package_class = UI_Package
            end

            if (self.m_data['type'] == 'bundle') then
                product_num = 1
                row_num = 1
                col_num = 1
                if index > 1 then break end
                ui = package_class(product_list, false, self.m_data['t_name'])
            else
                local list = {}
                table.insert(list, struct_product)
                ui = package_class(list, false, self.m_data['t_name'])
            end
        end

        local function checkMemberInMetatable(obj, name)
            local pObj = getmetatable(obj)

            while(pObj ~= nil) do
                if rawget(pObj, name) ~= nil then
                    return true
                end
                pObj = rawget(pObj, 'def') and rawget(pObj, 'def') or rawget(pObj, 'super')
            end

            return false
        end

        if ui then
            if checkMemberInMetatable(ui, 'setBuyCB') then
                ui:setBuyCB(function() self:refresh() end)
            end

            local ui_size = ui.root:getChildren()[1]:getContentSize()

            if (index == 1) then
                local temp_x
                local temp_y
        
                if (row_num % 2 == 1) then -- odd
                    temp_x = math.floor(row_num / 2)
                else -- even
                    temp_x = (row_num) / 2 - 0.5
                end

                if (col_num % 2 == 1) then -- odd
                    temp_y = math.floor(col_num / 2)
                else -- even
                    temp_y = (col_num) / 2 - 0.5
                end
        
                init_pos_x = -(margin + ui_size.width) * temp_x
                init_pos_y = (margin + ui_size.height) * temp_y       
                
                ----------------------------------------------------------
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
            end
            
            container:addChild(ui.root)

            local row = (index - 1) % row_num
            local col = math.floor((index - 1) / row_num)
            
            local result_x = init_pos_x + row * (margin + ui_size.width)
            local result_y = init_pos_y - col * (margin + ui_size.height)

            ui.root:setPosition(result_x, result_y)
        end
    end
end


