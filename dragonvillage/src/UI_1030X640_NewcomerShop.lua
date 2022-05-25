local PARENT = UI

-------------------------------------
-- class UI_1030X640_NewcomerShop
-- @brief 초보자 선물 (신규 유저 전용 상점)
-------------------------------------
UI_1030X640_NewcomerShop = class(PARENT,{
        m_ncmId = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_1030X640_NewcomerShop:init(ncm_id)
    self.m_ncmId = ncm_id
    self.m_uiName = 'UI_1030X640_NewcomerShop'
    
    local ui_res = 'newcomer_shop.ui'
    local vars = self:load(ui_res)
    --UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_1030X640_NewcomerShop')

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
function UI_1030X640_NewcomerShop:initUI()
    local vars = self.vars

    -- 상품 리스트 받아옴
    require('TableNewcomerShop')
    local l_product_id = TableNewcomerShop:getNewcomerShopProductList(self.m_ncmId)


    do -- 테이블 뷰 생성
        local l_struct_product = {}
        for _,product_id in pairs(l_product_id) do
            local struct_product = g_shopDataNew:getTargetProduct(product_id)
            if (struct_product) then
                l_struct_product[product_id] = struct_product
            end
        end

        local node = vars['listNode']
        local table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(265 + 10, 405)
        require('UI_ProductNewcomerShop')
        table_view:setCellUIClass(UI_ProductNewcomerShop)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        table_view:setItemList(l_struct_product)
    
        -- ui_priority로 정렬
        local function sort_func(a, b)
            -- 1. 구매 가능한 상품 우선
            -- 2. product_id가 작으면 우선
            local a_struct_product = a['data']
            local b_struct_product = b['data']

            local a_is_buy_all = a_struct_product:isBuyAll()
            local b_is_buy_all = b_struct_product:isBuyAll()

            if (a_is_buy_all == b_is_buy_all) then
                local a_product_id = a_struct_product['product_id']
                local b_product_id = b_struct_product['product_id']
                return a_product_id < b_product_id
            elseif (a_is_buy_all == false) then
                return true
            else--if (b_is_buy_all == false) then
                return false
            end
        end
        table.sort(table_view.m_itemList, sort_func)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_1030X640_NewcomerShop:initButton()
    local vars = self.vars
    if vars['closeBtn'] then
        vars['closeBtn']:setVisible(false)
        vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
    end

    if vars['contractBtn'] then
        vars['contractBtn']:registerScriptTapHandler(function() self:click_contractBtn() end)
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_1030X640_NewcomerShop:refresh()
end

-------------------------------------
-- function update
-------------------------------------
function UI_1030X640_NewcomerShop:update(dt)
    local vars = self.vars

    local end_date = (g_newcomerShop:getNewcomerShopEndTimestamp(self.m_ncmId) or 0) / 1000 -- timestamp 1585839600000
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 1. 남은 시간 표시 (기간제일 경우에만)
    local time_label = vars['timeLabel']
    if time_label then
        if (0 < end_date) and (curr_time < end_date) then
            --local time_millisec = (end_date - curr_time) * 1000
            --local str = datetime.makeTimeDesc_timer(time_millisec)
            local time = (end_date - curr_time)
            local str = Str('이벤트 종료까지 {1} 남음', ServerTime:getInstance():makeTimeDescToSec(time, true))
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end
end

-------------------------------------
-- function click_contractBtn
-------------------------------------
function UI_1030X640_NewcomerShop:click_contractBtn()
    GoToAgreeMentUrl()
end

--@CHECK
UI:checkCompileError(UI_1030X640_NewcomerShop)
