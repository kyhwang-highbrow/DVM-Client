local PARENT = UI_Product--class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_ProductDragonSkin
-------------------------------------
UI_ProductDragonSkin = class(PARENT, {
    m_structSkinSale = 'StructProduct',
    m_cbBuy = 'function',
})

-------------------------------------
-- function init
-------------------------------------
function UI_ProductDragonSkin:init(struct_product)
    -- shop_package_list_02.ui 복사
    local vars = self:load('package_dargon_skin_item.ui')    
    self.m_structProduct = struct_product
    self:initItemNodePos()
    self:initUI()
	self:initButton()
	self:refresh()
end

--[[ -- -------------------------------------
-- -- function initItemNodePos
-- -- @brief 상품명, 설명 등의 위치와 크기 조정
-- -------------------------------------
function UI_ProductDragonSkin:initItemNodePos()
end ]]

-------------------------------------
-- function initButton
-------------------------------------
function UI_ProductDragonSkin:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ProductDragonSkin:refresh()
    local vars = self.vars
    PARENT.refresh(self)    

--[[     local item_id = v['item_id']
    local count = v['count']

    local ui = UI_ItemCard(item_id, count)
    ui.root:setSwallowTouch(false)
    ui.root:setPositionX((i-1) * -150) ]]

    --vars['priceLabel']:setString(Str('구매하기'))
    vars['priceLabel']:setVisible(false)
    vars['priceNode']:removeAllChildren()
    -- 가격 아이콘 및 라벨, 배경 조정
    UIHelper:makePriceNodeVariable(vars['priceBg'],  vars['priceNode'], vars['priceLabel'])
    vars['moneyLabel']:setString(Str('구매하기'))
end

-------------------------------
-- function click_buyBtn
-------------------------------------
function UI_ProductDragonSkin:click_buyBtn()
	local struct_product = self.m_structProduct

--[[     -- @jhakim 190701
    -- 닉네임 변경권 구입전에 (신규유저라면 무료 변경 가능하다는) 팝업 띄워줘야 해서 구매 전 조건 체크 함수 추가
    -- 원래는 struct_product:buy 함수에서 일괄적으로 체크하는 것이 맞으나, 작은 일로 buy함수 건들기 위험해서 이쪽에 추가, 후에 구매 전 조건 체크가 필요하다면 함수 옮기는 것을 추천 
    local product_id = struct_product:getProductID()
    if (self:canNotBuy(product_id)) then
        return
    end


	if (struct_product:getTabCategory() == 'package') then
        local is_popup = true
		local ui = PackageManager:getTargetUI(struct_product, is_popup)
        ui:setCloseCB(function() self:refresh() end)
        ui:setBuyCB(self.m_cbBuy)

    -- 광고 시청
    elseif (struct_product.price_type == 'advertising') then
        if (not g_advertisingData:getEnableShopAdv()) then
            return
        end
        g_advertisingData:showAdvPopup(AD_TYPE.RANDOM_BOX_LOBBY, function() self:refresh() end)

	else
        local function cb_func(ret)
            if (self.m_cbBuy) then
                self.m_cbBuy(ret)
            end

            -- 다이아 상품인 경우는 구매후 우편함 바로 보여줌
            if (struct_product:getTabCategory() == 'cash') then
                UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOODS)

            else
                -- 코스튬 상점 구매 결과창
                if (self:isCostumeInStore()) then
                    self:obtainResultPopup_costume()
                else
                    -- 아이템 획득 결과창
                    ItemObtainResult_Shop(ret)
                end
            end
        end
        
		struct_product:buy(cb_func)
	end ]]
end

--[[ -------------------------------------
-- function adjustLayout
-- @brief 상품명, 설명 등의 위치와 크기 조정
-------------------------------------
function UI_ProductDragonSkin:adjustLayout()
    local vars = self.vars

    do -- 상품 이름 (시스템 폰트)
        local width = 244
        local str_width = vars['itemLabel']:getStringWidth()
        if (width < str_width) then
            local scale = (width / str_width)

            -- 상점에서 번역텍스트가 매우 길 때 두줄로 나올 때가 있는데
            -- 비율로 맞추기만 하면 기한 텏스트랑 겹쳐서
            -- 0.6 싸이즈로 했더니 딱 맞아서 일단 급해서 이렇게 함...
            if (g_localData:getLang() == 'es') then
                scale = 0.6
            end

            vars['itemLabel']:setScale(scale)
        end
    end
end ]]