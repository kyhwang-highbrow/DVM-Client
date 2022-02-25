local PARENT = class(UI, ITableViewCell:getCloneTable())

-------------------------------------
-- class UI_SupplyProductListItem
-------------------------------------
UI_SupplyProductListItem = class(PARENT, {
        m_tSupplyData = 'tabel', -- table_supply테이블에서 한 행
        --{
        --    ['supply_id']=1004;
        --    ['period']=14;
        --    ['daily_content']='gold;1000000';
        --    ['t_name']='14일 골드 보급';
        --    ['product_content']='cash;1590';
        --    ['t_desc']='';
        --    ['type']='daily_gold';
        --    ['product_id']=120104;
        --    ['ui_priority']=40;
        --    ['period_option']=1;
        --}

        m_bActive = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SupplyProductListItem:init(t_data)
    self.m_tSupplyData = t_data
 
	-- UI load
    local supply_id = t_data['supply_id']
    -- 'supply_product_list_item.ui' -> 'supply_product_list_item_1001.ui' 형태로 변경
	local ui_name = 'supply_product_list_item_' .. supply_id .. '.ui' 
	self:load(ui_name)

	-- initialize
    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-- @param t_data table_supply에서 한 행
-------------------------------------
function UI_SupplyProductListItem:initUI()
    local vars = self.vars
    local t_data = self.m_tSupplyData

    do -- 상품명
        vars['itemLabel']:setString(Str(t_data['t_name']))
    end    

    do -- 유효 기간 (보급 기간)
        local period = t_data['period'] or 0
        local str = Str('유효 기간 : {1}일', period)
        vars['periodLabel']:setString(str)
    end

    do -- 즉시 획득 (기획 의도상 즉시 지급하는 다이아만 표기하고 있다)
        local package_item_str = t_data['product_content']
        local count = ServerData_Item:getItemCountFromPackageItemString(package_item_str, ITEM_ID_CASH)
        local str = ''
        if (0 < count) then
            --str = Str('즉시 획득 {1}', comma_value(count))
            str = comma_value(count)
        end
        vars['obtainLabel']:setString(str)
    end

    -- StructProduct
    local struct_product = self:getStructProduct()
    if struct_product then
        -- 가격
        local is_tag_attached = ServerData_IAP.getInstance():setGooglePlayPromotionSaleTag(self, struct_product, index)
        local is_sale_price_written = false
        if (is_tag_attached == true) then
            is_sale_price_written = ServerData_IAP.getInstance():setGooglePlayPromotionPrice(self, struct_product, index)
        end

        if (is_sale_price_written == false) then
            vars['priceLabel']:setString(struct_product:getPriceStr())
        end

        -- 상품 설명
        vars['totalRewardLabel']:setString(Str(struct_product:getDesc()))
    end

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SupplyProductListItem:initButton()
    local vars = self.vars

    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['receiveBtn']:registerScriptTapHandler(function() self:click_receiveBtn() end)
    vars['renewalBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_SupplyProductListItem:refresh()
    local vars = self.vars
    local t_data = self.m_tSupplyData


    local supply_type = t_data['type']
    cclog(supply_type)
    local t_supply_info = g_supply:getSupplyInfoByType(supply_type)
    
    -- 상태 체크 -1:비활성, 0:일일 보상 수령 가능, 1:일일 보상 수령 완료
    local reward_status = -1

    if t_supply_info then
        local curr_time = Timer:getServerTime()
        local end_time = (t_supply_info['end'] / 1000)
        
        if (end_time < curr_time) then
            reward_status = -1
        elseif (t_supply_info['reward'] == 0) then
            -- 일일 지급품이 있는지 확인
            local package_item_str = t_data['daily_content']
            local l_item_list = ServerData_Item:parsePackageItemStr(package_item_str)
            if (0 < #l_item_list) then
                reward_status = 0
            else
                reward_status = 1
            end
        else
            reward_status = t_supply_info['reward'] -- 1이어야 한다.
        end
    end

    local struct_product = g_shopDataNew:getTargetProduct(t_data['product_id'])

    -- 비활성 상태
    if (reward_status == -1) then
        if (struct_product == nil) or (not struct_product:isItOnTime()) then
            vars['buyBtn']:setVisible(false)
        else
            vars['buyBtn']:setVisible(true)
        end
        vars['receiveBtn']:setVisible(false)
        vars['renewalBtn']:setVisible(false)
        self.m_bActive = false

    -- 활성 상태에서 일일 보상을 받을 수 있는 상태
    elseif (reward_status == 0) then
        vars['buyBtn']:setVisible(false)
        vars['receiveBtn']:setVisible(true)
        vars['renewalBtn']:setVisible(false)
        self.m_bActive = true

    -- 활성 상태에서 일일 보상을 받은 후
    elseif (reward_status == 1) or (reward_status == 9) then
        
        vars['buyBtn']:setVisible(false)
        vars['receiveBtn']:setVisible(false)
        if (struct_product == nil) or (not struct_product:isItOnTime()) then
            vars['renewalLabel']:setString(Str('오늘 수령 완료'))
            vars['renewalBtn']:setVisible(true)
            vars['renewalBtn']:setEnabled(false)
        else
            vars['renewalLabel']:setString(Str('갱신'))
            vars['renewalBtn']:setVisible(true)
            vars['renewalBtn']:setEnabled(true)
        end

        self.m_bActive = true
    end


    -- 시간 표시
    if (self.m_bActive == true) then
        if t_supply_info then
            local curr_time = Timer:getServerTime_Milliseconds()
            local end_time = t_supply_info['end']
            local time_millisec = math_max(end_time - curr_time, 0)
            local time_str = datetime.makeTimeDesc_timer(time_millisec, true) -- param : milliseconds, day_special
            local str = Str('남은 시간 : {1}', '{@green}' .. time_str)
            vars['periodLabel']:setString(str)
        else
            vars['periodLabel']:setString('')
        end
    else
        -- 유효 기간 (보급 기간)
        local period = t_data['period'] or 0
        local str = Str('유효 기간 : {@DESC}{1}일', period)
        vars['periodLabel']:setString(str)
    end
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출됨
-------------------------------------
function UI_SupplyProductListItem:update(dt)
    if (self.m_bActive == true) then
        self:refresh()
    end
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_SupplyProductListItem:click_infoBtn()
    local t_data = self.m_tSupplyData

    local supply_id = t_data['supply_id']

    -- 상품 구매 후 콜백
    local function cb_func(ret)
        self:questDoubleBuySuccessCB(ret)
    end

    -- 일일 퀘스트 2배 보상(type : daily_quest)
    if (supply_id == TableSupply.SUPPLY_ID_DAILY_QUEST) then

        require('UI_SupplyProductInfoPopup_QuestDouble')
        UI_SupplyProductInfoPopup_QuestDouble(false, cb_func)
    else
        require('UI_SupplyProductInfoPopup')
        local ui = UI_SupplyProductInfoPopup(self.m_tSupplyData)


        ui:setBuyCallback(cb_func)

    end 
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_SupplyProductListItem:click_buyBtn()
    -- 상품 구매 후 콜백
    local function cb_func(ret)
        self:questDoubleBuySuccessCB(ret)
	end

    -- StructProduct
    local struct_product = self:getStructProduct()
	struct_product:buy(cb_func)
end

-------------------------------------
-- function click_receiveBtn
-------------------------------------
function UI_SupplyProductListItem:click_receiveBtn()
    -- 상품 구매 후 콜백
    local function cb_func(ret)
        self:questDoubleBuySuccessCB(ret)
	end

    local t_data = self.m_tSupplyData
    local supply_type = t_data['type']
    g_supply:request_supplyReward(supply_type, cb_func)
end

-------------------------------------
-- function questDoubleBuySuccessCB
-- @brief 상품 구매 후 콜백
-------------------------------------
function UI_SupplyProductListItem:questDoubleBuySuccessCB(ret)
    -- 아이템 획득 결과창
    ItemObtainResult_Shop(ret, true) -- param : ret, show_all
    self:refresh()
end




-------------------------------------
-- function getStructProduct
-- @return StructProduct
-------------------------------------
function UI_SupplyProductListItem:getStructProduct()
    local t_data = self.m_tSupplyData
    local struct_product = g_shopDataNew:getTargetProduct(t_data['product_id'])
    return struct_product
end