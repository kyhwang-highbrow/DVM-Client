-------------------------------------
-- class ServerData_Event
-------------------------------------
ServerData_Event = class({
        m_serverData = 'ServerData',
        m_eventList = 'list',

        m_bDirty = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Event:init(server_data)
    self.m_serverData = server_data
    self.m_bDirty = false
end

-------------------------------------
-- function getEventPopupTabList
-- @brief 이벤트 탭 노출 리스트 (이벤트 버튼 클릭시)
-------------------------------------
function ServerData_Event:getEventPopupTabList()
    local item_list = {}
    local event_list = self.m_eventList

    -- 출석 체크 고정 (기본출석, 이벤트출석) -- 우선순위는 이벤트 리스트에서 가져오도록 변경함
    for i, v in pairs(g_attendanceData.m_structAttendanceDataList) do
        local event_popup_tab = StructEventPopupTab(v)
        item_list[event_popup_tab.m_type] = event_popup_tab
        self:setEventTabNoti(event_popup_tab)
    end

    -- 기타 가변적인 이벤트 (shop, banner, access_time)
    local idx = 1
    for i, v in ipairs(event_list) do
        local is_exist = true
        local event_id = v['event_id']
        local event_type = v['event_type'] 

        -- shop 관련 이벤트는 오픈되지 않능 상품이라면 탭 등록 pass 
        if (event_type == 'shop') then
            is_exist = g_shopDataNew:isExist('package', event_id)
        end

        -- package 관련 이벤트는 구성품이 오픈되지 않능 상품이라면 탭 등록 pass - ex) 주말패키지
        if (string.find(event_type, 'package_')) then
            is_exist = PackageManager:isExist(event_type)
        end

        if (is_exist) then
            local event_popup_tab = StructEventPopupTab(v)

            -- 키값은 중복되지 않게
            local type = v['event_type']
            if (item_list[type]) then
                event_popup_tab.m_type = type .. idx
                idx = idx + 1
            else
                event_popup_tab.m_type = type
            end

            item_list[event_popup_tab.m_type] = event_popup_tab
            self:setEventTabNoti(event_popup_tab)
        end
    end

    return item_list
end

-------------------------------------
-- function getEventFullPopupList
-- @brief 이벤트 풀팝업 노출 리스트 (로비 진입시)
-------------------------------------
function ServerData_Event:getEventFullPopupList()
    local l_list = {}
    local l_priority = {}
    local event_list = self.m_eventList

    for i, v in ipairs(event_list) do
        local priority = v['full_popup']
        local event_type = v['event_type'] 

        if (priority ~= '') then
            -- 단일 상품인 경우 (type:shop) event_id로 등록
            if (event_type == 'shop') then
                event_type = v['event_id']     

            -- banner type인 경우 resource, url까지 등록
            elseif (event_type == 'banner') then
                event_type = event_type .. ';' .. v['banner'] .. ';' .. v['url']
            end
            
            l_priority[event_type] = tonumber(priority)
            table.insert(l_list, event_type)
        end
    end

    table.sort(l_list, function(a,b)
        return l_priority[a] < l_priority[b]
    end)

    return l_list
end

-------------------------------------
-- function getEventBannerMap
-- @brief 이벤트 배너 노출 맵 (키:이벤트 타입, 값:이미지 리소스)
-------------------------------------
function ServerData_Event:getEventBannerMap()
    local map = {}
    local l_priority = {}
    local event_list = self.m_eventList

    -- 매일 매일 다이아는 고정으로 넣어줌
    map['daily_dia'] = 'res/ui/event/banner_daily_dia.png'

    for i, v in ipairs(event_list) do
        local lobby_banner = v['lobby_banner']
        local event_type = v['event_type'] 
        
        if (lobby_banner ~= '') then
            -- 패키지 (구매 가능하다면 등록)
            if (string.find(event_type, 'package') and PackageManager:isExist(product_id)) then
                map[event_type] = lobby_banner

            -- 단일 상품 (구매 가능하다면 등록)
            elseif (event_type == 'shop') then
                l_shop_list = g_shopDataNew:getProductList('package')
                local pid = v['event_id'] 
                if (l_shop_list[tonumber(pid)]) then
                    map[pid] = lobby_banner
                end
            else
                map[event_type] = lobby_banner
            end
        end
    end

    return map
end

-------------------------------------
-- function setEventTabNoti
-- @brief 이벤트 탭 노티피케이션
-------------------------------------
function ServerData_Event:setEventTabNoti(event_tab)
    local event_type = event_tab.m_type

    -- 출석 받을 보상 있음
    if (event_tab.m_bAttendance) then
        event_tab.m_hasNoti = g_attendanceData:hasAttendanceReward()

    -- 접속 시간 받을 보상 있음
    elseif (event_type == 'access_time') then
        event_tab.m_hasNoti = g_accessTimeData:hasReward()

    -- 교환 이벤트 받을 누적 보상 있음
    elseif (event_type == 'event_exchange') then
        event_tab.m_hasNoti = g_exchangeEventData:hasReward()

    else
        event_tab.m_hasNoti = false
    end
end

-------------------------------------
-- function isHighlightEvent
-- @brief 로비 이벤트 버튼 하일라이트 정보
-------------------------------------
function ServerData_Event:isHighlightEvent()
    local b_highlight = false

    if (g_accessTimeData:hasReward()) then
        b_highlight = true
    end

    return b_highlight
end

-------------------------------------
-- function hasReward
-- @brief 받아야할 보상이 있는지 여부 (이벤트 팝업을 띄움)
-------------------------------------
function ServerData_Event:hasReward()
    -- 출석 보상 여부
    if g_attendanceData:hasAttendanceReward() then
        return true
    end

    return false
end

-------------------------------------
-- function openEventPopup
-------------------------------------
function ServerData_Event:openEventPopup(tab)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        co:work('# 출석 정보 받는 중')
        g_attendanceData:request_attendanceInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:work('# 이벤트 정보 받는 중')
        self:request_eventList(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        if (self:isVaildEvent('event_exchange')) then
            co:work('# 교환 이벤트 정보 받는 중')
            g_exchangeEventData:request_eventInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        co:work('# 상점 정보 받는 중')
        g_shopDataNew:request_shopInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:work('# 접속시간 저장 중')
        g_accessTimeData:request_saveTime(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end
        
        co:work('# 하이브로 상점 정보 받는 중')
        g_highbrowData:request_getHbProductList(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:close()

        self.m_bDirty = true
        if (tab) then
            local noti = false -- 탭 타겟을 정한 경우 이벤트 노티 체크하는 부분이랑 꼬임, 노티 꺼줌
            local ui = UI_EventPopup(noti)
            ui:setTab(tab, true)
        else
            local noti = true
            UI_EventPopup(noti)
        end
    end

    Coroutine(coroutine_function, 'Event Popup 코루틴')
end

-------------------------------------
-- function request_eventList
-------------------------------------
function ServerData_Event:request_eventList(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    -- 성공 콜백
    local function success_cb(ret)
        self.m_eventList = {}
        local event_list = ret['table_event_list'] 
        for _, v in ipairs(event_list) do
            if (v['ui_priority'] ~= '') then
                table.insert(self.m_eventList, v)
            end
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/event/list')
    ui_network:setLoadingMsg('이벤트 정보 받는 중...')
    ui_network:setParam('uid', uid)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function isVaildEvent
-------------------------------------
function ServerData_Event:isVaildEvent(event_name)
    for _, event in ipairs(self.m_eventList) do
        if (event['event_type'] == event_name) then
            return true
        end
    end
    return false
end