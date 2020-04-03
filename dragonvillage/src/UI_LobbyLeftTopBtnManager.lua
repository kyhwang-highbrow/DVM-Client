-------------------------------------
-- class UI_LobbyLeftTopBtnManager
-- @brief 마을(Lobby)에서 좌상단의 상품 버튼들 관리 클래스
-------------------------------------
UI_LobbyLeftTopBtnManager = class({
        vars = '',

        m_bDirtyButtonsStatus = 'boolean',
        m_bDirtyButtonsPos = 'boolean',

        m_lManagedButtonUI = 'list',
        m_interval = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LobbyLeftTopBtnManager:init(ui_lobby)
    self.vars = ui_lobby.vars
    local vars = self.vars

    self.m_lManagedButtonUI = {}
    self.m_interval = 10

    vars['productBtnMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    local function dirty_status_cb()
        self.m_bDirtyButtonsStatus = true
    end

    local function dirty_position_cb()
        self.m_bDirtyButtonsPos = true
    end


    local l_managed_button_info = {}
    table.insert(l_managed_button_info, {900, UI_ButtonFirstPurchaseReward}) -- 첫 충전 선물 (첫 결제 보상)
    table.insert(l_managed_button_info, {800, UI_ButtonSpecialOfferProduct}) -- 특별 할인 상품
    table.insert(l_managed_button_info, {700, UI_ButtonSpotSale}) -- 깜짝 할인 상품
    


    for i,v in ipairs(l_managed_button_info) do
        local priority = v[1]
        local class_ = v[2]

        local managed_button = class_()
        managed_button.root:setDockPoint(cc.p(0, 0.5))
        managed_button:setPriority(priority)
        managed_button:setDirtyStatusCB(dirty_status_cb)
        managed_button:setDirtyPositionCB(dirty_position_cb)
        vars['productBtnMenu']:addChild(managed_button.root)
        table.insert(self.m_lManagedButtonUI, managed_button)
    end

    self:setDirtyButtonsStatus()
end

-------------------------------------
-- function setDirtyButtonsStatus
-------------------------------------
function UI_LobbyLeftTopBtnManager:setDirtyButtonsStatus()
    self.m_bDirtyButtonsStatus = true
end

-------------------------------------
-- function updateButtonsStatus
-------------------------------------
function UI_LobbyLeftTopBtnManager:updateButtonsStatus()

    for i,v in ipairs(self.m_lManagedButtonUI) do
        v:updateButtonStatus()
    end

    self.m_bDirtyButtonsStatus = false
    self.m_bDirtyButtonsPos = true
end

-------------------------------------
-- function updateButtonsPosition
-- @brief 버튼들의 위치 조정
-------------------------------------
function UI_LobbyLeftTopBtnManager:updateButtonsPosition()
    -- 1. priority가 높은 순으로 리스트를 정렬
    table.sort(self.m_lManagedButtonUI, function(a, b)
        return (a:getPriority() > b:getPriority())
    end)

    -- 2. 위치 지정
    local pos_x = 0
    for i,v in ipairs(self.m_lManagedButtonUI) do
        if (v:isActive() == true) then
            local width = v:getWidth()
            v.root:setPositionX(pos_x + (width / 2))
            pos_x = (pos_x + width + self.m_interval)
        end
    end

    self.m_bDirtyButtonsPos = false
end

-------------------------------------
-- function update
-- @brief 매 프레임 호출되는 함수
-------------------------------------
function UI_LobbyLeftTopBtnManager:update(dt)

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