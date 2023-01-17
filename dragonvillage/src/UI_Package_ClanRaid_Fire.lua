local PARENT = UI_Package

----------------------------------------------------------------------
-- class UI_Package_ClanRaid_Fire
----------------------------------------------------------------------
UI_Package_ClanRaid_Fire = class(PARENT, {
    m_tableview = 'UIC_TableView',
})

-- ----------------------------------------------------------------------
-- -- function init
-- ----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:init(struct_product, is_popup)
    self.m_uiName = 'UI_Package_ClanRaid_Fire'
    -- @UI_ACTION
    --self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0.2, 0.3)
    --self:doActionReset()
    --self:doAction(nil, false)
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:initMember()
end

----------------------------------------------------------------------
-- function initUI
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:initUI()
    self:initMember()

    PARENT.initUI(self)

    self:initTableView()
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:initButton(is_popup)
    PARENT.initButton(self, is_popup)

    self:setBuyCB(function() self:buyCallback() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:refresh()
    PARENT.refresh(self)

end


----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:initTableView()
    local vars = self.vars

    local product_id = self.m_structProduct['product_id']

    cclog('--------------------------------------------------------------')
    cclog('product_id Fire : ' .. product_id)
    cclog('--------------------------------------------------------------')

    vars['productNode']:removeAllChildren()
    vars['productNodeLong']:removeAllChildren()

    local node
    local isPackagePurchased = g_clanDungeonFirePackageData:isPackageActive(product_id)

    vars['productNodeLong']:setVisible(isPackagePurchased)
    vars['productNode']:setVisible(not isPackagePurchased)
    vars['buyBtn']:setVisible(not isPackagePurchased)
    vars['buyLabel']:setVisible(not isPackagePurchased)
    vars['contractBtn']:setVisible(not isPackagePurchased)
    -- vars['rewardVisual']:setVisible(not isPackagePurchased)

    if isPackagePurchased then
        node = vars['productNodeLong']
        -- vars['infoLabel']:setString(Str('수령 완료'))
    else
        node = vars['productNode']
        -- vars['rewardVisual']:setTimeScale(2)
    end

    local item_list = g_clanDungeonFirePackageData:getPackageTable(product_id)

    table.sort(item_list, function(a, b)
        return a['package_id'] < b['package_id']
    end)


    local function create_func(ui, data)
        
    end

    local tableview = UIC_TableView(node)
    tableview:setCellSizeToNodeSize(true)

    tableview:setGapBtwCells(5)
    tableview:setCellUIClass(UI_Package_ClanRaid_FireListItem, create_func)
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setItemList(item_list, true)
    self.m_tableview = tableview

    if g_clanDungeonFirePackageData:isPackageActive(product_id) then
        local isReceivableReward = false
        local target_index
        for key, data in pairs(item_list) do
            local dungeon_score = data['achive_2']
            local isRewardReceived = g_clanDungeonFirePackageData:isRewardReceived(product_id, dungeon_score)
    
            local curr_score = g_clanRaidData:getClanDungeonFireScore()
            
            local isOverScore = (curr_score >= dungeon_score)

            isReceivableReward = (not isRewardReceived) and isOverScore
            if isReceivableReward then 
                target_index = key
                break 
            end
        end

        if isReceivableReward then
            self.m_tableview:update(0)
            self.m_tableview:relocateContainerFromIndex(target_index)
        end
    end
end

----------------------------------------------------------------------
-- function buyCallback
----------------------------------------------------------------------
function UI_Package_ClanRaid_Fire:buyCallback(ret)
    local function callback()
        self:initTableView()
        self:refresh()

        self.m_tableview:refreshAllItemUI()
    end
    g_clanDungeonFirePackageData:request_info(self.m_structProduct['product_id'], callback)
end

----------------------------------------------------------------------
-- class UI_Package_ClanRaid_Fire
----------------------------------------------------------------------
UI_Package_ClanRaid_FireListItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_productId = 'string',
    m_stageId = '',

})

----------------------------------------------------------------------
-- function init
----------------------------------------------------------------------
function UI_Package_ClanRaid_FireListItem:init(data)
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
function UI_Package_ClanRaid_FireListItem:initUI()
    local vars = self.vars

    local stage_score = self.m_data['achive_2']
    -- local chapter_name = g_dmgateData:getStageChapterText(stage_id)
    -- local stage_name = g_dmgateData:getStageName(stage_id)

    -- local diff_color = g_dmgateData:getStageDiffColorStr(stage_id)
    -- local diff_name = g_dmgateData:getStageDiffText(stage_id)

    -- local chapter_name = g_dmgateData:getStageChapterText(stage_id)
    -- local stage_name = g_dmgateData:getStageName(stage_id)

    -- local diff_color = g_dmgateData:getStageDiffColorStr(stage_id)
    -- local diff_name = g_dmgateData:getStageDiffText(stage_id)
    --local diff_color = g_dmgateData:getStageDiffTextColor(stage_id)
    -- if diff_name ~= '' then
    --     diff_name = diff_name .. ' '
    -- end

    vars['stepLabel']:setString(Str("클랜 던전 점수"))
    vars['raidScoreLabel']:setString(comma_value(stage_score))
    --vars['levelLabel']:setTextColor(diff_color)
    

    local item_list = ServerData_Item:parsePackageItemStr(self.m_data['reward'])


    for i, v in pairs(item_list) do
        local card = UI_ItemCard(v['item_id'], v['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode1']:addChild(card.root)
    end
end

----------------------------------------------------------------------
-- function initButton
----------------------------------------------------------------------
function UI_Package_ClanRaid_FireListItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

----------------------------------------------------------------------
-- function refresh
----------------------------------------------------------------------
function UI_Package_ClanRaid_FireListItem:refresh()
    local vars = self.vars

    local product_id = self.m_data['product_id']
    local isPackagePurchased = g_clanDungeonFirePackageData:isPackageActive(product_id)

    if (not isPackagePurchased) then
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setEnabled(false)

        return
    end

    local dungeon_score = self.m_data['achive_2']
    local isRewardReceived = g_clanDungeonFirePackageData:isRewardReceived(product_id, dungeon_score)
    
    local curr_score = g_clanRaidData:getClanDungeonFireScore()
    
    local isOverScore = (curr_score >= dungeon_score)

    vars['receiveSprite']:setVisible(isRewardReceived)
    vars['rewardBtn']:setEnabled((not isRewardReceived) and isOverScore)

    -- if vars['rewardBtn']:isEnabled() then
    --     vars['infoLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
    -- else
    --     vars['infoLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    -- end
end


----------------------------------------------------------------------
-- function click_rewardBtn
----------------------------------------------------------------------
function UI_Package_ClanRaid_FireListItem:click_rewardBtn()
    local product_id = self.m_data['product_id']
    local dunegon_score = self.m_data['achive_2']

    
    local function success_cb(ret)
        self:refresh()

        ItemObtainResult_Shop(ret)
    end

    local function fail_cb(ret)
        UIManager:toastNotificationRed(Str('잘못된 요청입니다.'))

        UINavigator:goTo('lobby')
    end
    
    g_clanDungeonFirePackageData:request_reward(product_id, dunegon_score, success_cb, fail_cb)
end