local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonSpotSale
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonSpotSale = class(PARENT, {
        m_activeUIIdx = 'number',
        m_activeSpotSaleID = 'number',
        m_maxUIIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonSpotSale:init()
    self:load('button_spot_sale.ui')

    self.m_activeUIIdx = nil
    self.m_activeSpotSaleID = nil

    local ui_idx_list, max = TableSpotSale:getUIIdxList()
    self.m_maxUIIdx = math_max(max, 10)

    local vars = self.vars
    for i=1, self.m_maxUIIdx do
        -- spotSaleBtn1, spotSaleBtn2, spotSaleBtn3
        local lua_name = 'spotSaleBtn' .. i
        if vars[lua_name] then
            vars[lua_name]:setVisible(false)
            vars[lua_name]:registerScriptTapHandler(function() self:click_spotSaleBtn() end)
        end
    end

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonSpotSale:isActive()
    return (self.m_activeUIIdx ~= nil)
end

-------------------------------------
-- function click_spotSaleBtn
-------------------------------------
function UI_ButtonSpotSale:click_spotSaleBtn()
    UI_Package_SpotSale(self.m_activeSpotSaleID)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ButtonSpotSale:update(dt)
    local vars = self.vars

	local has_spot_sale_item = g_spotSaleData:hasSpotSaleItem()

    -- 활성화된 깜짝 상품이 있을 경우
    if (has_spot_sale_item == true) then
        local spot_sale_id, endtime = g_spotSaleData:getSpotSaleInfo_activeProduct()
        local ui_idx = TableSpotSale:getUIIdx(spot_sale_id)
        self:setActiveUIIdx(ui_idx, spot_sale_id)

        -- 판매 종료까지 남은 시간 표시
        -- spotSaleLabel1, spotSaleLabel2, spotSaleLabel3
        local lua_name = 'spotSaleLabel' .. ui_idx
        if vars[lua_name] then
            --local end_of_sale_time = g_spotSaleData:getSpotSaleInfo_EndOfSaleTime(spot_sale_id) / 1000
            --local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
            local end_of_sale_time = g_spotSaleData:getSpotSaleInfo_EndOfSaleTime(spot_sale_id)
            local curr_time = Timer:getServerTime_Milliseconds()

            local str = ''
            if (curr_time < end_of_sale_time) then
                local time = (end_of_sale_time - curr_time)
                --str = Str('{1} 남음', datetime.makeTimeDesc(time, true)) -- param : sec, showSeconds, firstOnly, timeOnly
                str = Str('{1}', datetime.makeTimeDesc_timer(time))
            end
            vars[lua_name]:setString(str)
        end
        
    else
        self:setActiveUIIdx(nil, nil) -- param : ui_idx, spot_sale_id
    end
end

-------------------------------------
-- function setActiveUIIdx
-- @brief
-------------------------------------
function UI_ButtonSpotSale:setActiveUIIdx(ui_idx, spot_sale_id)
    if (self.m_activeUIIdx == ui_idx) then
        return
    end

    local off_idx = self.m_activeUIIdx
    local on_idx = ui_idx
    self.m_activeUIIdx = ui_idx
    self.m_activeSpotSaleID = spot_sale_id

    local vars = self.vars

    if (off_idx and vars['spotSaleBtn' .. off_idx]) then
        vars['spotSaleBtn' .. off_idx]:setVisible(false)
    end

    if (on_idx and vars['spotSaleBtn' .. on_idx]) then
        vars['spotSaleBtn' .. on_idx]:setVisible(true)
    end

    -- 상태가 변경되었으니 위치 조정
    self:callDirtyPositionCB()
end