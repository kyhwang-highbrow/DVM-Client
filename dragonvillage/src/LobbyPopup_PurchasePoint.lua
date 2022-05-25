local PARENT = LobbyPopupAbstract

-------------------------------------
-- class LobbyPopup_PurchasePoint
-------------------------------------
LobbyPopup_PurchasePoint = class(PARENT, {
        m_purchasePointVersion = 'number', -- 누적결제 이벤트 팝업은 한 개씩만 뜸
    })

-------------------------------------
-- function init
-------------------------------------
function LobbyPopup_PurchasePoint:init()
end

-------------------------------------
-- function startGuide
-- @brief 안내 시작
-------------------------------------
function LobbyPopupAbstract:startGuide()
    self:startCustomGuide()

    local data = self.m_tData

    -- 기간 체크
    -- 팝업 노출 간격 설정
    local key = 'purchase_point' -- purchase_point1-5까지 다 똑같은 팝업 보여줄 것이기 때문에 같은 키값으로 고정
    local server_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    g_lobbyPopupData:setTimestamp(key, server_time)
end

-------------------------------------
-- function checkCustomCondition
-- @brief 조건 확인
-------------------------------------
function LobbyPopup_PurchasePoint:checkCustomCondition()
    local t_lobby_popup_data = self.m_tData
    if (not t_lobby_popup_data) then
        return false
    end

    -- 현재 열려 있는 누적 결제 이벤트 리스트
    local l_item_list_purchase_point = g_purchasePointData:getEventPopupTabList() or {}
    for _, purchase_point_data in pairs(l_item_list_purchase_point) do
        local data = purchase_point_data.m_eventData

        -- 활성화 누적 이벤트 한 개만 검사
        if (data) then
            local active_version = data['version']
            self.m_purchasePointVersion = active_version
            
            if (active_version) then
                -- 마지막 보상 받았을 경우 무조건 false 반환
                local is_get_last_reward = g_purchasePointData:isGetLastReward(active_version)
                if (is_get_last_reward) then
                    return false
                -- 점수 조건 체크
                elseif (t_lobby_popup_data['popup_key'] == 'purchase_point_value') then
                    return self:checkPoint(active_version)
                -- 날짜 조건 체크
                elseif (t_lobby_popup_data['popup_key'] == 'purchase_point_date') then
                    return self:checkDate(active_version)
                end

                return false
            end

        end
    end

    return false
end

-------------------------------------
-- function checkPoint
-- @brief 조건 확인
-------------------------------------
function LobbyPopup_PurchasePoint:checkPoint(active_version)
    if (not active_version) then
        return false
    end
    
    if (not self.m_tData) then
        return false
    end

    local data = self.m_tData
    local cur_purchase_point = tonumber(g_purchasePointData:getPurchasePoint(active_version)) or 0
    local min_value = tonumber(data['min_value']) or 0
    local max_value = tonumber(data['max_value']) or 0

    if (cur_purchase_point < min_value) then
        return false
    end

    if (cur_purchase_point > max_value) then
        return false
    end

    return true
end

-------------------------------------
-- function checkDate
-- @brief 조건 확인
-------------------------------------
function LobbyPopup_PurchasePoint:checkDate(active_version)
    if (not active_version) then
        return false
    end

    if (not self.m_tData) then
        return false
    end
    
    local data = self.m_tData
    local purchase_point_info = g_purchasePointData:getPurchasePointInfo(active_version)
    if (not purchase_point_info) then
        return false
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local start_time = g_purchasePointData:getStartTime(active_version)
    local end_time = g_purchasePointData:getEndTime(active_version)

    if (not start_time) or (not end_time) then
        return false
    end

    -- 1. 상품 판매 시작한 날이라면 (하루가 지나지 않았다면)
    if (curr_time - start_time) < datetime.dayToSecond(1) then
        return true
    end

    -- 2. 상품 종료 2일 전이라면
    if (end_time - curr_time) < datetime.dayToSecond(2) then
        return true
    end

    return false
end

-------------------------------------
-- function getPopupKey
-- @brief 팝업 종류
-- @return string or number
-------------------------------------
function LobbyPopup_PurchasePoint:getPopupKey()
    local version = self.m_purchasePointVersion or ''
    return string.format('purchase_point;%d', version)
end

return LobbyPopup_PurchasePoint