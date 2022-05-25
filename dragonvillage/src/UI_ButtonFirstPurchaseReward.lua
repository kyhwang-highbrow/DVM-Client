local PARENT = UI_ManagedButton

-------------------------------------
-- class UI_ButtonFirstPurchaseReward
-- @brief 관리되는 버튼 (버튼이 노출되는 여부에 따라 상위 메뉴에서 위치 변경)
-- @used_at 
-------------------------------------
UI_ButtonFirstPurchaseReward = class(PARENT, {
        m_eventId = 'string', -- '10102'
    })

-- 최초 1번은 노티를 보여주기 위함
UI_ButtonFirstPurchaseReward.s_bFirstOpen = true

-------------------------------------
-- function init
-------------------------------------
function UI_ButtonFirstPurchaseReward:init(event_id)
    self.m_eventId = event_id

    -- 서버에서 받은 버튼 ui로 생성한다.
    local ui_res = self:getDataByKey('btn_ui') or 'button_first_purchase_reward.ui'
    self:load(ui_res)

    -- 업데이트 스케줄러
    self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)

    -- 버튼 설정
    local btn = self.vars['btn']
    if btn then
        btn:registerScriptTapHandler(function() self:click_btn() end)
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function UI_ButtonFirstPurchaseReward:isActive()
    local status = self:getDataByKey('status')

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

-------------------------------------
-- function getDataByKey
-------------------------------------
function UI_ButtonFirstPurchaseReward:getDataByKey(key)
    if (self.m_eventId == nil) then
        return nil
    end

    local t_info = g_firstPurchaseEventData:getFirstPurchaseEventInfoByEventId(self.m_eventId)
    -- "10102":{
    --   "popup_ui":"event_first_purchase_newbie.ui",
    --   "t_name":"첫 충전 선물",
    --   "end_date":1586790000000,
    --   "status":-1,
    --   "btn_ui":"button_first_purchase_reward.ui",
    --   "start_date":1585839600000,
    --   "reward":"770405;1,700001;2000"
    -- }
    if (not t_info) then
        return nil
    end

    return t_info[key]
end


-------------------------------------
-- function click_btn
-- @brief 버튼 클릭
-------------------------------------
function UI_ButtonFirstPurchaseReward:click_btn()
    UI_ButtonFirstPurchaseReward.s_bFirstOpen = false

    require('UI_FirstPurchaseRewardPopup')
    local ui = UI_FirstPurchaseRewardPopup(self.m_eventId)

    -- 이하 개발을 위한 코드
    --local t_info = g_firstPurchaseEventData:getFirstPurchaseEventInfoByEventId(self.m_eventId)
    --t_info['status'] = 1
    --t_info['end_date'] = (ServerTime:getInstance():getCurrentTimestampSeconds() + 3) * 1000
end

-------------------------------------
-- function update
-- @brief 매 프레인 호출되는 함수
-------------------------------------
function UI_ButtonFirstPurchaseReward:update(dt)
    local vars = self.vars
    local status = self:getDataByKey('status') -- -1, 0, 1
    local end_date = (self:getDataByKey('end_date') or 0) / 1000 -- timestamp 1585839600000
    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    -- 1. 남은 시간 표시 (기간제일 경우에만)
    local time_label = vars['timeLabel']
    if time_label then
        if (0 < end_date) and (curr_time < end_date) then
            local time_millisec = (end_date - curr_time) * 1000
            local str = datetime.makeTimeDesc_timer(time_millisec)
            time_label:setString(str)
        else
            time_label:setString('')
        end
    end

    -- 2. 빨간 느낌표 표시 상태 (실행 후 한번도 보지 않았을 경우 or 보상이 수령 가능한 상태일 경우)
    local noti_sprite = vars['notiSprite']
    if noti_sprite then
        -- 앱 실행 후 최초 1회는 노출
        if (UI_ButtonFirstPurchaseReward.s_bFirstOpen == true) then
            noti_sprite:setVisible(true)
        
        -- 획득 가능한 보상이 있을 경우 노출
        elseif (status == 0) then
            noti_sprite:setVisible(true)

        -- 그 외 경우 미노출
        else
            noti_sprite:setVisible(false)
        end
    end

    do -- 3. 삭제될 건지 확인
        -- 시간이 지난 경우 (제한 시간이 없을 경우 end_date가 0)
        if (0 < end_date) and (end_date < curr_time) then
            self.m_bMarkDelete = true
            self:callDirtyStatusCB()
        end

        -- 보상을 수령한 상태일 경우
        if (status == 1) then
            self.m_bMarkDelete = true
            self:callDirtyStatusCB()
        end
    end
end