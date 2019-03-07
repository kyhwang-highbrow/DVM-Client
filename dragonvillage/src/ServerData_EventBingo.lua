-------------------------------------
-- class ServerData_EventBingo
-- @instance g_eventBingoData
-------------------------------------
ServerData_EventBingo = class({
        m_nMaterialCnt = 'number', -- 재화 보유량
        m_endTime = 'number', -- 종료 시간
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_EventBingo:init()
end

-------------------------------------
-- function getStatusText
-------------------------------------
function ServerData_EventBingo:getStatusText()
    --[[
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('이벤트 종료까지 {1} 남음', datetime.makeTimeDesc(time, true))
    --]]
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventBingo:networkCommonRespone(ret)
    --[[
    self.m_nMaterialCnt = ret['event'] or 0 -- 재화 보유량
    self.m_nMaterialGet = ret['event_get'] or 0 -- 재화 획득량 (일일)
    self.m_nMaterialUse = ret['event_use'] or 0 -- 재화 획득량 (누적)

    if (ret['event_reward']) then
        self.m_rewardInfo = ret['event_reward']
    end
    --]]
end

-------------------------------------
-- function confirm_reward
-- @brief 보상 정보
-------------------------------------
function ServerData_EventBingo:confirm_reward(ret)
    --[[
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
    --]]
end