-------------------------------------
-- class ServerData_FirstPurchaseEvent
-- @instance g_firstPurchaseEventData
-- @brief 첫 충전 선물 (첫 결제 보상)
-------------------------------------
ServerData_FirstPurchaseEvent = class({
        m_serverData = 'ServerData',
        m_tFirstPurchaseEventInfo = 'table', -- 서버에서 받는 값을 그대로 저장
        --"first_purchase_event_info":{
        --    "10102":{
        --      "is_reward":0,
        --      "btn_ui":"res/ui/buttons/lobby_first_newbie_btn_0101.png",
        --      "end_date":1586790000000,
        --      "popup_ui":"event_first_purchase_newbie.ui",
        --      "t_name":"첫 충전 선물",
        --      "start_date":1585753200000,
        --      "reward":"770405;1,700001;2000"
        --    }
        --  }
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_FirstPurchaseEvent:init(server_data)
    self.m_serverData = server_data
    self.m_tFirstPurchaseEventInfo = {}
end

-------------------------------------
-- function applyFirstPurchaseEvent
-- @brief
-------------------------------------
function ServerData_FirstPurchaseEvent:applyFirstPurchaseEvent(t_data)
    if (not t_data) then
        return
    end

    self.m_tFirstPurchaseEventInfo = t_data
    --cclog('## ServerData_FirstPurchaseEvent:applyFirstPurchaseEvent(t_data)')
    --ccdump(self.m_tFirstPurchaseEventInfo)
end

-------------------------------------
-- function request_firstPurchaseRewardInfo
-- @brief
-- @api /shop/first_purchase_reward
-------------------------------------
function ServerData_FirstPurchaseEvent:request_firstPurchaseRewardInfo(event_id, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        -- first_purchase_event_info 처리
        self:applyFirstPurchaseEvent(ret['first_purchase_event_info'], nil) -- params : ret, finish_cb

        -- mail_item_info

        -- 보상 획득 UI
        -- ItemObtainResult(ret) -- UI 에서 출력함

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/first_purchase_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('event_id', event_id)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end


-------------------------------------
-- function getFirstPurchaseEventInfoByEventId
-- @brief
-------------------------------------
function ServerData_FirstPurchaseEvent:getFirstPurchaseEventInfoByEventId(event_id)
    if (self.m_tFirstPurchaseEventInfo == nil) then
        return nil
    end

    return self.m_tFirstPurchaseEventInfo[event_id]
end

-------------------------------------
-- function isActiveAnnyFirstPurchaseEvent
-- @brief
-------------------------------------
function ServerData_FirstPurchaseEvent:isActiveAnnyFirstPurchaseEvent()
    if (self.m_tFirstPurchaseEventInfo == nil) then
        return false
    end

    for i,v in pairs(self.m_tFirstPurchaseEventInfo) do
        local status = v['status']
        -- 초기상태
        if (status == -1) then
            return true

        -- 결제 완료 ( 보상 수령 가능 
        elseif (status == 0) then
            return true

        -- 보상 수령 완료
        elseif (status == 1) then
            return false
    
        -- 그 외 모든 상황
        else
            return false
        end
    end

    return false
end