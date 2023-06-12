-------------------------------------
-- class StructEventPopupTab
-- @brief 이벤트 팝업에 등록된 탭
-------------------------------------
StructEventPopupTab = class({
        m_type = 'string',
        m_sortIdx = 'number',
        m_eventData = 'map',
        m_hasNoti = '',
    })

-------------------------------------
-- function init
-------------------------------------
function StructEventPopupTab:init(event_data)
    self.m_eventData = event_data
    self.m_sortIdx = event_data['ui_priority'] or 99
end

-------------------------------------
-- function getTabButtonName
-------------------------------------
function StructEventPopupTab:getTabButtonName()
	local name = self.m_eventData['t_name'] or '이벤트'
    return Str(name)
end

-------------------------------------
-- function getTabIcon
-------------------------------------
function StructEventPopupTab:getTabIcon()
    local res = self.m_eventData['icon']
    return res
end

-------------------------------------
-- function getVersion
-------------------------------------
function StructEventPopupTab:getVersion()
    return self.m_eventData['version']
end


-------------------------------------
-- function getEventID
-------------------------------------
function StructEventPopupTab:getEventID()
    return self.m_eventData['event_id']
end

-------------------------------------
-- function getStartDate
-------------------------------------
function StructEventPopupTab:getStartDate()
    return self.m_eventData['start_date']
end

-------------------------------------
-- function getEndDate
-------------------------------------
function StructEventPopupTab:getEndDate()
    return self.m_eventData['end_date']
end

-------------------------------------
-- function isNotiVisible
-------------------------------------
function StructEventPopupTab:isNotiVisible()
    local event_type = self.m_type
    local event_id = self:getEventID()
    local is_noti = false

    -- 접속 시간 받을 보상 있음
    if (event_type == 'access_time') then
        is_noti = g_accessTimeData:hasReward()

    -- 교환 이벤트 받을 누적 보상 있음
    elseif (event_type == 'event_exchange') then
        is_noti = g_exchangeEventData:hasReward()

    -- 클랜 출석 이벤트
    elseif (event_type == 'daily_mission') then
        is_noti = g_dailyMissionData:hasAvailableReward(event_id)

    -- 핫타임
    elseif (event_type == 'fevertime') then
        is_noti = g_fevertimeData:isNotUsedFevertimeExist()

    -- 신화 드래곤 투표 이벤트
    elseif (event_type == 'event_vote') then
        is_noti = g_eventVote:isAvailableEventVote()

    -- 신화 드래곤 인기 투표 가챠
    elseif (event_type == 'event_popularity') then
        is_noti = g_eventPopularityGacha:isAvailableMileagePoint()

    -- 누적 결제 이벤트
    elseif (string.find(event_type, 'purchase_point_')) then
        is_noti = g_purchasePointData:hasAvailableReward(self:getVersion())

    -- 일일 충전 선물
    elseif (string.find(event_type, 'purchase_daily_')) then
        is_noti = g_purchaseDailyData:hasAvailableReward(self:getVersion())

    -- 콜로세움 참여 이벤트
    elseif (string.find(event_type, 'event_arena_play')) then
        is_noti = g_eventArenaPlayData:hasReward('play') or g_eventArenaPlayData:hasReward('win')

    -- 레이드 참여 이벤트
    elseif (string.find(event_type, 'event_raid_play')) then
        is_noti = g_eventLeagueRaidData:hasReward('play') or g_eventLeagueRaidData:hasReward('win')
    
    -- 사전 예약 보상 이벤트
    elseif (string.find(event_type, 'event_crosspromotion')) then
        if (string.find(event_id, 'pre_reservation_')) then
            is_noti = g_userData:isAvailablePreReservation(event_id)
        end

    -- 주사위 이벤트 완주 보상
    elseif (event_type == 'event_dice') then
        is_noti = g_eventDiceData:isAvailableLapReward()
    end

    return is_noti
end
