

----------------------------------------------------------------------
-- class UI_PackageCategoryButton
----------------------------------------------------------------------
UI_PackageCategoryButton = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'StructPackageBundle',
    m_scrollView = '',
    m_contractBtn = '',
    m_parent = '',
})

----------------------------------------------------------------------
-- function init
---@param data StructPackageBundle
----------------------------------------------------------------------
function UI_PackageCategoryButton:init(data)
    self.m_data = data
    local vars = self:load('shop_package_list.ui')

    vars['listBtn']:registerScriptTapHandler(function() self:click_btn() end)
end

----------------------------------------------------------------------
-- function SetTarget
----------------------------------------------------------------------
function UI_PackageCategoryButton:SetTarget(isTarget)
    self.vars['listBtn']:setEnabled(not isTarget)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_PackageCategoryButton:refresh()
    local vars = self.vars
    local data = self.m_data
    local product_list = data:getProductList()

    vars['listLabel']:setString(Str(data['t_desc']))

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

        -- 보급소 보상 수령 가능 상태인지 노티 체크
        if ( struct_product['package_res'] == 'package_supply.ui') then
            local reward_status = g_supply:checkRewardStatus(struct_product)
            
            if(reward_status) then 
                is_noti_visible = true
            end
        end

        local t_name = data['t_name']
        if (g_settingData:getPackageSetting(t_name)) ~= true then
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
    local parent = self.m_parent

    self.m_scrollView:setVisible(true)
    parent:changeTargetUI(self, vars['listBtn'])
    parent:setOff_DragonPackageUI()

    local scroll_node
    if (self.m_data['type'] == 'group') then
        scroll_node = parent.vars['contentsListNode']
    else
        scroll_node = parent.vars['contentsNode']
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

    self:refresh()
end

----------------------------------------------------------------------
-- function createTableView
----------------------------------------------------------------------
function UI_PackageCategoryButton:createTableView()
    local product_list = self.m_data:getProductList()
    local container = self.m_scrollView:getContainer()

    if not container then 
        return
    end

    container:removeAllChildren()

    -- struct_package
    self.m_data:setTargetUI(container, function() self:refresh() end, true)
    local ui_list = container:getChildren()

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

    if (self.m_data['type'] ~= 'group') then
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

----------------------------------------------------------------------
-- function isDragonPackage
----------------------------------------------------------------------
function UI_PackageCategoryButton:isDragonPackage()
    return false
end