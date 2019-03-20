-------------------------------------
-- class ServerData_EventBingo
-- @instance g_eventBingoData
-------------------------------------
ServerData_EventBingo = class({
        m_nMaterialCnt = 'number', -- ��ȭ ������
        m_endTime = 'number', -- ���� �ð�
        m_startTime = 'number',

        m_structBingo = 'StructEventBingoInfo',
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
    local curr_time = Timer:getServerTime()
    local end_time = (self.m_endTime / 1000)

    local time = (end_time - curr_time)
    return Str('�̺�Ʈ ������� {1} ����', datetime.makeTimeDesc(time, true))
end

-------------------------------------
-- function confirm_reward
-- @brief ���� ����
-------------------------------------
function ServerData_EventBingo:confirm_reward(ret)
    local item_info = ret['item_info'] or nil
    if (item_info) then
        UI_MailRewardPopup(item_info)
    else
        local toast_msg = Str('������ ���������� ���۵Ǿ����ϴ�.')
        UI_ToastPopup(toast_msg)

        g_highlightData:setHighlightMail()
    end
end

-------------------------------------
-- function request_bingoInfo
-------------------------------------
function ServerData_EventBingo:request_bingoInfo(finish_cb, fail_cb)
    
    -- ���� ID
    local uid = g_userData:get('uid')

    -- �ݹ�
    local function success_cb(ret)
        self.m_structBingo = StructEventBingoInfo(ret)
        self.m_endTime = ret['end']
        self.m_startTime = ret['begin']
        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- ��Ʈ��ũ ���
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_bingo_info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_bingoInfo
-------------------------------------
function ServerData_EventBingo:request_DrawNumber(finish_cb, pick_number)
    -- ���� ID
    local uid = g_userData:get('uid')

    -- �ݹ�
    local function success_cb(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- ��Ʈ��ũ ���
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_bingo_use')
    ui_network:setParam('uid', uid)
    ui_network:setParam('number', pick_number)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_rewardBingo
-------------------------------------
function ServerData_EventBingo:request_rewardBingo(reward_type, reward_ind, finish_cb, pick_number)
    -- ���� ID
    local uid = g_userData:get('uid')

    -- �ݹ�
    local function success_cb(ret)
        
        if finish_cb then
            finish_cb(ret)
        end
    end
    
    -- ��Ʈ��ũ ���
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/event_bingo_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('type', reward_type)
    ui_network:setParam('number', reward_ind)
    ui_network:setSuccessCB(success_cb)
	ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
	ui_network:hideBGLayerColor()
    ui_network:request()

    return ui_network
end
