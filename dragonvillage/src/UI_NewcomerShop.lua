local PARENT = UI

-------------------------------------
-- class UI_NewcomerShop
-- @brief 초보자 선물 (신규 유저 전용 상점)
-------------------------------------
UI_NewcomerShop = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_NewcomerShop:init()
    self.m_uiName = 'UI_NewcomerShop'
    
    local ui_res = 'newcomer_shop.ui'
    local vars = self:load(ui_res)
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_NewcomerShop')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_NewcomerShop:initUI()
    local vars = self.vars

    -- 상품 리스트 받아옴 (TODO: 실제 적용된 ncm_id로 수정할 것)
    require('TableNewcomerShop')
    local l_product_id = TableNewcomerShop:getNewcomerShopProductList(10001)

    -- 개별 상품 생성
    for i,product_id in ipairs(l_product_id) do
        local node = vars['itemNode' .. i]
        self:makeNewcomerShopProductUI(node, product_id)
    end
end

-------------------------------------
-- function makeNewcomerShopProductUI
-- @brief 초보자 선물 개별 상품 UI 생성
-------------------------------------
function UI_NewcomerShop:makeNewcomerShopProductUI(parent_node, product_id)
    if (not parent_node) then
        return
    end
    parent_node:removeAllChildren()

    local struct_product = g_shopDataNew:getTargetProduct(product_id)
    if (not struct_product) then
        return
    end

    require('UI_ProductNewcomerShop')
    local ui = UI_ProductNewcomerShop(struct_product)
    ui:setBuyCB(function() self:makeNewcomerShopProductUI(parent_node, product_id) end) -- 상품 구매 후 콜백. 구매 제한 내용 갱신을 위해 UI 다시 생성
    parent_node:addChild(ui.root)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_NewcomerShop:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_NewcomerShop:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_NewcomerShop:update(dt)
    local vars = self.vars
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_NewcomerShop:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_NewcomerShop)
