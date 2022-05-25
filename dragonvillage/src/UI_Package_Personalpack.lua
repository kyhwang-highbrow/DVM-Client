local PARENT = UI

-------------------------------------
-- class UI_Package_Personalpack
-- @brief 깜짝 할인 상품 팝업
-------------------------------------
UI_Package_Personalpack = class(PARENT,{
        m_ppid = 'number', -- table_spot_sale의 key id
        m_structProductList = 'StructProduct',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_Package_Personalpack:init(ppid)
    self.m_ppid = ppid
    self.m_structProductList = {}

    local pid_list = TablePersonalpack:getProductIdList(ppid)
    for i, pid in ipairs(pid_list) do
        table.insert(self.m_structProductList, g_shopDataNew:getTargetProduct(tonumber(pid)))
    end

    self.m_uiName = 'UI_Package_Personalpack'
    local vars = self:load(TablePersonalpack:getPackageRes(ppid))
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_Package_Personalpack')

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
function UI_Package_Personalpack:initUI()
    local vars = self.vars

    local function setProductInfo(idx, struct_product)
        -- 아이템명
        vars['itemLabel' .. idx]:setString(struct_product:getDesc())

        -- 가격
        vars['priceLabel' .. idx]:setString(struct_product:getPriceStr())

        -- 구매 제한
        vars['buyLabel' .. idx]:setString(struct_product:getMaxBuyTermStr(true))
    end

    -- 상품 정보 입력
    for idx, struct_product in ipairs(self.m_structProductList) do
        setProductInfo(idx, struct_product)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Package_Personalpack:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    for i = 1, 2 do
        if (vars['buyBtn' .. i]) then
            vars['buyBtn' .. i]:registerScriptTapHandler(function() self:click_buyBtn(i) end)
        end
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Package_Personalpack:refresh()
    local vars = self.vars

    for idx, struct_product in ipairs(self.m_structProductList) do
        local is_buyable = struct_product:isItBuyable()
        vars['buyBtn' .. idx]:setVisible(is_buyable)
        vars['buyBtn' .. idx]:setEnabled(is_buyable)
        vars['completeNode' .. idx]:setVisible(not is_buyable)
    end

    if (vars['lockMenu']) then
        vars['lockMenu']:setVisible(self.m_structProductList[1]:isItBuyable())
    end
end

-------------------------------------
-- function click_buyBtn
-- @brief 구매 버튼
------------------------------------- 
function UI_Package_Personalpack:click_buyBtn(idx)
    local struct_product = self.m_structProductList[idx]

    local function cb_func(ret)
        -- 아이템 획득 결과창
        ItemObtainResult_Shop(ret)
        self:refresh()
    end
    local sub_msg = nil
    struct_product:buy(cb_func, sub_msg)
end

-------------------------------------
-- function update
-------------------------------------
function UI_Package_Personalpack:update(dt)
    local vars = self.vars

    local ppid = self.m_ppid
    
    local end_time = g_personalpackData:getEndOfSaleTime(ppid)
    if (end_time == nil) then
        return
    end
    end_time = end_time / 1000

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local remain_time = math_max(end_time - curr_time, 0)
    local str = ''
    if (0 < remain_time) then
        str = Str('판매 종료까지 {1} 남음', datetime.makeTimeDesc(remain_time, true)) -- param : sec, showSeconds, firstOnly, timeOnly
    end
    vars['timeLabel']:setString(str)
end

--@CHECK
UI:checkCompileError(UI_Package_Personalpack)
