-------------------------------------
-- class UI_LobbyLeftTopBtnManager
-- @brief 마을(Lobby)에서 좌상단의 상품 버튼들 관리 클래스
--        UI_ManagedButton을 상속받은 버튼들을 관리
-------------------------------------
UI_LobbyLeftTopBtnManager = class({
    vars = '',

    m_bDirtyButtonsStatus = 'boolean',
    m_bDirtyButtonsPos = 'boolean',

    m_lManagedButtonUI = 'list[UI_ManagedButton]',
    m_interval = 'number',

    PRIORITY = 'table',

    m_elapsedTime = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyLeftTopBtnManager:init(ui_lobby)
    self.vars = ui_lobby.vars
    local vars = self.vars

    self.m_lManagedButtonUI = {}
    self.m_interval = 10
    -- 낮을 수록 우선순위 높음
    self.PRIORITY = {
        RECALL = 0, -- 드래곤 리콜
        FIRST_PURCHASE_REWARD = 1, -- 첫 구매 보상
        VIP = 2, -- 하이브로 멤버쉽

        WEIDEL_PACK = 5,  -- 바이델 패키지(4대 이벤트)
    
        PERSONALPACK = 10, -- 개인화 패키지 (22.10.19 기준 사용하지 않고 있음)
        NEWCOMER_SHOP = 11, -- 초보자 선물 패키지 모음
        GETDRAGON_PACK = 12,  -- 신화 획득 축하 패키지
        FLEA_SHOP = 13,         -- 벼룩시장 패키지 모음

        SPECIAL_OFFER_PACK_DIA = 15, -- 특별 할인 다이아 패키지
        SPECIAL_OFFER_PACK_GOLD = 16, -- 특별 할인 골드 패키지
        SPECIAL_OFFER_PACK_NURTURE = 17, -- 특별 할인 육성 패키지
        SPOT_SALE_PRODUCT = 18  -- 깜짝 할인 패키지 
    }

    self.m_elapsedTime = 1

    vars['productBtnMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)


    local l_managed_button_info = {}
    if (g_highbrowVipData:checkVipStatus() == true) and (g_highbrowVipData:isEventActive() == true)then
        table.insert(l_managed_button_info, {self.PRIORITY.VIP, g_highbrowVipData:getVipButton()}) -- Highbrow VIP 버튼   
    end
    
    table.insert(l_managed_button_info, {self.PRIORITY.PERSONALPACK, UI_ButtonPersonalpack}) -- 특별제안 패키지
    table.insert(l_managed_button_info, {self.PRIORITY.SPECIAL_OFFER_PACK_DIA, UI_ButtonSpecialOfferProduct}) -- 특별 할인 상품
    table.insert(l_managed_button_info, {self.PRIORITY.SPECIAL_OFFER_PACK_GOLD, UI_ButtonSpecialOfferProductGold}) -- 특별 할인 골드 상품
    table.insert(l_managed_button_info, {self.PRIORITY.SPECIAL_OFFER_PACK_NURTURE, UI_ButtonSpecialOfferProductNurture}) -- 특별 할인 패키지 상품
    table.insert(l_managed_button_info, {self.PRIORITY.SPOT_SALE_PRODUCT, UI_ButtonSpotSale}) -- 깜짝 할인 상품
    
    table.insert(l_managed_button_info, {self.PRIORITY.WEIDEL_PACK, UI_ButtonSpecialOfferWeidel}) -- 바이델 축제 패키지
    table.insert(l_managed_button_info, {self.PRIORITY.WEIDEL_PACK, UI_ButtonSpecialPeriod}) -- 5주년 축제 패키지, 달빛 축제 패키지

    --table.insert(l_managed_button_info, {self.PRIORITY.PAYMENT_SHOP, UI_ButtonPaymentShop}) -- 현금 결제 상품 상점
    --table.insert(l_managed_button_info, {self.PRIORITY.SUPPLY_DEPOT, UI_ButtonSupplyDepot}) -- 보급소(정액제)

    for i,v in ipairs(l_managed_button_info) do
        local priority = v[1]
        local class_ = v[2]

        local managed_button = self:makeManagedButton(class_)
        managed_button:setPriority(priority)
    end

    self:setDirtyButtonsStatus()
    self:update()
end

-------------------------------------
-- function makeManagedButton
-------------------------------------
function UI_LobbyLeftTopBtnManager:makeManagedButton(class_, ...)
    local vars = self.vars

    local function dirty_status_cb()
        self.m_bDirtyButtonsStatus = true
    end

    local function dirty_position_cb()
        self.m_bDirtyButtonsPos = true
    end


    local managed_button = class_(...)
    managed_button.root:setDockPoint(cc.p(0, 0.5))
    managed_button:setDirtyStatusCB(dirty_status_cb)
    managed_button:setDirtyPositionCB(dirty_position_cb)
    vars['productBtnMenu']:addChild(managed_button.root)
    table.insert(self.m_lManagedButtonUI, managed_button)

    return managed_button
end

-------------------------------------
-- function setDirtyButtonsStatus
-------------------------------------
function UI_LobbyLeftTopBtnManager:setDirtyButtonsStatus()
    self.m_bDirtyButtonsStatus = true
end

-------------------------------------
-- function getManagedButtonByUniqueKey
-- @brief unique_key로 ManagedButton 리턴
-- @param unique_key (string)
-- @return UI_ManagedButton을 상속 받은 클래스 or nil
-------------------------------------
function UI_LobbyLeftTopBtnManager:getManagedButtonByUniqueKey(unique_key)
    for i,v in ipairs(self.m_lManagedButtonUI) do
        if (v.m_uniqueKey == unique_key) then
            return v
        end
    end

    return nil
end

-------------------------------------
-- function updateButtonsStatus
-------------------------------------
function UI_LobbyLeftTopBtnManager:updateButtonsStatus()

    local makeBtnFunction = function (class_, priority, unique_key, ...)
        local managed_button = self:makeManagedButton(class_, ...)
        managed_button:setPriority(priority)
        managed_button.m_uniqueKey = unique_key
    end

    do -- 추가될 버튼 확인
        -- 첫 충전 선물 버튼 생성
        for event_id,v in pairs(g_firstPurchaseEventData.m_tFirstPurchaseEventInfo) do
            local unique_key = ('first_purchase_reward_' .. event_id)

            -- 존재하지 않으면 생성 (삭제는 managed button에서 알아서 진행)
            if (self:getManagedButtonByUniqueKey(unique_key) == nil) then
                -- status가 1이면 보상을 수령한 상태
                if (v['status'] ~= 1) then
                    local class_ = UI_ButtonFirstPurchaseReward
                    local priority = self.PRIORITY.FIRST_PURCHASE_REWARD
                    makeBtnFunction(class_, priority, unique_key, event_id)
                end
            end
        end

        do -- 초보자 선물 버튼 생성
            local t_newcomer_shop_map = g_newcomerShop:getNewcomerShopList()

            for ncm_id, _ in pairs(t_newcomer_shop_map) do
                if (g_newcomerShop:isActiveNewcomerShop(ncm_id) == true) then
                    -- 초보자 선물 데이터가 있고, 종료 시간이 지나지 않은 경우 생성
                    local unique_key = ('newcomer_shop' .. ncm_id)

                    -- 존재하지 않으면 생성 (삭제는 managed button에서 알아서 진행)
                    if (self:getManagedButtonByUniqueKey(unique_key) == nil) then
                        local class_ = UI_ButtonNewcomerShop
                        local priority = self.PRIORITY.NEWCOMER_SHOP
                        makeBtnFunction(class_, priority, unique_key, ncm_id)
                    end
                end
            end
        end

        do -- 벼룩시장 선물 버튼 생성
            local t_flea_shop_map = g_fleaShop:getFleaShopList()
            for ncm_id, _ in pairs(t_flea_shop_map) do
                if (g_fleaShop:isActiveFleaShop(ncm_id) == true) then
                    -- 벼룩시장 선물 데이터가 있고, 종료 시간이 지나지 않은 경우 생성
                    local unique_key = ('flea_shop' .. ncm_id)
                    -- 존재하지 않으면 생성 (삭제는 managed button에서 알아서 진행)
                    if (self:getManagedButtonByUniqueKey(unique_key) == nil) then
                        local class_ = UI_ButtonFleaShop
                        local priority = self.PRIORITY.FLEA_SHOP
                        makeBtnFunction(class_, priority, unique_key, ncm_id)
                    end
                end
            end
        end
    end

    do  --드래곤 획득 패키지
        local unique_key = ('getDragonPackage')
        if (self:getManagedButtonByUniqueKey(unique_key) == nil) then
            if (g_getDragonPackage:isPossibleBuyPackage()) then
                local class_ = UI_GetDragonPackage_LobbyButton
                local priority = self.PRIORITY.GETDRAGON_PACK
                makeBtnFunction(class_, priority, unique_key)
            end
        end
    end

    do -- 리콜
        local unique_key = 'dragon_recall'
        if (self:getManagedButtonByUniqueKey(unique_key) == nil) then
            if g_dragonsData:isRecallExist() then
                require('UI_ButtonDragonRecall')
                local class_ = UI_ButtonDragonRecall
                local priorty = self.PRIORITY.RECALL
                makeBtnFunction(class_, priorty, unique_key)
            end
        end    
    end
    -----------------------------------------------------------

    -- 버튼들의 상태 업데이트
    local l_remove_idx = {}
    for i,v in ipairs(self.m_lManagedButtonUI) do
        v:updateButtonStatus()

        -- 삭제 표시가 된 버튼 수집
        if (v.m_bMarkDelete == true) then
            table.insert(l_remove_idx, 1, i)
        end
    end

    -- 삭제
    for i,v in ipairs(l_remove_idx) do
        local ui = self.m_lManagedButtonUI[v]
        if ui.root then
            ui.root:removeFromParent()
        end
        table.remove(self.m_lManagedButtonUI, v)
    end

    self.m_bDirtyButtonsStatus = false
    self.m_bDirtyButtonsPos = true
end

-------------------------------------
-- function updateButtonsPosition
-- @brief 버튼들의 위치 조정
-------------------------------------
function UI_LobbyLeftTopBtnManager:updateButtonsPosition()
    -- 1. priority 값이 낮은 순으로 리스트를 정렬 (낮을 수록 우선도 높음)
    table.sort(self.m_lManagedButtonUI, function(a, b)
        return (a:getPriority() < b:getPriority())
    end)

    -- 2. 위치 지정
    local pos_x = 0
    local action_tag = 1917 -- 해당 액션만 재생하고 정지하기 위해 고유한 아무 값이나 사용
    local duration = 0.2
    for i,v in ipairs(self.m_lManagedButtonUI) do
        local is_active = v:isActive()
        if (is_active == true) then
            local width = v:getWidth()
            
            -- 액션으로 이동
            local x = pos_x + (width / 2)
            local y = v.root:getPositionY()
            local action = cca.makeBasicEaseMove(duration, x, y)
            cca.stopAction(v.root, action_tag)
            cca.runAction(v.root, action, action_tag)

            -- 즉시 이동
            --v.root:setPositionX(pos_x + (width / 2))

            -- 다음 위치 계산
            pos_x = (pos_x + width + self.m_interval)
        end

        v.root:setVisible(is_active)
    end

    self.m_bDirtyButtonsPos = false
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출되는 함수
-------------------------------------
function UI_LobbyLeftTopBtnManager:update(dt)
    self.m_elapsedTime = self.m_elapsedTime + (dt or 0)

    if (self.m_elapsedTime < 1) then
        return
    else
        self.m_elapsedTime = 0
    end    

    -- 버튼 상태 변경이 필요한 경우 갱신
    if (self.m_bDirtyButtonsStatus == true) then
        self:updateButtonsStatus()
        self.m_bDirtyButtonsStatus = false
    end


    -- 버튼의 위치 변경이 필요한 경우 갱신
    if (self.m_bDirtyButtonsPos == true) then
        self:updateButtonsPosition()
        self.m_bDirtyButtonsPos = false
    end
end