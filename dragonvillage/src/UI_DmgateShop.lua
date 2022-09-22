--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())


UI_DmgateShop = class(PARENT, {
    m_modeId = 'number',
    m_dragonNode = '',
    m_relationNode = '',
    m_listNode = '',
    m_npcNode = '',

    m_productTableview = '',

    m_relationUI = '',
})


-------------------------------------
-- function init
-------------------------------------
function UI_DmgateShop:init(mode_id) 
    self.m_modeId = mode_id
    local vars = self:load('dmgate_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DmgateShop')
    
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

    -- local function coroutine_function()
    --     local co = CoroutineHelper()
    --     co:work('# 차원문 상점 정보 받는 중')
    --     g_dmgateData:request_shopInfo(co.NEXT, co.ESCAPE)
    --     if co:waitWork() then return end

    --     co:close()

    --     self:initMember()
    --     self:initUI()
    --     self:initButton()
    --     self:refresh()
    -- end

    -- Coroutine(coroutine_function, "DimensionGate Shop UI Coroutine")
    
    self:initMember()
    self:initUI()
    self:initButton()
    self:refresh()

    
    -- 시즌 타이머
    self:scheduleUpdate(function(dt) self:update(dt) end, 1, true)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DmgateShop:initMember() 
    local vars = self.vars

    self.m_dragonNode = vars['dragonNode']
    self.m_listNode = vars['listNode']
    self.m_relationNode = vars['relationNode']

end
-------------------------------------
-- function initUI
-------------------------------------
function UI_DmgateShop:initUI() 
    local vars = self.vars
    local dragon_id = 120742

    local resource_spine = TableDragon:getDragonRes(dragon_id) -- 'res/character/dragon/angra_water_03/angra_water_03.spine'
    local resource_json = string.gsub(resource_spine, '.spine', '.json')
    

    do -- 앙그라 추가
        self.m_dragonNode:removeAllChildren(true)
        local animator = MakeAnimator(resource_json) -- 'res/character/dragon/angra_water_03/angra_water_03.spine'
        if (animator.m_node) then
            animator:changeAni('idle', true)
            animator:setTimeScale(0.5)
            self.m_dragonNode:addChild(animator.m_node)
        end
    end

    do -- 
        -- 데이터
        local t_data = {
            ['did'] = dragon_id,
            ['grade'] = TableDragon:getBirthGrade(dragon_id)
        }
        local struct_dragon = StructDragonObject(t_data)

        -- 카드 생성
        local ui = UI_DragonReinforceItem('dragon', struct_dragon)
        local card = ui.m_card
        ui:showMaxRelationPoint()
        self.m_relationUI = ui
        self.m_relationNode:addChild(ui.root)
        
        card.vars['clickBtn']:setEnabled(true)
    end

    self:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DmgateShop:initButton() 

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DmgateShop:refresh()
    if self.m_relationUI then
        self.m_relationUI:refresh()
    end

    if self.m_productTableview then
        self.m_productTableview:refreshAllItemUI()
    end
end

----------------------------------------------------------------------
-- function update
----------------------------------------------------------------------
function UI_DmgateShop:update(dt)
    if (g_dmgateData:isActive() == false) then 
        g_dmgateData:MakeSeasonEndedPopup()
        self.root:unscheduleUpdate()
    end
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_DmgateShop:initTableView() 
    local vars = self.vars

    self.m_listNode:removeAllChildren()

    local product_list = g_dmgateData:getShopInfoProductList()

    local function create_callback(ui, data)
        -- ui.m_buyBtn:registerScriptTapHandler(function() 
        --     self:click_buyBtn(ui.m_itemData)
        --     -- cca.reserveFunc(self.m_relationNode, 0.25, 
        --     --     function() self:refresh() end)
        --     self:refresh()
        -- end)

        --ui.m_buyCallbackFun = self.refresh
        ui.m_parent = self
    end

    -- create TableView
    local table_view = UIC_TableViewTD(self.m_listNode)
    --table_view:setCellSizeToNodeSize(true)
    table_view.m_cellSize = cc.size(225 + 5, 275 + 5)
    table_view.m_nItemPerCell = 3
    table_view:setCellUIClass(UI_DmgateShopItem, create_callback)
    
    table_view:setItemList(product_list)
    table_view.m_scrollView:setTouchEnabled(false)

    self.m_productTableview = table_view
