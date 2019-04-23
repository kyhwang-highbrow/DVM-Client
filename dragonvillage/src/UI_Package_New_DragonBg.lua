
-------------------------------------
-- function openPackage_New_Dragon
-------------------------------------
function openPackage_New_Dragon(struct_product, premier_item_id, product_cnt)
    local ui_res = 'package_new_dragon_item_01.ui'
    local ui_bg = nil

    -- 상품 갯수에 따라 다른 크기로 된 UI 사용
    if (product_cnt == 2) then
        ui_res = 'package_new_dragon_item_01.ui'
    elseif (product_cnt == 3) then
        ui_res = 'package_new_dragon_item_02.ui'
    end

    ui_bg = UI_Package_New_DragonBg(struct_product, ui_res, premier_item_id)

    -- 대표 상품이 소환권, 드래곤인지 구분
    if (ui_bg) then
        local premier_item_type = TableItem:getItemType(premier_item_id)
        if (premier_item_type == 'summon') then
            ui_bg:setDragonTicket()
        elseif (premier_item_type == 'dragon') then
            ui_bg:setDragon()   
        end
    end
    
    return ui_bg
end




local PARENT = UI

-------------------------------------
-- class UI_Package_New_DragonBg
-- @todo UI_Package 상속받도록 수정할 것
-------------------------------------
UI_Package_New_DragonBg = class(PARENT,{
        m_struct_product = 'StructProduct',
        m_premier_item_id = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_New_DragonBg:init(struct_product, ui_res, premier_item_id)
    self:load(ui_res)
    self.m_struct_product = struct_product
    self.m_premier_item_id = premier_item_id
    
    self:doActionReset()
    self:doAction(nil, false)
    self:refresh()
    self:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_New_DragonBg:refresh()
    local vars = self.vars
    local struct_product = self.m_struct_product

    local l_item_list = ServerData_Item:parsePackageItemStr(struct_product['mail_content'])
    local item_str = ''
    
    -- 구성품 설명 라벨
    if (l_item_list) then
        for idx, data in ipairs(l_item_list) do
            local name = TableItem:getItemName(data['item_id'])
            local cnt = data['count']
            local get_label_color = self:getLabelColor(data['item_id'])
            item_str = item_str .. get_label_color .. Str('{1} {2}개', name, comma_value(cnt)) .. '\n'
        end

        local label = vars['itemLabel']
        label:setString(item_str)
    end

    -- 구매 제한
    if vars['buyLabel'] then
        local str = struct_product:getMaxBuyTermStr()
        -- 구매 가능/불가능 텍스트 컬러 변경
        local is_buy_all = struct_product:isBuyAll()
        local color_key = is_buy_all and '{@impossible}' or '{@available}'
        local rich_str = color_key .. str
        vars['buyLabel']:setString(rich_str)
        
        -- 구매 불가능할 경우 '구매완료' 출력
        if (vars['completeNode']) then
            vars['completeNode']:setVisible(is_buy_all)
        end
    end
	
    -- 가격
    if vars['priceLabel'] then
	    local price = struct_product:getPriceStr()
        vars['priceLabel']:setString(price)
    end

    -- 상품이 드래곤이라면 노드에 해당 드래곤 출력
    local item_id = self.m_premier_item_id
    local dragon_id = TableItem:getDidByItemId(item_id)
    if (dragon_id ~= '') then
        local dragon_animator = UIC_DragonAnimator()
        dragon_animator:setDragonAnimator(tonumber(dragon_id), 3)
        dragon_animator:setTalkEnable(false)
        dragon_animator:setIdle()
        
        if (self.vars['dragonNode']) then
            self.vars['dragonNode']:addChild(dragon_animator.m_node)
            self.vars['dragonNodeMenu']:setVisible(true)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_New_DragonBg:initButton()
   local vars = self.vars
   
   if (vars['buyBtn']) then
        vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
   end

   if (vars['dragonInfoBtn']) then
        vars['dragonInfoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
   end

   if (vars['summonInfoBtn']) then
        vars['summonInfoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
   end
end

function UI_Package_New_DragonBg:setDragonTicket()
    local vars = self.vars
    local item_id = self.m_premier_item_id
    
    vars['dragonMenu']:setVisible(false)
    vars['summonMenu']:setVisible(true)
    
    -- 소환권 아이템 카드
    local ui_card = UI_ItemCard(item_id, 0)
    ui_card.root:setScale(0.66)
    if (vars['itemNode']) then
        vars['itemNode']:addChild(ui_card.root)
    end
end

function UI_Package_New_DragonBg:setDragon()
    local vars = self.vars

    vars['dragonMenu']:setVisible(true)
    vars['summonMenu']:setVisible(false)
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_New_DragonBg:click_buyBtn()
	local struct_product = self.m_struct_product

	local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)

        -- 갱신이 필요한 상태일 경우
        if ret['need_refresh'] then
            self:refresh()
            g_eventData.m_bDirty = true
		end
	end

	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_Package_New_DragonBg:click_infoBtn()
    local premier_item_type = TableItem:getItemType(self.m_premier_item_id)
    local did = TableItem:getDidByItemId(self.m_premier_item_id)

	if (premier_item_type == 'dragon') then
        UI_BookDetailPopup.openWithFrame(did, nil, 1, 0.8, true)    -- param : did, grade, evolution scale, ispopup
    elseif (premier_item_type == 'summon') then
        UI_SummonDrawInfo(self.m_premier_item_id, false) -- item_id, is_draw
    end
end

-------------------------------------
-- function getLabelColor
-------------------------------------
function UI_Package_New_DragonBg:getLabelColor(item_id)
    local label_color = '{@default}'
    local did = TableItem:getDidByItemId(item_id)
    if (did == '') then
        return label_color
    end
    local attr = TableDragon:getDragonAttr(did)
    return string.format('{@%s}', attr)
end
