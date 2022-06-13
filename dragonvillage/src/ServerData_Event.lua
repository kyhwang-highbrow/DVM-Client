-------------------------------------
-- class ServerData_Event
-------------------------------------
ServerData_Event = class({
        m_serverData = 'ServerData',
        m_eventList = 'list',

        m_mapChanceUpDragons = 'map',
		
        -- 2주년 감사 이벤트
        m_isComebackUser_1st = 'bool', -- 복귀유저 구분하는 데 사용 - 2주년 때에는 사용하지 않
		m_isEventUserReward = 'bool', -- 복귀/신규 판단하여 n주년 기념 보상 받은 여부 판단
        m_isUserState = 'number', -- 신규 1 복귀 2 기존 3


        -- 신규 유저 환영 이벤트
        m_sRewardItem = '70001;2, ...',
        m_isRewardTake = 'boolean',

        m_bDirty = 'boolean',
        m_tLobbyDeco = 'table',
        m_successCb = 'success_cb'
    })

local LIMITED_EVENT_LIST = {
	'event_dice',
	'event_exchange'
}

-------------------------------------
-- function init
-------------------------------------
function ServerData_Event:init(server_data)
    self.m_serverData = server_data
    self.m_bDirty = false
    self.m_isRewardTake = true
end

-------------------------------------
-- function getEventPopupTabList
-- @brief 이벤트 탭 노출 리스트 (이벤트 버튼 클릭시)
-------------------------------------
function ServerData_Event:getEventPopupTabList()
    local item_list = {}
    local event_list = self.m_eventList

    -- 기타 가변적인 이벤트 (shop, banner, access_time)
    local idx = 1
    for i, v in ipairs(event_list) do
        local visible = true
        local event_id = v['event_id']
        local event_type = v['event_type'] 
        local priority = v['ui_priority']
        local feature = v['feature']
        local user_lv = v['user_lv']
        local start_date = v['start_date']
        local end_date = v['end_date']
        local target_server = v['target_server'] or ''
        local target_language = v['target_language'] or ''
        local banner = v['banner']

        -- 크로스 프로모션 기간인지 체크 후 기간, os체크를 하는것이 베스트
        if (string.find(event_type, 'event_crosspromotion')) then
            local cross_event_data = g_serverData:get('user', 'cross_promotion_event')
            if (cross_event_data == nil) then cross_event_data = {} end

            visible = false

            -- table_cross_promotion 조회해서 이벤트 기간 체크
            local cross_table = TABLE:get('table_cross_promotion')
            if (cross_table and cross_table ~= '') then
                local ev_item = cross_table[event_id]

                if (ev_item) then
                    local start_timestamp_sec = ServerTime:getInstance():datestrToTimestampSec(ev_item['start'])
                    local end_timestamp_sec = ServerTime:getInstance():datestrToTimestampSec(ev_item['end'])

                    local curr_timestamp_sec = ServerTime:getInstance():getCurrentTimestampSeconds()

                    if start_timestamp_sec and end_timestamp_sec then   
                        if (start_timestamp_sec <= curr_timestamp_sec) and (curr_timestamp_sec <= end_timestamp_sec) then
                            visible = true
                        end
                    elseif start_timestamp_sec and (not end_timestamp_sec) then
                        if (start_timestamp_sec <= curr_timestamp_sec) then
                            visible = true
                        end
                    elseif (not start_timestamp_sec) and end_timestamp_sec then
                        if (curr_timestamp_sec <= end_timestamp_sec) then
                            visible = true
                        end
                    elseif (not start_timestamp_sec) and (not end_timestamp_sec) then
                        visible = true
                    end
                end
            end


            for _, event_name in ipairs(cross_event_data) do
                if (event_name == event_id) then
                    visible = false
                    break
                end
            end
        end


        -- 유저 레벨 조건 (걸려있는 레벨 이상인 유저에게만 노출)
        if (visible) and (user_lv ~= '') then
            local curr_lv = g_userData:get('lv')
            visible = (curr_lv >= user_lv)
        end

        -- 서버 조건
        if (visible) and (target_server ~= '') then
            visible = self:checkTargetServer(target_server)
        end
        
        -- 언어 조건
        if (visible) and (target_language ~= '') then
            visible = (Translate:getGameLang() == target_language)
        end


        -- 날짜 조건
        if (visible) and ((start_date ~= '') or (end_date ~= '')) then
            visible = self:checkEventTime(start_date, end_date, v)
        end
        
        -- ui_priority가 없는 것은 등록하지 않는다.
        if (visible) and (priority == '') then
            visible = false
        end

        -- 토파즈가 있는 유저에게만 보이는 이벤트
        if (visible) and (feature == 'topaz') then
            local topaz = g_userData:get('topaz')
            if (topaz <= 0) then
                visible = false
            end

        elseif (visible) and (string.find(feature, 'only_aos')) then
            visible = CppFunctions:isAndroid()

            if IS_TEST_MODE() then
                visible =  visible or CppFunctions:isMac() or CppFunctions:isWin32()
            end
        elseif (visible) and (string.find(feature, 'only_ios')) then
            visible = CppFunctions:isIos()

            if IS_TEST_MODE() then
                visible = visible or CppFunctions:isMac() or CppFunctions:isWin32()
            end
        -- 드빌 전용관은 한국서버에서만 노출
        elseif (visible) and (event_type == 'highbrow_shop') then
            if (not g_localData:isShowHighbrowShop()) then
                visible = false
            end

        -- 이벤트 탭에서는 패키지 제외
        elseif (visible) and (string.find(event_type, 'package_')) then
            visible = false

        -- shop 관련 이벤트는 오픈되지 않능 상품이라면 탭 등록 pass 
        elseif (visible) and (event_type == 'shop') then
            visible = g_shopDataNew:isExist('package', event_id)

		-- Daily Mission
		elseif (visible) and (event_type == 'daily_mission') then
			-- 전부 클리어 체크
			if (g_dailyMissionData:getMissionDone(event_id)) then
				visible = false
			end

		-- 출석
		elseif (visible) and (string.find(event_type, 'attendance')) then
            -- table_attendance_event_list에서 event_type, event_id
            local category = event_id
            local atd_id = tonumber(event_id)

            -- event_id를 atd_id로 사용하는 것이 우선이다.
            if g_attendanceData:getAttendanceDataByAtdId(atd_id) then

            -- event_id를 category으로 사용하는 경우를 체크
			elseif g_attendanceData:getAttendanceData(category) then

            -- 그 외 경우는 false
            else
                visible = false
            end

        -- 한정 이벤트 체크
        elseif (visible) and (event_id == 'limited') then
			visible = g_hotTimeData:isActiveEvent(event_type)

        elseif (visible) and (event_type == 'fevertime') then
            local item_list = g_fevertimeData:getAllStructFevertimeList()

            if (# item_list <= 0) then 
                visible = false 
            end
            
        elseif (visible) and (event_type == 'event_1st_comeback') then
		    visible = self:isComebackUser_1st()

        -- 2주년 감사이벤트
		elseif (visible) and (string.find(event_type, 'event_thanks_anniversary')) then
            -- 앞의 조건들을 만족하였을 경우에만, 보상 수령 여부를 추가로 판단
            if (visible) then
		        visible = not (self:isEventUserRewardDone())
            end
       
       -- 신규 유저 환영 이벤트
       elseif (visible) and (event_type == 'event_welcome_newbie') then
		    visible = self:isPossibleToGetWelcomeNewbieReward()

        -- 코스튬
        elseif (visible) and (event_type == 'costume_event') then
            visible = UI_CostumeEventPopup:isActiveCostumeEventPopup()

        -- 원스토어 30% 캐시백 프로모션 (원스토어 빌드에만 노출)
        elseif (visible) and (banner == 'event_promotion_onestore_cashback.ui') then
            if (PerpleSdkManager:onestoreIsAvailable() == false) then
                visible = false
            end
        
        -- 어린이날 이벤트 룰렛
        elseif (visible) and (string.find(event_type, 'event_roulette')) then
            if g_hotTimeData:isActiveEvent('event_roulette') or g_hotTimeData:isActiveEvent('event_roulette_reward') then
                visible = true
            else
                visible = false
            end
            
        -- VIP 설문조사 (참여 후에도 이벤트 페이지에서 접근 가능하도록)
        elseif (visible) and string.find(event_type, 'vip_survey') then
            -- year : 2021, 2022, etc
            local splitted_str = pl.stringx.split(event_type, 'vip_survey_')

            if splitted_str then
                local key = splitted_str[2]

                local vip_status = g_userData:getVipInfo(key)
                visible = (key ~= nil) and (vip_status ~= nil)
            else
                visible = false
            end
        end

        if (visible) then
            local event_popup_tab = StructEventPopupTab(v)

            -- 키값은 중복되지 않게 (shop, banner)
            if (item_list[event_type]) then
                event_popup_tab.m_type = event_type .. idx
                idx = idx + 1

            -- 출석은 event_id 추가 (event_id로 구분)
            elseif (string.find(event_type, 'attendance')) then
                event_popup_tab.m_type = event_type .. event_id

            else
                event_popup_tab.m_type = event_type
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
    local event_list = self.m_eventList or {}

    local package_list = g_shopDataNew:getActivatedPackageList(true)

    for i, v in ipairs(event_list) do
        local priority = v['full_popup']

        if (priority ~= '') then
            local event_type = v['event_type']
			local event_id = v['event_id']
            local feature = v['feature']
            local visible = true
            local user_lv = v['user_lv']
            local start_date = v['start_date']
            local end_date = v['end_date']
            local target_server = v['target_server'] or ''
            local target_language = v['target_language'] or ''
            local banner = v['banner']


            -- 먼저 크로스 프로모션 기간인지 체크
            if (string.find(event_type, 'event_crosspromotion')) then
                local cross_event_data = g_serverData:get('user', 'cross_promotion_event')
                if (cross_event_data == nil) then cross_event_data = {} end

                for _, event_name in ipairs(cross_event_data) do
                    if (event_name == event_id) then
                        -- 받은거 있다
                        visible = false
                        break
                    end
                end
            end


			-- feature 조건 체크
			do
				-- aos에서만 노출
				if (visible) and (feature == 'only_aos') then
                    visible = CppFunctions:isAndroid()
                    
                    if IS_TEST_MODE() then
					    visible = visible or CppFunctions:isMac() or CppFunctions:isWin32()
                    end
                elseif (visible) and (feature == 'only_ios') then
                    visible = CppFunctions:isIos()

                    if IS_TEST_MODE() then
					    visible = visible or CppFunctions:isMac() or CppFunctions:isWin32()
                    end
				-- 토파즈가 있는 유저에게만 보이는 이벤트
				elseif (visible) and (feature == 'topaz') then
					local topaz = g_userData:get('topaz')
					if (topaz <= 0) then
						visible = false
					end
				end
			end

            -- 유저 레벨 조건 (걸려있는 레벨 이상인 유저에게만 노출)
            if (visible) and (user_lv ~= '') then
                local curr_lv = g_userData:get('lv')
                visible = curr_lv >= user_lv
            end

            -- 서버 조건
            if (visible) and (target_server ~= '') then
                visible = self:checkTargetServer(target_server)
            end

            -- 언어 조건
            if (visible) and (target_language ~= '') then
                visible = (Translate:getGameLang() == target_language)
            end

            -- 날짜 조건
            if (visible) and ((start_date ~= '') or (end_date ~= '')) then
                visible = self:checkEventTime(start_date, end_date, v)
            end

            -- 단일 상품인 경우 (type:shop) event_id로 등록
            if (visible) and (event_type == 'shop') then
                event_type = v['event_id']     

            -- 레벨업 패키지인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_levelup') then
                if (g_levelUpPackageData:isActive(LEVELUP_PACKAGE_PRODUCT_ID)) then
                    visible = false
                end
            
            -- 레벨업 패키지2인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_levelup_02') then
                if (g_levelUpPackageData:isActive(LEVELUP_PACKAGE_2_PRODUCT_ID)) then
                    visible = false
                end

            -- 레벨업 패키지3인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_levelup_03') then
                if (g_levelUpPackageData:isActive(LEVELUP_PACKAGE_3_PRODUCT_ID)) then
                    visible = false
                end

            -- 모험돌파 패키지인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_adventure_clear') then
                if (g_adventureClearPackageData:isActive()) then
                    visible = false
                end

            -- 모험돌파 패키지인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_adventure_clear_02') then
                if (g_adventureClearPackageData02:isActive()) then
                    visible = false
                end

            -- 모험돌파 패키지인 경우 구매했을 경우 노출시키지 않음.
            elseif (visible) and (event_type == 'package_adventure_clear_03') then
                if (g_adventureClearPackageData03:isActive()) then
                    visible = false
                end
                
            -- 패키지인 경우 구매 불가한 경우 노출시키지 않음.
            elseif (visible) and (string.find(event_type, 'package')) then
                local package_name = event_type

                -- _popup 붙어있는 경우 원래 패키지명을 구함
                if (string.find(package_name, '_popup')) then
                    local l_package_name_split = plSplit(package_name, '_popup')
                    package_name = l_package_name_split[1]
                end

                visible = false

                for index, struct_package_group in pairs(package_list) do
                    if (struct_package_group:getProductName() == package_name) and struct_package_group:isBuyable() then
                        visible = true
                    end
                end

            -- banner type인 경우 resource, url까지 등록
            elseif (visible) and (event_type == 'banner') then
                event_type = event_type .. ';' .. v['banner'] .. ';' .. v['url'] .. ';' .. v['end_date'] .. ';' .. v['start_date']

                -- 원스토어 30% 캐시백 프로모션 (원스토어 빌드에만 노출)
                if (banner == 'event_promotion_onestore_cashback.ui') then
                    if (PerpleSdkManager:onestoreIsAvailable() == false) then
                        visible = false
                    end
                end
			
			-- Daily Mission
			elseif (visible) and (event_type == 'daily_mission') then
				-- 전부 클리어 체크
				if (g_dailyMissionData:getMissionDone(event_id)) then
					visible = false
				else
					event_type = event_type .. ';' .. event_id
				end

			elseif (visible) and (event_type == 'event_1st_comeback') then
				visible = self:isComebackUser_1st()

			elseif (visible) and (string.find(event_type, 'event_thanks_anniversary')) then
                if (visible) then
				    visible = (not self:isEventUserRewardDone())
                end

			-- 한정 이벤트 리스트
			elseif (visible) and (event_id == 'limited') then
				visible = g_hotTimeData:isActiveEvent(event_type)

                -- 콜로세움 참여 이벤트 보상을 전부 받은 경우 풀팝업 X
                if visible and (event_type == 'event_arena_play') then
                    visible = not (g_eventArenaPlayData:isAllReceived('play') and g_eventArenaPlayData:isAllReceived('win'))
                end

            -- 누적 결제 보상 이벤트
            elseif (visible) and (event_type == 'purchase_point') then
                -- 누적 결제 판매 중이 아닐 때에는 visible 끔, 판매 중일 때에는 위의 조건에 따름
                local is_active = g_purchasePointData:isActivePurchasePointEvent(event_id) -- version
                if (not is_active) then
                    visible = is_active
                end

                -- 마지막 보상 받았다면 띄워주지 않음
                local is_get_last_reward = g_purchasePointData:isGetLastReward(event_id)
                if (is_get_last_reward) then
                    visible = false
                end

                if visible then
                    event_type = event_type .. ';' .. event_id
                end

            -- 일일 충전 선물 이벤트
            elseif (visible) and (event_type == 'purchase_daily') then
                local version = event_id

                -- 누적 결제 판매 중이 아닐 때에는 visible 끔, 판매 중일 때에는 위의 조건에 따름
                local is_active = g_purchaseDailyData:isActivePurchaseDailyEvent(version)
                if (not is_active) then
                    visible = false
                end

                -- 마지막 보상 받았다면 띄워주지 않음
                local is_get_last_reward = g_purchaseDailyData:isGetLastReward(version)
                if (is_get_last_reward) then
                    visible = false
                end

                if visible then
                    event_type = event_type .. ';' .. event_id
                end

            -- 코스튬
            elseif (visible) and (event_type == 'costume_event') then
                visible = UI_CostumeEventPopup:isActiveCostumeEventPopup()

            -- 신규 드래곤 출시
            elseif (visible) and (event_type == 'event_dragon_launch_legend') then
                event_type = event_type .. ';' .. event_id

                   
            -- 신규 유저 환영 이벤트
			-- 다른 함수에서 풀팝업 띄워움 UI_Lobby - g_fullPopupManager:show(FULL_POPUP_TYPE.EVENT_WELCOME_NEWBIE, show_func) 
            elseif (visible) and (event_type == 'event_welcome_newbie') then
		        visible = false

			-- VIP 설문조사 (참여하면 풀팝업 뜨지 않도록)
            elseif (visible) and string.find(event_type, 'vip_survey') then
                local is_participated                
                if string.find(event_type, '2021') then
                    if g_settingData:get('vip', 'survey') then
                        is_participated = (start_date == g_settingData:get('vip', 'survey'))
                    else
                        is_participated = (start_date == g_settingData:get('vip', event_type))
                    end
                else
                    is_participated = (start_date == g_settingData:get('vip', event_type))
                end
                -- year : 2021, 2022, etc
                local splitted_str = pl.stringx.split(event_type, 'vip_survey_')

                if splitted_str then
                    local key = splitted_str[2]

                    local vip_status = g_userData:getVipInfo(key)
                    visible = (is_participated == false) and (key ~= nil) and (vip_status ~= nil)
                else
                    visible = false
                end

            elseif (visible) and string.find(event_type, 'highbrow_vip') then
                if (g_highbrowVipData:checkVipStatus() == true) then
                    visible = true 
                else
                    visible = false
                end
            end


            if (visible) then
                l_priority[event_type] = tonumber(priority)
                table.insert(l_list, event_type)
            end
        end
    end

    table.sort(l_list, function(a,b)
        return l_priority[a] < l_priority[b]
    end)

    return l_list
end

-------------------------------------
-- function checkTargetServer
-- @brief true : 활성화, false : 비활성화
-------------------------------------
function ServerData_Event:checkTargetServer(target_server)
    local l_str =  pl.stringx.split(target_server, ';')
    -- 개발서버와 QA서버는 테스트를 위해 등록
    table.insert(l_str, 'DEV')
    table.insert(l_str, 'QA')

    local server = g_localData:getServerName()

    for _, v in ipairs(l_str) do
        if (string.match(v, server)) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function checkEventTime
-- @brief true : 활성화, false : 비활성화
-------------------------------------
function ServerData_Event:checkEventTime(start_date, end_date, optional_data)
    local start_time
    local end_time
    local cur_time = ServerTime:getInstance():getCurrentTimestampSeconds()

    local date_format = 'yyyy-mm-dd HH:MM:SS'
    local parser = pl.Date.Format(date_format)

    
    -- 단말기(local)의 타임존 (단위 : 초)
    local timezone_local = datetime.getTimeZoneOffset()

    -- 서버(server)의 타임존 (단위 : 초)
    local timezone_server = Timer:getServerTimeZoneOffset()
    local offset = (timezone_local - timezone_server)

    if (start_date ~= '' or start_date) then
        local parse_start_date = parser:parse(start_date)
        if (parse_start_date) then
            -- @sgkim 2019.10.24 time값이 nil이 들어오는 경우가 있다.
            if (parse_start_date['time'] == nil) then
                if (optional_data) then
                    start_time = self:getEventTimeInException(optional_data['start_date_timestamp'], optional_data)
                end
            else
                start_time = parse_start_date['time'] + offset -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end

    if (end_date ~= '' or end_date) then
        local parse_end_date = parser:parse(end_date)
        if (parse_end_date) then
            -- @sgkim 2019.10.24 time값이 nil이 들어오는 경우가 있다.
            if (parse_end_date['time'] == nil) then
                if (optional_data) then
                    end_time = self:getEventTimeInException(optional_data['end_date_timestamp'], optional_data)
                end
            else
                end_time = parse_end_date['time'] + offset -- <- 문자열로 된 날짜를 timestamp로 변환할 때 서버 타임존의 숫자로 보정
            end
        end
    end

    -- 시작 종료 시간 모두 걸려있는 경우
    if (start_time) and (end_time) then
        return (start_time < cur_time and cur_time < end_time)

    -- 시작 시간만 걸려있는 경우
    elseif (start_time) then
        return (start_time < cur_time)

    -- 종료 시간만 걸려있는 경우
    elseif (end_time) then
        return (cur_time < end_time)
    end

    return true
end

-------------------------------------
-- function getTargetEventFullPopupRes
-- @brief feature가 client이고 event_type이 일치하는 테이블 정보를 가져와서 풀팝업을 띄울 리소스 문자열 생성
-------------------------------------
function ServerData_Event:getTargetEventFullPopupRes(feature)
	for i, v in ipairs(self.m_eventList) do
		if (v['feature'] == feature) then
			return string.format('banner;%s;%s', v['banner'], v['url'])
		end
	end
	return nil
end

-------------------------------------
-- function getEventTimeInException
-- @brief table_event_list 의 ex) 2019-10-22 을 타임스템프로 변환하는 과정에서 nil이 발생하는 경우가 있음
-- @brief 그런 경우 서버에서 보내준 timestamp값을 사용, 그래도 값을 알수 없다면 오류로그 전송
-------------------------------------
function ServerData_Event:getEventTimeInException(timestamp, optional_data)
    if (not timestamp) then
        -- 오류 로그 전송
        self:sendErrorLog_checkEventTime(optional_data)
        return
    end

    return timestamp/1000
