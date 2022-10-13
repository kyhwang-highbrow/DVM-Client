local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
---@class UI_DiaShopPopupItem
-------------------------------------
UI_DiaShopPopupItem = class(PARENT, {
    m_structProduct = 'structProduct',

    m_elapsedTime = 'number',
})

-------------------------------------
-- function init
---@param struct_product StructProduct
-------------------------------------
function UI_DiaShopPopupItem:init(struct_product)
    self.m_uiName = 'UI_DiaShopPopupItem'
    self.m_resName = 'shop_package_list_02.ui'

    self.m_structProduct = struct_product
    self.m_elapsedTime = 1
end

-------------------------------------
-- function init
-------------------------------------
function UI_DiaShopPopupItem:init_after()
    local vars = self:load(self.m_resName)

	-- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)    

    self:initUI()
	self:initButton()
    self:refresh()

    if vars['timeLabel'] then
        self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    end
end

-------------------------------------
-- function init
-------------------------------------
function UI_DiaShopPopupItem:initUI()
    local vars = self.vars
    local struct_product = self.m_structProduct

    -- 상품 이름
    local node = vars['itemLabel']
    if node then
        local product_name = struct_product:getProductName()
        node:setString(product_name)
    end

    -- 상품 설명
    local node = vars['descLabel']
    if node then
        local product_name = struct_product:getProductDesc()
        node:setString(product_name)
    end

    -- 아이콘 노드
    node = vars['iconNode']
    if node then
        node:removeAllChildren()

        local icon = struct_product:makeProductIcon()

        if icon then
            node:addChild(icon)
        end
    end

    -- 뱃지 아이콘 추가
    node = vars['badgeNode']
    if node then
        node:removeAllChildren()
        local badge_icon = struct_product:makeBadgeIcon()
        if badge_icon then
            node:addChild(badge_icon)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DiaShopPopupItem:initButton()
    local vars = self.vars

    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DiaShopPopupItem:refresh()
    local vars = self.vars
    local struct_product = self.m_structProduct

    -- 구매 제한
    local node = vars['buyLabel']
    if node then
        local buy_term_str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local color_key = struct_product:isBuyAll() and '{@impossible}' or '{@available}'
        node:setString(color_key .. buy_term_str)

        -- 구매가 불가능한 경우 구매 완료 출력
    end

    -- 가격
    node = vars['priceLabel']
    if node then
        local price_str = struct_product:getPriceStr()
        node:setString(price_str)
    end
end

-------------------------------------
---function update
---@param dt number
-------------------------------------
function UI_DiaShopPopupItem:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime < 1) then
        return
    end

    local vars = self.vars
    self.m_elapsedTime = 0

    if vars['timeLabel'] then
        cclog('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
        ccdump(self.m_structProduct:getEndDateStr())
        vars['timeLabel']:setString(self.m_structProduct:getEndDateStr())
    end
end 

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_DiaShopPopupItem:click_buyBtn()
    local struct_product = self.m_structProduct

    local function cb_func(ret)
        self:refresh()
    end

    struct_product:buy(cb_func)
end