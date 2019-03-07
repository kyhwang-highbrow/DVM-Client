-------------------------------------
-- class ServerData_EventBingo
-- @instance g_eventBingoData
-------------------------------------
ServerData_EventBingo = class({
        m_nMaterialCnt = 'number', -- ��ȭ ������
        m_endTime = 'number', -- ���� �ð�
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
    return Str('�̺�Ʈ ������� {1} ����', datetime.makeTimeDesc(time, true))
    --]]
end

-------------------------------------
-- function networkCommonRespone
-------------------------------------
function ServerData_EventBingo:networkCommonRespone(ret)
    --[[
    self.m_nMaterialCnt = ret['event'] or 0 -- ��ȭ ������
    self.m_nMaterialGet = ret['event_get'] or 0 -- ��ȭ ȹ�淮 (����)
    self.m_nMaterialUse = ret['event_use'] or 0 -- ��ȭ ȹ�淮 (����)

    if (ret['event_reward']) then
        self.m_rewardInfo = ret['event_reward']
    end
    --]]
end

-------------------------------------
-- function confirm_reward
-- @brief ���� ����
-------------------------------------
function ServerData_EventBingo:confirm_reward(ret)
    --[[
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('������ ���������� ���۵Ǿ����ϴ�.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
    --]]
end