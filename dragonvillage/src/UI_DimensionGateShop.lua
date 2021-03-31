--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--// 
--////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////////////////////
local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())


UI_DimensionGateShop = class(PARENT, {
    m_dragonNode = '',
    m_relationNode = '',
    m_listNode = '',
    m_npcNode = '',

})


-------------------------------------
-- function init
-------------------------------------
function UI_DimensionGateShop:init() 
    local vars = self:load('dmgate_shop.ui')
    UIManager:open(self, UIManager.SCENE)

    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_DimensionGateShop')

    local function coroutine_function()
        local co = CoroutineHelper()
        co:work('# 차원문 상점 정보 받는 중')
        g_dimensionGateData:request_shopInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:close()

        self:doActionReset()
        self:doAction(nil, false)

        self:initMember()
        self:initUI()
        self:initButton()
        self:refresh()
    end

    Coroutine(coroutine_function, "DimensionGate Shop UI Coroutine")
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateShop:initMember() 
    local vars = self.vars

    self.m_dragonNode = vars['dragonNode']
    self.m_listNode = vars['listNode']
    self.m_relationNode = vars['relationNode']

end
-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateShop:initUI() 
    local vars = self.vars
    

    do -- 나르비 테이머 추가
        local res = 'res/character/npc/arahan/arahan.json'
        self.m_dragonNode:removeAllChildren(true)
        local animator = MakeAnimator(res)
        if (animator.m_node) then
            animator:changeAni('idle', true)
            self.m_dragonNode:addChild(animator.m_node)
        end
    end

    self:initTableView()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DimensionGateShop:initButton() 

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DimensionGateShop:refresh() 

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DimensionGateShop:initTableView() 
    local vars = self.vars

    self.m_listNode:removeAllChildren()

    local product_list = g_dimensionGateData:getShopInfoProductList(DIMENSION_GATE_MANUS)

    local function create_callback(ui, data)
    end

    -- create TableView
    local table_view = UIC_TableViewTD(self.m_listNode)
    --table_view:setCellSizeToNodeSize(true)
    table_view.m_cellSize = cc.size(225, 275)
    table_view.m_nItemPerCell = 3
    table_view:setCellUIClass(UI_DimensionGateShopItem, create_callback)
    
    table_view:setItemList(product_list)
end




-------------------------------------
-- function initParentVariable
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:initParentVariable()
    self.m_uiName = 'UI_DimensionGateShop'
    self.m_titleStr = Str('차원문 상점')
    self.m_subCurrency = 'medal_angra' -- 
    self.m_bVisible = true
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function onClose
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:onClose() 
    self:releaseI_TopUserInfo_EventListener()
    g_currScene:removeBackKeyListener(self)
end
-------------------------------------
-- function onFocus
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:onFocus() 

end


-------------------------------------
-- function click_exitBtn
-- @brief pure virtual function of ITopUserInfo_EventListener 
-------------------------------------
function UI_DimensionGateShop:click_exitBtn()
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
-- function UI_DimensionGateShopItem
-------------------------------------
UI_DimensionGateShopItem = class(PARENT, {
    m_itemData = '',

    -- nodes in ui
    m_itemNode = '',            -- 
    m_descriptionLabel = '',    -- 
    m_maxProductNumLabel = '',  -- 
    m_itemLabel = '',           -- 

    m_buyBtn = '',              -- 
    m_priceLabel = '',          -- 
})


-------------------------------------
-- function UI_DimensionGateShopItem
-------------------------------------
function UI_DimensionGateShopItem:init(data)
    local vars = self:load('dmgate_shop_item.ui')
    self.m_itemData = data
    self.m_itemNode = vars['itemNode']
    self.m_descriptionLabel = vars['dscLabel']
    self.m_maxProductNumLabel = vars['maxBuyTermLabel']
    self.m_itemLabel = vars['itemLabel']


    self.m_buyBtn = vars['buyBtn']
    self.m_priceLabel = vars['priceLabel']

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function UI_DimensionGateShopItem
-------------------------------------
function UI_DimensionGateShopItem:initUI()

    self.m_itemLabel:setString(self.m_itemData['t_name']) -- 상품 이름
    
    local parsedItem = ServerData_Item:parsePackageItemStr(self.m_itemData['product_content'])[1]


    -- -- 룬인 경우 능력치 표시
    -- if (self:isRuneItem()) then
    --     t_sub_data = self:getRuneData()
    -- end
    --ccdump(parsedItem)
    local card = UI_ItemCard(parsedItem['item_id'], parsedItem['count'])
    self.m_itemNode:addChild(card.root)
    


    self.m_descriptionLabel:setString(self.m_itemData['t_desc'])
    
    
    self.m_priceLabel:setString(tostring(self.m_itemData['price']))

    
    local maxCount = self.m_itemData['max_buy_count']
    local productCount = g_dimensionGateData:getProductCount(DIMENSION_GATE_MANUS, self.m_itemData['product_id'])
    if productCount == nil or maxCount == '' then
        self.m_maxProductNumLabel:setVisible(false)
    else
        self.m_maxProductNumLabel:setString(string.format('%d / %d', productCount, maxCount))
    end
end

-------------------------------------
-- function UI_DimensionGateShopItem
-------------------------------------
function UI_DimensionGateShopItem:initButton()
    self.m_buyBtn:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function UI_DimensionGateShopItem
-------------------------------------
function UI_DimensionGateShopItem:refresh()

end


-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DimensionGateShopItem:click_buyBtn()

    local item_data = TABLE:get('item')[tonumber(self.m_itemData['medal'])]
    local item_type = item_data['type']

    -- 재화 부족
    if ConfirmPriceByItemID(self.m_itemData['medal'], self.m_itemData['price']) == false then
       return 
    end

    local function buy_callback_func(ret)
        ItemObtainResult_Shop(ret)

    end
    local function ok_button_callback()
        local product_id = self.m_itemData['product_id']
        local count = 1--self.m_itemData['bundle']
        g_dimensionGateData:request_buy(product_id, count, buy_callback_func)
    end

    local name = self.m_itemData['t_name']
    local count = 1
    local msg = Str('{@item_name}"{1} x{2}"\n{@default}구매하시겠습니까?', name, count)

    UI_ConfirmPopup(item_type, self.m_itemData['price'], msg, ok_button_callback)
end