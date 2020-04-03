local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonFirstPurchaseReward
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonFirstPurchaseReward = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonFirstPurchaseReward:init()
    self:load('button_first_purchase_reward.ui')
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonFirstPurchaseReward:isActive()
    return false
end

-------------------------------------
-- function updateButtonStatus
-- virtual 순수 가상 함수
-------------------------------------
function UI_ButtonFirstPurchaseReward:updateButtonStatus()
    self.root:setVisible(false)
end