end

-------------------------------------
-- function goToEventUrl
-- @brief 풀팝업, 이벤트탭에서 url 존재 할 경우 처리
-------------------------------------
function ServerData_Event:goToEventUrl(url)
    if (url == 'costume_shop') then
        local tamer_id = g_tamerData:getCurrTamerID()
        UINavigator:goTo('tamer', tamer_id)

    elseif (url == 'shop_topaz') then
        g_shopDataNew:openShopPopup('topaz')

	elseif (url == 'dragon_manage') then
        UINavigator:goTo('dragon')

	elseif (url == 'hatchery') then
		UINavigator:goTo('hatchery')

	elseif (url == 'capsule_box') then
		g_capsuleBoxData:openCapsuleBoxUI()

    -- 카페 게시글
    elseif (string.find(url, 'article')) then
        local l_str = seperate(url, ';')
        local article_key = l_str[2]
        NaverCafeManager:naverCafeStartWithArticleByKey(article_key)

    else
        SDKManager:goToWeb(url)
    end
end

-------------------------------------
-- function setEventTabNoti
-- @brief 이벤트 탭 노티피케이션
-------------------------------------
function ServerData_Event:setEventTabNoti(event_tab)
    local event_type = event_tab.m_type

    -- 접속 시간 받을 보상 있음
    if (event_type == 'access_time') then
        event_tab.m_hasNoti = g_accessTimeData:hasReward()

    -- 교환 이벤트 받을 누적 보상 있음
    elseif (event_type == 'event_exchange') then
        event_tab.m_hasNoti = g_exchangeEventData:hasReward()

    -- 클랜 출석 이벤트
    elseif (event_type == 'daily_mission') then
        event_tab.m_hasNoti = g_dailyMissionData:hasAvailableReward(event_tab:getEventID())

    -- 핫타임
    elseif (event_type == 'fevertime') then
        event_tab.m_hasNoti = g_fevertimeData:isNotUsedFevertimeExist()

    -- 누적 결제 이벤트
    elseif (string.find(event_type, 'purchase_point_')) then
        event_tab.m_hasNoti = g_purchasePointData:hasAvailableReward(event_tab:getVersion())

    -- 일일 충전 선물
    elseif (string.find(event_type, 'purchase_daily_')) then
        event_tab.m_hasNoti = g_purchaseDailyData:hasAvailableReward(event_tab:getVersion())

    -- 콜로세움 참여 이벤트
    elseif (string.find(event_type, 'event_arena_play')) then
        event_tab.m_hasNoti = g_eventArenaPlayData:hasReward('play') or g_eventArenaPlayData:hasReward('win')

    else
        event_tab.m_hasNoti = false
    end