end




-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DmgateShop:initParentVariable()
    self.m_uiName = 'UI_DmgateShop'
    self.m_titleStr = Str('차원문 상점')
    self.m_subCurrency = 'medal_angra' -- 
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DmgateShop:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end
-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DmgateShop:onFocus() 

end


-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DmgateShop:click_exitBtn()
   self:close()
end




--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
local PARENT = class(UI, ITableViewCell:getCloneTable())


-- ['max_buy_count']='';
-- ['t_name']='마누스(불) 인연 포인트';
-- ['lock']='';
-- ['badge']='';
-- ['medal']=700901;
-- ['product_content']='relation_point;761064;1';
-- ['t_desc']='드래곤과의 인연의 깊이를 나타내는 포인트. 드래곤 소환, 강화에 사용할 수 있다.';
-- ['bundle']=1;
-- ['max_buy_term']='';
-- ['product_id']=10102;
-- ['price']=20;
-------------------------------------
-- function UI_DmgateShopItem
-------------------------------------
UI_DmgateShopItem = class(PARENT, {
    m_itemData = '',

    -- nodes in ui
    m_itemNode = '',            -- 
    m_descriptionLabel = '',    -- 
    m_maxProductNumLabel = '',  -- 
    m_itemLabel = '',           -- 

    m_buyBtn = '',              -- 
    m_priceLabel = '',          -- 
    --m_priceMenu = '',

    m_buyCallbackFun = '',
    m_parent = '',
})


-------------------------------------
-- function UI_DmgateShopItem
-------------------------------------
function UI_DmgateShopItem:init(data)
    local vars = self:load('dmgate_shop_item.ui')
    self.m_itemData = data
    self.m_itemNode = vars['itemNode']
    self.m_descriptionLabel = vars['dscLabel']
    self.m_maxProductNumLabel = vars['maxBuyTermLabel']
    self.m_itemLabel = vars['itemLabel']


    self.m_buyBtn = vars['buyBtn']
    self.m_priceLabel = vars['priceLabel']
    --self.m_priceMenu = vars['priceMenu']

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function UI_DmgateShopItem
-------------------------------------
function UI_DmgateShopItem:initUI()
    local vars = self.vars
    self.m_itemLabel:setString(Str(self.m_itemData['t_name'])) -- 상품 이름
    
    local parsedItem = ServerData_Item:parsePackageItemStr(self.m_itemData['product_content'])[1]
    
    -- -- 룬인 경우 능력치 표시
    -- if (self:isRuneItem()) then
    --     t_sub_data = self:getRuneData()
    -- end

    local card = UI_ItemCard(parsedItem['item_id'], parsedItem['count'])
    self.m_itemNode:addChild(card.root)
    


    self.m_descriptionLabel:setString(Str(self.m_itemData['t_desc']))
    
    
    self.m_priceLabel:setString(tostring(self.m_itemData['price']))
    
    UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])

end

-------------------------------------
-- function UI_DmgateShopItem
-------------------------------------
function UI_DmgateShopItem:initButton()
    self.m_buyBtn:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function UI_DmgateShopItem
-------------------------------------
function UI_DmgateShopItem:refresh()
    local maxCount = self.m_itemData['max_buy_count']
    local productCount = g_dmgateData:getProductCount(self.m_itemData['product_id'])
    if productCount == nil or maxCount == '' then
        self.m_maxProductNumLabel:setVisible(false)
    else
        --self.m_maxProductNumLabel:setString(string.format('%d / %d', productCount, maxCount))
        self.m_maxProductNumLabel:setString(self.m_itemData:getBuyCountDesc())
        if (productCount >= maxCount) then
            self.m_maxProductNumLabel:setTextColor(cc.c4b(233, 0, 0, 255))
        end
    end
end


-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DmgateShopItem:click_buyBtn()
    -- 재화 부족
    -- if ConfirmPriceByItemID(self.m_itemData['medal'], self.m_itemData['price']) == false then
    --    return 
    -- end
    if (not self.m_itemData:isBuyable()) then
        return
    end

    local function buy_callback_func(ret)
        ItemObtainResult_Shop(ret)
        
        if (self.m_parent) then
            self.m_parent:refresh()
        end

        self:refresh()
    end

    self.m_itemData:buy(buy_callback_func)
end