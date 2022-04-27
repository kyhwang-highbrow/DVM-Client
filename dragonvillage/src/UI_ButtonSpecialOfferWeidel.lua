local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonSpecialOfferWeidel
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonSpecialOfferWeidel = class(PARENT, {
        m_bActive = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonSpecialOfferWeidel:init()
    self:load('button_weidel_festival_product.ui')

    self.m_bActive = false

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonSpecialOfferWeidel:isActive()
    return self.m_bActive
end


-------------------------------------
-- function update
-- @brief UI_Lobby에서 매 프레임 호출됨
-------------------------------------
function UI_ButtonSpecialOfferWeidel:update(dt)
   
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ButtonSpecialOfferWeidel:updateButtonStatus()
    local vars = self.vars

    -- 모든 특별 할인 상품 visible을 꺼준다.
    for i=1, 10 do
        local btn = vars['specialOfferBtn' .. i]
        if btn then
            btn:setVisible(false)
        end
    end

    -- 상점에서 특별 할인 상품을 받아온다.
    local struct_product, idx, bonus_num = g_shopDataNew:getSpecialOfferProductWeidel()

    -- UI가 없을 경우
    local button = vars['specialOfferBtn' .. idx]
    local time_label = vars['specialOfferLabel' .. idx]
    if (not button) or (not time_label) then
        return
    end

    -- 특별 할인 상품 유무에 따라서 초기화
    if struct_product then
        button:setVisible(true)

        -- 상품 클릭 시 패키지 팝업
        button:registerScriptTapHandler(function()
            local ui = self:showOfferPopup(struct_product)

            -- 팝업이 닫히면 정보 다시 갱신
            ui:setCloseCB(function() 
                if (struct_product:getDependency() == nil) then
                    self.m_bMarkDelete = true
                end
                self:callDirtyStatusCB() 
            end)
        end)

        -- 매 프레임 남은 시간을 표기한다.
        local function update(dt)
            local time_sec = struct_product:getTimeRemainingForEndOfSale()
            local time_millisec = (time_sec * 1000)
            local str = datetime.makeTimeDesc_timer(time_millisec)
            
            time_label:setString(str)            
        end
        update(0) -- 최초 1번 호출
        time_label.m_node:scheduleUpdateWithPriorityLua(function(dt) update(dt) end, 0)
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
function UI_ButtonSpecialOfferWeidel:showOfferPopup(struct_product)
    local pid = struct_product['product_id']
    local package_name = TablePackageBundle:getPackageNameWithPid(pid)   

    local struct_product_group = g_shopDataNew:getTargetPackage(package_name)
    local ui = struct_product_group:getTargetUI(nil, nil, true)

    return ui
end