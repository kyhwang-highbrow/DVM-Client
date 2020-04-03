local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonFirstPurchaseReward
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonFirstPurchaseReward = class(PARENT, {
        m_eventId = 'string', -- '10102'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonFirstPurchaseReward:init(event_id)
    self.m_eventId = event_id

    -- 서버에서 받은 버튼 ui로 생성한다.
    local ui_res = self:getDataByKey('btn_ui') or 'button_first_purchase_reward.ui'

    self:load(ui_res)

    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonFirstPurchaseReward:isActive()
    return true
end

-------------------------------------
-- function updateButtonStatus
-- virtual 순수 가상 함수
-------------------------------------
function UI_ButtonFirstPurchaseReward:updateButtonStatus()
    self.root:setVisible(true)
end

-------------------------------------
-- function getDataByKey
-------------------------------------
function UI_ButtonFirstPurchaseReward:getDataByKey(key)
    if (self.m_eventId == nil) then
        return nil
    end

    local t_info = g_firstPurchaseEventData:getFirstPurchaseEventInfoByEventId(self.m_eventId)
    --"10102":{
    --  "is_reward":0,
    --  "btn_ui":"button_first_purchase_reward.ui",
    --  "end_date":1586790000000,
    --  "popup_ui":"event_first_purchase_newbie.ui",
    --  "t_name":"첫 충전 선물",
    --  "start_date":1585839600000,
    --  "reward":"770405;1,700001;2000"
    --}
    if (not t_info) then
        return nil
    end

    return t_info[key]
end


-------------------------------------
-- function update
-- @brief 매 프레인 호출되는 함수
-------------------------------------
function UI_ButtonFirstPurchaseReward:update(dt)
    -- 1. 빨간 느낌표 표시 상태 (실행 후 한번도 보지 않았을 경우 or 보상이 수령 가능한 상태일 경우)

    -- 2. 삭제될 건지 확인 (시간이 지났거나, 보상을 수령했을 경우)
end