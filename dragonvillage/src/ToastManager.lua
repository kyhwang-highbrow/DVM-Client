local PARENT = UI

-------------------------------------
-- class ToastManager
-- @brief 사용할 때 ToastManager 인스턴스 생성
-- @brief 더이상 토스트 팝업이 없다면 ToastManager 인스턴스 삭제
-------------------------------------
ToastManager = class(PARENT, {
        m_tToastItem = 'Map_StructToast',
    })

-------------------------------------
-- function init
-------------------------------------
function ToastManager:init()
    self.m_tToastItem = {}
end

-------------------------------------
-- function getInstance
-------------------------------------
function ToastManager:getInstance()
    if g_toastManager then
        return g_toastManager
    end

    g_toastManager = ToastManager()
    return g_toastManager
end

-------------------------------------
-- function addToastItem
-------------------------------------
function ToastManager:addToastItem(toast_type, ui_item, delay_time, height, pos_y) -- toast_type, ui_item, delay_time, height, pos_y
    
    local is_exist = false
    -- 이미 등록된 종류의 토스트아이템인지 확인
    if (self.m_tToastItem[toast_type]) then
        is_exist = true
    end

    -- 이미 등록되어 있다면 리스트에 추가
    if (is_exist) then
        local struct_toast = self.m_tToastItem[toast_type]
        struct_toast:addToastItem(ui_item)
    
    -- 등록된 아이템이 없다면 새로 생성
    else
        -- 해당 타입 아이템이 다 사라지면 타입 제거
        local empty_cb = function(toast_type)
            self:removeType(toast_type)
        end

        local struct_toast = StructToast(toast_type, ui_item, delay_time, height, empty_cb, pos_y)
        self.m_tToastItem[toast_type] = struct_toast
    end
end

-------------------------------------
-- function removeType
-------------------------------------
function ToastManager:removeType(toast_type)
    self.m_tToastItem[toast_type] = nil
    local is_empty = true
    for _, reward_item in pairs(self.m_tToastItem) do
        if (reward_item) then
            is_empty = false
        end
    end

    --  현재 떠있는 토스트 아이템들이 없다면 인스턴스 제거
    if (is_empty) then
        g_toastManager = nil
    end
end