end

-------------------------------------
-- function hasAvailableReward
-- @brief 받을 수 있는 보상이 있는지
-------------------------------------
function ServerData_Event:hasAvailableReward(event_tab)
    local event_type = event_tab.m_type
    local has_available_reward

    -- 접속 시간 받을 보상 있음
    if (event_type == 'access_time') then
        has_available_reward = g_accessTimeData:hasReward()

    -- 교환 이벤트 받을 누적 보상 있음
    elseif (event_type == 'event_exchange') then
        has_available_reward = g_exchangeEventData:hasReward()

    -- 클랜 출석 이벤트
    elseif (event_type == 'daily_mission') then
        has_available_reward = g_dailyMissionData:hasAvailableReward(event_tab:getEventID())

    -- 핫타임
    elseif (event_type == 'fevertime') then
        has_available_reward = g_fevertimeData:isNotUsedFevertimeExist()

    -- 누적 결제 이벤트
    elseif (string.find(event_type, 'purchase_point_')) then
        has_available_reward = g_purchasePointData:hasAvailableReward(event_tab:getVersion())

    -- 일일 충전 선물
    elseif (string.find(event_type, 'purchase_daily_')) then
        has_available_reward = g_purchaseDailyData:hasAvailableReward(event_tab:getVersion())

    -- 콜로세움 참여 이벤트
    elseif (string.find(event_type, 'event_arena_play')) then
        has_available_reward = g_eventArenaPlayData:hasReward('play') or g_eventArenaPlayData:hasReward('win')

    else
        has_available_reward = false
    end

    return has_available_reward
