local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonSpecialPeriod
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonSpecialPeriod = class(PARENT, {
        m_bActive = 'boolean',
        m_elapsedTime = '',

        m_targetProduct = '',
        m_targetIndex = '', 
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonSpecialPeriod:init()
    self:load('button_special_period_product.ui')

    self.m_bActive = false
    self.m_elapsedTime = 0
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function update
-------------------------------------
function UI_ButtonSpecialPeriod:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + dt

    if (self.m_elapsedTime <  1) then
        return
    else
        self.m_elapsedTime = 0
    end
    
    local struct_product = self.m_targetProduct
    if struct_product then
        local index = self.m_targetIndex

        local time_sec = struct_product:getTimeRemainingForEndOfSale()
        local time_millisec = (time_sec * 1000)
        local str = datetime.makeTimeDesc_timer(time_millisec)
        
        self.vars['specialLabel' .. index]:setString(str)
    end
end 

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonSpecialPeriod:isActive()
    return self.m_bActive
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonSpecialPeriod:updateButtonStatus()
    local vars = self.vars

    -- 모든 특별 할인 상품 visible을 꺼준다.
    for i=1, 10 do
        local btn = vars['specialBtn' .. i]
        if btn then
            btn:setVisible(false)
        end
    end

    -- 상점에서 특별 할인 상품을 받아온다.
    local struct_product, idx = g_shopDataNew:getSpecialPeroidProduct()

    -- UI가 없을 경우
    local button = vars['specialBtn' .. idx]
    local time_label = vars['specialLabel' .. idx]
    if (not button) or (not time_label) then
        return
    end

    -- 특별 할인 상품 유무에 따라서 초기화
    if struct_product then
        self.m_targetProduct = struct_product
        self.m_targetIndex = idx

        button:setVisible(true)

        -- 상품 이름
        local product_name = struct_product['t_name']
        local string_removed_package = table.getFirst(pl.stringx.split(product_name, ' 패키지'))
        vars['nameLabel' .. idx]:setString(Str(string_removed_package .. '\n패키지'))

        -- 상품 클릭 시 패키지 팝업
        button:registerScriptTapHandler(function()
            local ui = self:showOfferPopup(struct_product)

            -- 팝업이 닫히면 정보 다시 갱신
            ui:setBuyCB(function() 
                if (struct_product:getDependency() == nil) then
                    self.m_bMarkDelete = true
                end
                self:callDirtyStatusCB() 
                ui:close()
            end)
        end)
        

        self:update(0) -- 최초 1번 호출

        time_label.m_node:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
        self.m_bActive = true

    else
        button:setVisible(false)
        time_label.m_node:unscheduleUpdate()
        self.m_bActive = false
    end
end

-------------------------------------
-- function showOfferPopup
-------------------------------------
function UI_ButtonSpecialPeriod:showOfferPopup(struct_product)
    local pid = struct_product['product_id']
    local package_name = TablePackageBundle:getPackageNameWithPid(pid)   

    local struct_product_group = g_shopDataNew:getTargetPackage(package_name)
    local ui = struct_product_group:getTargetUI(nil, nil, true)

    return ui
end
