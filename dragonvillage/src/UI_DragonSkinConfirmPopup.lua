local PARENT = UI

-------------------------------------
-- class UI_DragonSkinConfirmPopup
-------------------------------------
UI_DragonSkinConfirmPopup = class(PARENT,{
        m_dragonSkinData = 'StructDragonSkin'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_DragonSkinConfirmPopup:init(costume_data)
    local vars = self:load('tamer_costume_buy_popup.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_dragonSkinData = costume_data

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_DragonSkinConfirmPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_DragonSkinConfirmPopup:initUI()
    local vars = self.vars
    local costume_data = self.m_dragonSkinData
    local table_tamer = TableTamer()
    local tamer_id = costume_data:getTamerID()
    local costume_id = costume_data:getCid()

    local sd_res = costume_data:getResSD()
	local sd_animator = MakeAnimator(sd_res)
    vars['tamerSdNode']:addChild(sd_animator.m_node)

    local costume_name = costume_data:getName()
    vars['costumeTitleLabel']:setString(costume_name)

    local tamer_name = table_tamer:getValue(tamer_id, 't_name')
    vars['tamerNameLabel']:setString(Str(tamer_name))

    local shop_info = g_tamerCostumeData:getShopInfo(costume_id)
    if (not shop_info) then 
        return
    end

    local is_sale = costume_data:isSale()
    local price = is_sale and shop_info['sale_price'] or shop_info['origin_price'] 
    local price_type = shop_info['price_type']
    local price_icon = IconHelper:getPriceIcon(price_type)
    vars['iconNode']:addChild(price_icon)
    vars['priceLabel']:setString(comma_value(price))

    local str_price = price_type == 'cash' and Str('다이아몬드') or Str('골드')
    local costume_name = costume_data:getName()
    local msg = Str('{1} {2}개를 사용하여\n{3}(을)를 구매하시겠습니까?', str_price, comma_value(price), costume_name)
    vars['messageLabel']:setString(msg)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_DragonSkinConfirmPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_DragonSkinConfirmPopup:refresh()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_DragonSkinConfirmPopup:click_closeBtn()
    self.m_closeCB = nil
    self:close()
end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_DragonSkinConfirmPopup:click_okBtn()
    local costume_data = self.m_dragonSkinData
    local costume_id = costume_data:getCid()

    local shop_info = g_tamerCostumeData:getShopInfo(costume_id)
    local is_sale = costume_data:isSale()
    local price = is_sale and shop_info['sale_price'] or shop_info['origin_price'] 
    local price_type = shop_info['price_type']

    -- 캐쉬가 충분히 있는지 확인
    if (not ConfirmPrice(price_type, price)) then
        return
    end

    g_tamerCostumeData:request_costumeBuy(costume_id, function() 
        self:close() 
    end)
end

--@CHECK
UI:checkCompileError(UI_DragonSkinConfirmPopup)