end

-------------------------------------
-- function isHighlightEvent
-- @brief 로비 이벤트 버튼 하일라이트 정보
-------------------------------------
function ServerData_Event:isHighlightEvent()
    local b_highlight = false

    -- 2021-06-24 접속 시간 보상은 더이상 필요가 없음
    --if (g_accessTimeData:hasReward()) then
    --    b_highlight = true

	if (g_highlightData:isHighlighDailyMissionClan()) then
		b_highlight = true

    -- 누적 결제 보상 이벤트의 보상이 있을 경우
    elseif (g_purchasePointData and g_purchasePointData:hasPurchasePointReward()) then
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
function ServerData_Event:openEventPopup(tab, close_cb)

    local function coroutine_function(dt)
        local co = CoroutineHelper()
        co:setBlockPopup()

        co:work('# 출석 정보 받는 중')
        g_attendanceData:request_attendanceInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:work('# 이벤트 정보 받는 중')
        self:request_eventList(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        if (g_hotTimeData:isActiveEvent('event_exchange')) then
            co:work('# 교환 이벤트 정보 받는 중')
            g_exchangeEventData:request_eventInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_dice')) then
            co:work('# 주사위 이벤트 정보 받는 중')
            g_eventDiceData:request_diceInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end


        if (g_hotTimeData:isActiveEvent('event_bingo')) then
            co:work('# 빙고 이벤트 정보 받는 중')
            g_eventBingoData:request_bingoInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_gold_dungeon')) then
            co:work('# 황금던전 이벤트 정보 받는 중')
            g_eventGoldDungeonData:request_dungeonInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_match_card')) then
            co:work('# 카드 짝 맞추기 이벤트 정보 받는 중')
            g_eventMatchCardData:request_eventInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_mandraquest')) then
            co:work('# 만드라고라의 모험 이벤트 정보 받는 중')
            g_mandragoraQuest:request_questInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_alphabet')) then
            co:work('# 알파벳 이벤트 정보 받는 중')
            g_eventAlphabetData:request_alphabetEventInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_image_quiz')) then
            co:work('# 드래곤 이미지 퀴즈 이벤트 정보 받는 중')
            g_eventImageQuizData:request_eventImageQuizInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end
        
        if (g_eventLFBagData:isActive()) then
            co:work('# 소원 구슬 이벤트 정보 받는 중')
            g_eventLFBagData:request_eventLFBagInfo(true, false, co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_eventIncarnationOfSinsData:canPlay()) then
            co:work('# 죄악의 화신 토벌작전 이벤트 정보 받는 중')
            g_eventIncarnationOfSinsData:request_eventIncarnationOfSinsInfo(false, co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if g_hotTimeData:isActiveEvent('event_roulette') or g_hotTimeData:isActiveEvent('event_roulette_reward') then
            co:work('# 룰렛 이벤트 정보 받는 중')
            g_eventRouletteData:request_rouletteInfo(false, true, co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        co:work('# 핫타임(fevertime) 정보 요청 여부 확인')
        if (g_fevertimeData:needToUpdateFevertimeInfo() == true) then
            co:work('# 핫타임(fevertime) 정보 요청 중')
            g_fevertimeData:request_fevertimeInfo(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        if (g_hotTimeData:isActiveEvent('event_arena_play')) then
            co:work('# 콜로세움 이벤트 정보 받는 중')

            g_eventArenaPlayData:request_eventData(co.NEXT, co.ESCAPE)
            if co:waitWork() then return end
        end

        co:work('# 접속시간 저장 중')
        g_accessTimeData:request_saveTime(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end
        
        co:work('# 하이브로 상점 정보 받는 중')
		if (g_localData:isShowHighbrowShop()) then
			g_highbrowData:request_getHbProductList(co.NEXT, co.ESCAPE)
			if co:waitWork() then return end
		end

        co:work('# 일일 미션 받는 중')
		g_dailyMissionData:request_dailyMissionInfo(co.NEXT, co.ESCAPE)
        if co:waitWork() then return end

        co:close()

        self.m_bDirty = true
        local ui
        if (tab) then
            local noti = false -- 탭 타겟을 정한 경우 이벤트 노티 체크하는 부분이랑 꼬임, 노티 꺼줌

            ui = UI_EventPopup(noti)
            ui:setTab(tab, true)
        else
            local noti = true
            ui = UI_EventPopup(noti)
        end

        if (self.m_successCb) then
            self.m_successCb()
        end

        if (close_cb) then
            ui:setCloseCB(close_cb)
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
		self:response_eventList(ret, finish_cb)
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/event/list')
    ui_network:setLoadingMsg(Str('이벤트 정보 받는 중...'))
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
-- function response_eventList
-------------------------------------
function ServerData_Event:response_eventList(ret, finish_cb)
    self.m_eventList = {}
    
	local event_list = ret['table_event_list']
	if (event_list) then
		for _, v in ipairs(event_list) do
			-- 두칼럼 모두 비어있으면 제외 아니라면 등록
			if (v['ui_priority'] ~= '') or (v['full_popup'] ~= '') then
				table.insert(self.m_eventList, v)
                
            -- 로비 장식은 매개변수에 저장 (유효한 로비 장식이 여러개의 경우 마지막 장식 적용)
            elseif(v['event_type'] == 'lobby_deco') then
                self:setLobbyDecoData(v)

            elseif (v['event_type'] == 'event_daily_quest') then
                table.insert(self.m_eventList, v)
			end

        end

        self.m_bDirty = true
	end

    local event_type = 'event_incarnation_of_sins'
    local t_data = self:getEventInByEventType(event_type)

    g_eventIncarnationOfSinsData:setInfo(t_data)

    if finish_cb then
        finish_cb(ret)
    end
end

-------------------------------------
-- function getEventInByEventId
-- @brief 이벤트 아이디가 일치한 이벤트 아이템 반환
-------------------------------------
function ServerData_Event:getEventInByEventId(event_id)
    if (not event_id or not self.m_eventList) then return nil end
    if (#self.m_eventList <= 0) then return nil end

    local result = nil

    for i, v in ipairs(self.m_eventList) do
        if (v and v['event_id'] and v['event_id'] == event_id) then
            result = v
        end
    end

    return result
end

-------------------------------------
-- function getEventInByEventType
-- @brief 이벤트 타입이 일치한 이벤트 아이템 반환
-------------------------------------
function ServerData_Event:getEventInByEventType(event_type)
    if (not event_type or not self.m_eventList) then return nil end
    if (#self.m_eventList <= 0) then return nil end

    local result = nil

    for i, v in ipairs(self.m_eventList) do
        if (v and v['event_type'] and v['event_type'] == event_type) then
            result = v
        end
    end

    return result
end

-------------------------------------
-- function setLobbyDecoData
-- @brief (이벤트 기간이) 유효한 로비 데이터 저장
-------------------------------------
function ServerData_Event:setLobbyDecoData(table_lobbydeco)
    local start_date = table_lobbydeco['start_date']
    local end_date = table_lobbydeco['end_date']

    if (self:checkEventTime(start_date, end_date, table_lobbydeco)) then
        self.m_tLobbyDeco = table_lobbydeco
    end
end

-------------------------------------
-- function applyChanceUpDragons
-- @brief 확률업 드래곤 
-------------------------------------
function ServerData_Event:applyChanceUpDragons(ret)
    if (ret['chance_up']) then
        --self.m_mapChanceUpDragons = {}
        --self.m_mapChanceUpDragons = ret['chance_up']

        self.m_mapChanceUpDragons = {}
        local t_chance_up = ret['chance_up']
        
        -- 확률업은 1~2개이지만 10개까지 확인.
        for i=1, 10 do
            local key = ('chance_up_' .. i)
            if (t_chance_up[key]) then
                local t_data = {}
                t_data['did'] = t_chance_up[key]
                t_data['x'] = 0
                t_data['y'] = 0
                t_data['scale'] = 1

                -- key가 'chance_up_1_pos', 'chance_up_2_pos'의 형태이다.
                -- 값은 '0;0;1'의 형태로 x;y;scale값이다.
                local pos_str = t_chance_up[key .. '_pos']
                if pos_str then

                    -- 공백 제거
                    pos_str = string.gsub(pos_str, ' ', '')

                    -- ';'로 분리
                    local l_str = pl.stringx.split(pos_str, ';') 
                    t_data['x'] = tonumber(l_str[1]) or 0
                    t_data['y'] = tonumber(l_str[2]) or 0
                    t_data['scale'] = tonumber(l_str[3]) or 1
                end

                self.m_mapChanceUpDragons[key] = t_data
            end
        end
    end
end

-------------------------------------
-- function getChanceUpDragons
-------------------------------------
function ServerData_Event:getChanceUpDragons()
    return self.m_mapChanceUpDragons
end

-------------------------------------
-- function getLobbyDeco_eventId
-------------------------------------
function ServerData_Event:getLobbyDeco_eventId()
    if (not self.m_tLobbyDeco) then
        return nil
    end

    return self.m_tLobbyDeco['event_id']
end

-------------------------------------
-- function setEventUserReward
-------------------------------------
function ServerData_Event:setEventUserReward(n)
	if (n == -1) then
		self.m_isEventUserReward = false

	elseif (n == 0) then
		self.m_isEventUserReward = true -- 보상 받기 전

	elseif (n == 1) then
		self.m_isEventUserReward = false   -- 보상 받은 후

	else
		self.m_isEventUserReward = false
	end
end

-------------------------------------
-- function setComebackUserState
-------------------------------------
function ServerData_Event:setComebackUserState(user_state)
    self.m_isUserState = user_state
end

-------------------------------------
-- function isEventUserRewardDone
-------------------------------------
function ServerData_Event:isEventUserRewardDone()
	return (not self.m_isEventUserReward) -- 보상 받을 것이 없다면, 보상 받은 후!
end

-------------------------------------
-- function isCombackUser
-------------------------------------
function ServerData_Event:isCombackUser()
    return (self.m_isUserState == 2)
end

-------------------------------------
-- function isNewUser
-------------------------------------
function ServerData_Event:isNewUser()
    return (self.m_isUserState == 1)
end

-------------------------------------
-- function isOldUser
-------------------------------------
function ServerData_Event:isOldUser()
    return (self.m_isUserState == 3)
end

-------------------------------------
-- function getEventUserState
-------------------------------------
function ServerData_Event:getEventUserState()
    return self.m_isUserState or 3
end

-------------------------------------
-- function setComebackUser_1st
-------------------------------------
function ServerData_Event:setComebackUser_1st(n)
	if (n == -1) then
		self.m_isComebackUser_1st = false

	elseif (n == 0) then
		self.m_isComebackUser_1st = true

	elseif (n == 1) then
		self.m_isComebackUser_1st = false

	else
		self.m_isComebackUser_1st = false

	end
end

-------------------------------------
-- function isComebackUser_1st
-------------------------------------
function ServerData_Event:isComebackUser_1st()
    return self.m_isComebackUser_1st
end

-------------------------------------
-- function sendErrorLog_checkEventTime
-- @brief 시간처리 관련 오류 원인파악을 위해 서버에 로그 전송
-------------------------------------
function ServerData_Event:sendErrorLog_checkEventTime(t_data)

    -- luadump는 nil을 허용하고 무조건 string을 리턴한다.
    local dump_str = luadump(t_data)
    --cclog(dump)

    -- "\n"으로 구분된 첫 줄은 error_stack_header로 사용하기 위해 추가한다.
    local msg = 'ServerData_Event:checkEventTime Error' .. '\n' .. dump_str
    g_errorTracker:sendErrorLog(msg, nil) -- param : msg, success_cb
end

-------------------------------------
-- function response_eventWelcomeNewbie
-- @brief 신규 유저 환영 이벤트 : 로비, users/get_welcome_newbie_reward 통신에서 값을 받아 저장
-------------------------------------
function ServerData_Event:response_eventWelcomeNewbie(ret)
    local t_info = ret['event_welcome_newbie_info']

   -- 대상이 아니거나 보상을 이미 받았을 경우
   -- ret['event_welcome_newbie_info'] 값이 들어오지 않는다.
   -- 보상 받음 처리, isRewardTake = true 처리
    if (not t_info) then
        self.m_isRewardTake = true
        return
    end

    self.m_isRewardTake = t_info['take_reward']
    self.m_sRewardItem = t_info['reward']
end

-------------------------------------
-- function request_eventWelcomeNewbieReward
-- @brief 신규 유저 환영 이벤트 (보상 받기 통신)
-------------------------------------
function ServerData_Event:request_eventWelcomeNewbieReward(finish_cb)  
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        self:response_eventWelcomeNewbie(ret)

        if (ret['new_mail']) then
            local toast_msg = Str('보상이 우편함으로 전송되었습니다.')
            UI_ToastPopup(toast_msg)

            g_highlightData:setHighlightMail()
        end

        if (finish_cb) then
            finish_cb(ret)
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_welcome_newbie_reward')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function getWelcomeNewbieRewardString
-- @return 7001;2,
-------------------------------------
function ServerData_Event:getWelcomeNewbieRewardString()
    return self.m_sRewardItem
end

-------------------------------------
-- function isPossibleToGetWelcomeNewbieReward
-- @brief 보상 받을 수 있는 경우 true 리턴
-------------------------------------
function ServerData_Event:isPossibleToGetWelcomeNewbieReward()
    return not self.m_isRewardTake
end

function ServerData_Event:setSuccessCB(success_cb)
    self.m_successCb = success_cb
end