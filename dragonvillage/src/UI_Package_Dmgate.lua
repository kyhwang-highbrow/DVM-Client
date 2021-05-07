local PARENT = UI_Package

----------------------------------------------------------------------
-- class UI_Package_Dmgate
----------------------------------------------------------------------
UI_Package_Dmgate = class(PARENT, {
    m_tableview = 'UIC_TableView',
})

-- ----------------------------------------------------------------------
-- -- function init
-- ----------------------------------------------------------------------
function UI_Package_Dmgate:init(struct_product, is_popup)
    self.m_uiName = 'UI_Package_Dmgate'
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_Package_Dmgate:initMember()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_Package_Dmgate:initUI()
    self:initMember()

    PARENT.initUI(self)

    self:initTableView()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_Package_Dmgate:initButton(is_popup)
    PARENT.initButton(self, is_popup)

    self:setBuyCB(function() self:buyCallback() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_Dmgate:refresh()
    PARENT.refresh(self)

end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_Dmgate:initTableView()
    local vars = self.vars

    local product_id = self.m_structProduct['product_id']

    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node
    local isPackagePurchased = g_dmgatePackageData:isPackageActive(product_id)

    vars['productNodeLong']:setVisible(isPackagePurchased)
    vars['productNode']:setVisible(not isPackagePurchased)
    vars['buyBtn']:setVisible(not isPackagePurchased)
    vars['contractBtn']:setVisible(not isPackagePurchased)

    if isPackagePurchased then
        node = vars['productNodeLong']
    else
        node = vars['productNode']
    end

    local item_list = g_dmgatePackageData:getPackageTable(product_id)


    local function create_func(ui, data)
        
    end

    local tableview = UIC_TableView(node)
    tableview:setCellSizeToNodeSize(true)

    tableview:setGapBtwCells(5)
    tableview:setCellUIClass(UI_Package_DmgateListItem, create_func)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setItemList(item_list, true)
    self.m_tableview = tableview
end

----------------------------------------------------------------------
-- function buyCallback
----------------------------------------------------------------------
function UI_Package_Dmgate:buyCallback(ret)
    local function callback()
        self:initTableView()
        self:refresh()

        self.m_tableview:refreshAllItemUI()
    end
    g_dmgatePackageData:request_info(self.m_structProduct['product_id'], callback)
end

----------------------------------------------------------------------
-- class UI_Package_Dmgate
----------------------------------------------------------------------
UI_Package_DmgateListItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_productId = 'string',
    m_stageId = '',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_Package_DmgateListItem:init(data)
    self.m_data = data
    local struct_product = g_shopDataNew:getTargetProduct(tonumber(self.m_data['product_id']))
    local ui_str_list = plSplit(struct_product['package_res'], '.')
    local ui_file_name = ui_str_list[1] ..'_item.' .. ui_str_list[2]
    
    local vars = self:load(ui_file_name)

    --self.m_productId = self.m_data['product_id']
    --self.m_stageId = self.m_data['achive2']

    -- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_Package_DmgateListItem:initUI()
    local vars = self.vars

    local stage_id = self.m_data['achive_2']
    local chapter_name = g_dmgateData:getStageChapterText(stage_id)
    local stage_name = g_dmgateData:getStageName(stage_id)
    local diff_name = g_dmgateData:getStageDiffText(stage_id)
    --local diff_color = g_dmgateData:getStageDiffTextColor(stage_id)

    vars['levelLabel']:setString(chapter_name .. ' ' .. stage_name .. ' ' .. diff_name)
    --vars['levelLabel']:setTextColor(diff_color)
    

    local item_list = ServerData_Item:parsePackageItemStr(self.m_data['reward'])


    for i, v in pairs(item_list) do
        local card = UI_ItemCard(v['item_id'], v['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode' .. i]:addChild(card.root)
    end
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_Package_DmgateListItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_DmgateListItem:refresh()
    local vars = self.vars

    local product_id = self.m_data['product_id']
    local isPackagePurchased = g_dmgatePackageData:isPackageActive(product_id)

    if (not isPackagePurchased) then
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setEnabled(false)

        return
    end

    
    local stage_id = self.m_data['achive_2']
    local isRewardReceived = g_dmgatePackageData:isRewardReceived(product_id, stage_id)
    
    local isStageEverCleared = g_dmgateData:isStageEverCleared(stage_id)    
    
    vars['receiveSprite']:setVisible(isRewardReceived)
    vars['rewardBtn']:setEnabled((not isRewardReceived) and isStageEverCleared)
end


----------------------------------------------------------------------
-- function click_rewardBtn
----------------------------------------------------------------------
function UI_Package_DmgateListItem:click_rewardBtn()
    local product_id = self.m_data['product_id']
    local stage_id = self.m_data['achive_2']

    
    local function success_cb(ret)
        self:refresh()

        ItemObtainResult_Shop(ret)
    end

    local function fail_cb(ret)
        UIManager:toastNotificationRed(Str('잘못된 요청입니다.'))

        UINavigator:goTo('lobby')
    end
    
    g_dmgatePackageData:request_reward(product_id, stage_id, success_cb, fail_cb)
end