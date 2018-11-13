-------------------------------------
-- class UI_LobbySpotSaleBtn
-- @brief 마을(Lobby)에서 깜짝 할인 상품 버튼을 관리하는 클래스
-------------------------------------
UI_LobbySpotSaleBtn = class({
        vars = '',
        m_activeUIIdx = 'number',
        m_activeSpotSaleID = 'number',
        m_maxUIIdx = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbySpotSaleBtn:init(ui_lobby)
    self.vars = ui_lobby.vars
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
end

-------------------------------------
-- function click_spotSaleBtn
-------------------------------------
function UI_LobbySpotSaleBtn:click_spotSaleBtn()
    UI_Package_SpotSale(self.m_activeSpotSaleID)
end

-------------------------------------
-- function update
-- @brief UI_Lobby에서 매 프레임 호출됨
-------------------------------------
function UI_LobbySpotSaleBtn:update()
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
            --local curr_time = Timer:getServerTime()
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
function UI_LobbySpotSaleBtn:setActiveUIIdx(ui_idx, spot_sale_id)
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
end