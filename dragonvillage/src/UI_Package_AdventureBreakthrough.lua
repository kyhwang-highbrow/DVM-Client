local PARENT = UI_Package


-------------------------------------
-- class UI_Package_AdventureBreakthrough
-------------------------------------
UI_Package_AdventureBreakthrough = class(PARENT,{

})

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureBreakthrough:init(struct_product_list, is_popup, package_name)
    
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureBreakthrough:initUI()
    PARENT.initUI(self)

    self:init_tableView()
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureBreakthrough:initButton()
    PARENT.initButton(self)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureBreakthrough:refresh()
    PARENT.refresh(self)
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_Package_AdventureBreakthrough:init_tableView()
    local vars = self.vars
    local node

    if (g_adventureBreakthroughPackageData:isActive() == true) then
        node = vars['productNodeLong']
    else
        node = vars['productNode']
    end

    local product_id = self.m_structProduct:getProductID()
    local reward_list = g_adventureBreakthroughPackageData:getRewardListFromProductId(product_id)
    

    local function ctor_func(data)
        
        local index = g_adventureBreakthroughPackageData:getIndexFromProductId(product_id)
        if (index == 1) then
            data['res_name'] = 'package_adventure_clear_item.ui'
        else
            data['res_name'] = string.format('package_adventure_clear_item_%02d.ui', index)
        end
        data['product_id'] = product_id
        
        return UI_Package_AdventureBreakthroughItem(data)
    end

    local function create_func(ui, data)
        --ui.m_productId = product_id
    end

    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(490, 80+5)
    --table_view:setCellSizeToNodeSize(true)
    table_view:setCellUIClass(ctor_func, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    
    table_view:setItemList(reward_list)

    -- 리스트가 비었을 때
    table_view:makeDefaultEmptyDescLabel('')

    -- -- 보상 받기 가능한 idx로 이동
    -- local stage_id, idx = g_adventureClearPackageData03:getFocusRewardStage()
    -- if stage_id then
    --     table_view:update(0) -- 강제로 호출해서 최초에 보이지 않는 cell idx로 이동시킬 position을 가져올수 있도록 한다.
    --     table_view:relocateContainerFromIndex(idx, false)
    -- end
end











-------------------------------------
-- class UI_Package_AdventureBreakthroughItem
-------------------------------------
UI_Package_AdventureBreakthroughItem = class(class(UI, ITableViewCell:getCloneTable()), {
    m_data = 'table',
    m_productId = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_Package_AdventureBreakthroughItem:init(data)
--     {
--         ['stage']=1120607;
--         ['res_name']='package_adventure_clear_item_03.ui';
--         ['product_content']='';
--         ['mail_content']='700001;3000';
--         ['mission1']=1;
--         ['mission2']=1;
--         ['mission3']=1;
-- }
    self.m_data = data
    self.m_productId = data['product_id']

    local res_name = data['res_name']
    local vars = self:load(res_name)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_AdventureBreakthroughItem:initUI()
    local vars = self.vars
    local t_data = self.m_data

    -- 스테이지
    local stage_id = t_data['stage']
    local stage_info = g_adventureData:getStageInfo(stage_id) -- StructAdventureStageInfo
    local str = stage_info:getStageRichName()
    vars['levelLabel']:setString(str)

    local reward_list = {}

    local product_content = ServerData_Item:parsePackageItemStr(t_data['product_content'])
    for i,v in ipairs(product_content) do
        table.insert(reward_list, v)
    end

    local mail_content = ServerData_Item:parsePackageItemStr(t_data['mail_content'])
    for i,v in ipairs(mail_content) do
        table.insert(reward_list, v)
    end

    for i,v in ipairs(reward_list) do
        local card = UI_ItemCard(v['item_id'], v['count'])
        card.root:setSwallowTouch(false)
        vars['itemNode' .. i]:addChild(card.root)
    end
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_AdventureBreakthroughItem:initButton()
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
    vars['linkBtn']:registerScriptTapHandler(function() self:click_linkBtn() end)
end


-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_AdventureBreakthroughItem:refresh()
    local vars = self.vars
    local data = self.m_data

    do -- 획득한 별 표시
        local stage_id = data['stage']
        local stage_info = g_adventureData:getStageInfo(stage_id)
        local star = stage_info:getNumberOfStars()
        for i = 1, 3 do
            local node = vars['starSprite' .. i]
            if node then
                node:setVisible(i <= star)
            end
        end
    end

    -- 구매 전
    if (g_adventureBreakthroughPackageData:isActive(self.m_productId) == false) then
        -- 버튼 
        vars['receiveSprite']:setVisible(false)
        vars['rewardBtn']:setVisible(true)
        vars['rewardBtn']:setEnabled(false)
    -- 구매 후
    else
        local stage_id = data['stage']

        -- 보상을 받았으면
        if (g_adventureBreakthroughPackageData:isReceivedReward(self.m_productId, stage_id) == true) then
            vars['receiveSprite']:setVisible(true)
            vars['rewardBtn']:setVisible(false)
            vars['linkBtn']:setVisible(false)
        -- 보상을 받지 않았으면
        else
            vars['receiveSprite']:setVisible(false)

            -- 보상을 받을 수 있으면
            if (g_adventureBreakthroughPackageData:isReceivableReward(self.m_productId, stage_id) == true) then
                vars['rewardBtn']:setVisible(true)
                vars['rewardBtn']:setEnabled(true)
                vars['linkBtn']:setVisible(false)

            -- 보상을 받을 수 없으면
            else
                vars['rewardBtn']:setVisible(false)
                vars['linkBtn']:setVisible(true)
            end
        end

    end

    if vars['rewardBtn']:isEnabled() then
        vars['infoLabel']:setTextColor(cc.c4b(0, 0, 0, 255))
    else
        vars['infoLabel']:setTextColor(cc.c4b(240, 215, 159, 255))
    end
end


-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_Package_AdventureBreakthroughItem:click_rewardBtn()
    local data = self.m_data
    local stage_id = data['stage']

    if (g_adventureBreakthroughPackageData:isReceivableReward(self.m_productId, stage_id) == false) then
        UIManager:toastNotificationRed(Str('별 3개로 클리어 시 보상을 획득할 수 있습니다.'))
        return
    end

    local function cb_func(ret)
        self:refresh()

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
    end

    g_adventureBreakthroughPackageData:request_reward(self.m_productId, stage_id, cb_func)
end

-------------------------------------
-- function click_linkBtn
-- @brief 스테이지 바로가기 버튼
-------------------------------------
function UI_Package_AdventureBreakthroughItem:click_linkBtn()
    local data = self.m_data
    local stage_id = data['stage']
    UINavigator:goTo('adventure', stage_id)
end