local PARENT = UI

-------------------------------------
-- class UI_ManagedButton
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at UI_Lobby, UI_ButtonFirstPurchaseReward, UI_ButtonSpotSale
-------------------------------------
UI_ManagedButton = class(PARENT, {
        m_priority = 'number',
        m_cbSetDirtyStatus = 'function',
        m_cbSetDirtyPosition = 'function',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ManagedButton:init()
end

-------------------------------------
-- function setPriority
-------------------------------------
function UI_ManagedButton:setPriority(priority)
    self.m_priority = priority
end

-------------------------------------
-- function getPriority
-------------------------------------
function UI_ManagedButton:getPriority()
    return (self.m_priority or 0)
end

-------------------------------------
-- function setDirtyStatusCB
-------------------------------------
function UI_ManagedButton:setDirtyStatusCB(func)
    self.m_cbSetDirtyStatus = func
end

-------------------------------------
-- function callDirtyStatusCB
-------------------------------------
function UI_ManagedButton:callDirtyStatusCB()
    if self.m_cbSetDirtyStatus then
        self.m_cbSetDirtyStatus()
    end
end

-------------------------------------
-- function setDirtyPositionCB
-------------------------------------
function UI_ManagedButton:setDirtyPositionCB(func)
    self.m_cbSetDirtyPosition = func
end

-------------------------------------
-- function callDirtyPositionCB
-------------------------------------
function UI_ManagedButton:callDirtyPositionCB()
    if self.m_cbSetDirtyPosition then
        self.m_cbSetDirtyPosition()
    end
end

-------------------------------------
-- function isActive
-- virtual 순수 가상 함수
-------------------------------------
function UI_ManagedButton:isActive()
    return true
end

-------------------------------------
-- function getWidth
-------------------------------------
function UI_ManagedButton:getWidth()
    if self.root then
        local width, height = self.root:getNormalSize()
        return width
    end
    
    return 80
end

-------------------------------------
-- function updateButtonStatus
-------------------------------------
function UI_ManagedButton:updateButtonStatus()
end