local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

UI_ShopPackageScene = class(PARENT, {
    m_tableView = 'UIC_TableView',
    m_scrollView = 'cc.ScrollView',
})

function UI_ShopPackageScene:initParentVariable()
    self.m_uiName = 'UI_ShopPackageScene'
    
end

function UI_ShopPackageScene:init()
    local vars = self:load('shop_package.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPackageScene')
    
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

function UI_ShopPackageScene:initUI()
    local vars = self.vars

    self:createPackageScrollView()

    self:createButtonTableView()
end

function UI_ShopPackageScene:initButton()

end

function UI_ShopPackageScene:refresh()

end


----------------------------------------------------------------------
-- function createButtonTableView
----------------------------------------------------------------------
function UI_ShopPackageScene:createButtonTableView()
    local packBundleTable = TABLE:get('table_package_bundle')

    local item_list = {}

    for index, data in pairs(packBundleTable) do
        local pid_list = pl.stringx.split(data['t_pids'], ',')
        local struct_list = {}
        for _, product_id in pairs(pid_list) do
            struct_product = g_shopDataNew:getTargetProduct(tonumber(product_id))

            if struct_product then
                if (struct_product['m_tabCategory'] == 'package') then
                    table.insert(struct_list, struct_product)
                end
            end
        end

        if #struct_list > 0 then
            data['struct_product'] = struct_list
            table.insert(item_list, data)
        end
    end
 
    local create_func = function(ui, data)
        ui.vars['listLabel']:setString(Str(data['t_desc']))
        ui.m_scrollView = self.m_scrollView
        ui.m_contractBtn = self.vars['contractBtn']
    end

    local table_view = UIC_TableView(self.vars['listNode'])
    table_view:setCellSizeToNodeSize()
    table_view:setCellUIClass(UI_PackageCategoryButton, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(item_list, true)
end

----------------------------------------------------------------------
-- function createPackageScrollView
-- brief : 
----------------------------------------------------------------------
function UI_ShopPackageScene:createPackageScrollView()
    local content_size = self.vars['contentsNode']:getContentSize()

    local scroll_view = cc.ScrollView:create()
    scroll_view:setDockPoint(CENTER_POINT)
    scroll_view:setAnchorPoint(CENTER_POINT)

    scroll_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    scroll_view:setNormalSize(content_size)
    self.vars['contentsNode']:addChild(scroll_view)

    self.m_scrollView = scroll_view
end

function UI_ShopPackageScene:click_exitBtn()
    self:close()
end











------------------------------------------------------

UI_PackageCategoryButton = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_scrollView = '',
    m_contractBtn = '',
})

function UI_PackageCategoryButton:init(data)
    self.m_data = data
    local vars = self:load('shop_package_list.ui')

    vars['listBtn']:registerScriptTapHandler(function() self:click_btn() end)
end



-- ----------------------------------------------------------------------
-- -- function click_btn
-- ----------------------------------------------------------------------
function UI_PackageCategoryButton:click_btn()
    local vars = self.vars

    if (self.m_data['type'] ~= old) and (#self.m_data['struct_product'] > 1) then
        self.m_contractBtn:setVisible(true)
    else
        self.m_contractBtn:setVisible(false)
    end
    self:createTableView()
end

-- ----------------------------------------------------------------------
-- -- function createTableView
-- ----------------------------------------------------------------------
function UI_PackageCategoryButton:createTableView()
    local vars = self.vars

    local product_list = self.m_data['struct_product']
    local container = self.m_scrollView:getContainer()

    if container then 
        container:removeAllChildren()
    else 
        return 
    end

    local gap = 20
    local product_size
    local content_size
    local init_pos
    local product_num = #product_list

    -- if (self.m_data['type'] == 'old') then
    --     local package_name = TablePackageBundle:getPackageNameWithPid(pid_list[1])
    --     ui = PackageManager:getTargetUI(package_name, false)

    --     self:test(ui, 1, 1)
        
    -- else
        for index, struct_product in pairs(product_list) do
            local ui

            if (self.m_data['type'] == 'old') then
                if index > 1 then break end
                
                local package_name = TablePackageBundle:getPackageNameWithPid(struct_product['product_id'])
                product_num = 1
                ui = PackageManager:getTargetUI(package_name, false)
            else
                local package_class = _G[struct_product['package_class']]
                
                if (not package_class) and (not struct_product['package_class']) then
                    require(struct_product['package_class'])
                    package_class = _G[struct_product['package_class']]
                else
                    package_class = UI_Package
                end

                ui = package_class(struct_product, false)
            end

            if ui then
                if (index == 1) then
                    local ui_size = ui.root:getChildren()[1]:getContentSize()
                
                    if (self.m_scrollView:getDirection() == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                        product_size = ui_size.width
                    else -- cc.SCROLLVIEW_DIRECTION_VERTICAL
                        product_size = ui_size.height
                    end
            
                    local temp
            
                    if (product_num % 2 == 1) then -- odd
                        temp = math.floor(product_num / 2)
                    else -- even
                        temp = (product_num) / 2 - 0.5
                    end
            
                    init_pos = -(gap + product_size) * temp
         
            
                    if (self.m_scrollView:getDirection() == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                        self.m_scrollView:setContentSize(product_num * product_size + (product_num - 1) * gap, ui_size.height)
                        content_size = self.m_scrollView:getContentSize().width
                        container:setPositionX(0)
                    else -- cc.SCROLLVIEW_DIRECTION_VERTICAL
                        self.m_scrollView:setContentSize(ui_size.width, product_num * product_size + (product_num - 1) * gap)
                        content_size = self.m_scrollView:getContentSize().height
                        container:setPositionY(0)
                    end
            
                    self.m_scrollView:setTouchEnabled(content_size > self.m_scrollView:getNormalSize())
                end
                
                container:addChild(ui.root)
                
                local result = init_pos + (index - 1) * (gap + product_size)

                if (self.m_scrollView:getDirection() == cc.SCROLLVIEW_DIRECTION_HORIZONTAL) then
                    ui.root:setPositionX(result)
                else -- cc.SCROLLVIEW_DIRECTION_VERTICAL
                    ui.root:setPositionY(result)
                end
            end
        end
    --end
end


-- ----------------------------------------------------------------------
-- -- function createTableView
-- ----------------------------------------------------------------------