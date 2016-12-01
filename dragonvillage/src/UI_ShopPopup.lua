local PARENT = UI

-------------------------------------
-- class UI_ShopPopup
-------------------------------------
UI_ShopPopup = class(PARENT, ITopUserInfo_EventListener:getCloneTable(), {
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ShopPopup:init()
    local vars = self:load('shop_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self:initProductList()

    self:doActionReset()
    self:doAction()

    -- 백키 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ShopPopup')
end

-------------------------------------
-- function initParentVariable
-- @brief
-------------------------------------
function UI_ShopPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ShopPopup'
    self.m_titleStr = Str('상점')
    self.m_bUseExitBtn = true
end

-------------------------------------
-- function initProductList
-- @brief
-------------------------------------
function UI_ShopPopup:initProductList()
    local table_shop = TABLE:get('shop')

    local l_pos = getSortPosList(260, #table_shop)

    for i,v in ipairs(table_shop) do
        local product_button = UI_ProductButton(self, i)
        self.root:addChild(product_button.root)

        local pos_x = l_pos[i]
        product_button.root:setPositionX(pos_x)
    end
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ShopPopup:click_exitBtn()
    self:close()
end

-------------------------------------
-- function openShopPopup
-- @brief
-------------------------------------
function openShopPopup()
    UI_ShopPopup()
end