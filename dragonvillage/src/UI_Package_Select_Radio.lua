-------------------------------------
-- inner class UI_Package_Select_Radio
-------------------------------------
UI_Package_Select_Radio = class(UI ,{
    m_isPopup = 'boolean',
    m_cbBuy = 'function',
    m_data = 'table',
    m_pids = 'table',

    m_package_name = 'string',

    m_radioBtn = 'UIC_RadioBtn',
    m_selectPid = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Select_Radio:init(package_name, is_popup)
    self.m_package_name = package_name
    local vars = self:load(string.format('%s_popup.ui', package_name))
    self.m_data = TablePackageBundle:getDataWithName(package_name) 
    self.m_pids = TablePackageBundle:getPidsWithName(package_name) 
    self.m_isPopup = is_popup or false
	
	self.m_uiName = 'UI_Package_Select_Radio'

    if (is_popup) then
        UIManager:open(self, UIManager.POPUP)
        -- 백키 지정
        g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_Package_Bundle')
    end

    self:initUI()
	self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Package_Select_Radio:initUI()
    local vars = self.vars
    if (not self.m_isPopup) then
        vars['closeBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Select_Radio:initButton()
    local vars = self.vars
    vars['buyBtn']:registerScriptTapHandler(function() self:click_buyBtn() end)
    vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)

    -- radio button 선언
    local radio_button = UIC_RadioButton()
    radio_button:setChangeCB(function(pid)
        self.m_selectPid = pid
    end)
    self.m_radioBtn = radio_button

    -- 버튼 등록
    local num_pid, btn, sprite
    for i, pid in pairs(self.m_pids) do
        local num_pid = tonumber(pid)
		local btn = vars['selectBtn' .. i]
        local sprite = vars['selectSprite' .. i]
        radio_button:addButton(num_pid, btn, sprite)
    end
    radio_button:setSelectedButton(tonumber(self.m_pids[1]))
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Select_Radio:refresh()
    local vars = self.vars
    local l_item_list = g_shopData:getProductList('package')
    local target_product = self.m_pids
    if (not target_product) then
        return
    end

    -- local function setLabelString
    local function setLabelString(target_key, idx, str)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setString(str)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setString(str)
        end
    end

    -- local function setNodeVisible
    local function setNodeVisible(target_key, idx, visible)
        if (vars[target_key..idx]) then
            vars[target_key..idx]:setVisible(visible)

        -- 단일 패키지도 table_bundle_package에서 관리, UI 네이밍 예외 검사
        elseif (idx == 1) and (vars[target_key]) then
            vars[target_key]:setVisible(visible)
        end
    end

    for idx, pid in ipairs(target_product) do
        local pid = tonumber(pid)
        local struct_product = l_item_list[pid]

        -- 상품 정보가 없다면 구매제한을 넘겨 서버에서 준 정보가 없는 경우라 판단
        -- 월간 패키지, 주말 패키지는 구매제한 넘겨도 값을 주는데 다른 패키지는 주지 않음?
        if (not struct_product) then
            setLabelString('itemLabel', idx, Str('구매 완료'))

            setNodeVisible('priceNode', idx, false)
            setNodeVisible('buyLabel', idx, false)
            setNodeVisible('priceLabel', idx, false)
            setNodeVisible('buyBtn', idx, false)
            setNodeVisible('completeNode', idx, true)
        else
            -- 구매 제한
            local str = struct_product:getMaxBuyTermStr()

            -- 구매 가능/불가능 텍스트 컬러 변경
            local is_buy_all = struct_product:isBuyAll()
            local color_key = is_buy_all and '{@impossible}' or '{@available}'
            local rich_str = color_key .. str
            setLabelString('buyLabel', idx, rich_str)

	        -- 가격
	        local price = struct_product:getPriceStr()
            setLabelString('priceLabel', idx, price)

        end

    end
end

-------------------------------------
-- function click_buyBtn
-------------------------------------
function UI_Package_Select_Radio:click_buyBtn()
	local function cb_func(ret)
        if (self.m_cbBuy) then
            self.m_cbBuy(ret)
        end

        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        self:close()
	end

    local t_struct_product = g_shopData:getProductList('package')
    local struct_product = t_struct_product[self.m_selectPid]
    struct_product:buy(cb_func)
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_Package_Select_Radio:click_contractBtn()
    GoToAgreeMentUrl()
end

-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_Package_Select_Radio:click_closeBtn()
    self:close()
end

-------------------------------------
-- function setBuyCB
-------------------------------------
function UI_Package_Select_Radio:setBuyCB(func)
    self.m_cbBuy = func
end
