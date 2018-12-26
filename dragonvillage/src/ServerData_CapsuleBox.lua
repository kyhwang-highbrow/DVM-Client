-------------------------------------
-- class ServerData_CapsuleBox
-------------------------------------
ServerData_CapsuleBox = class({
        m_serverData = 'ServerData',
		m_tStrurctCapsuleBox = 'table',
		m_startTime = 'timestamp',
		m_endTime = 'timestamp',
        m_day = 'number', -- 20180827 <- 이런 형태로 스케쥴 상의 날짜를 리턴
		
		m_open = 'bool',
        m_todayScheduleIdx = 'number',
        m_todaySchedule = 'table',
        m_sortedScheduleList = 'list',
    })

local L_BOX_KEY = {'first', 'second'}

-------------------------------------
-- function init
-------------------------------------
function ServerData_CapsuleBox:init(server_data)
    self.m_serverData = server_data
	self.m_tStrurctCapsuleBox = {}
end

-------------------------------------
-- function init_data
-------------------------------------
function ServerData_CapsuleBox:init_data(t_data)
	-- 테이블이 비었다면 오픈하지 않은 것으로 간주
	if (table.count(t_data) == 0) then
		self.m_open = false
		return
	end

	-- 값이 존재하면 오픈한 것
	self.m_open = true

	for i, box_key in pairs(L_BOX_KEY) do
		local struct_capsulebox = StructCapsuleBox()

		-- 박스 종류
		struct_capsulebox:setBoxKey(box_key)
		
		-- 가격
		if (t_data['price']) then
			local price_str = t_data['price'][box_key]
			struct_capsulebox:setPrice(price_str)
		end

		-- 내용물
		local t_content = t_data[box_key]
		if (t_content) then
			struct_capsulebox:setContents(t_content)
		end

		-- 총 갯수
		if (t_data['total']) then
			struct_capsulebox:setTotal(t_data['total'])
		end

		self.m_tStrurctCapsuleBox[box_key] = struct_capsulebox
	end
end

-------------------------------------
-- function applyCapsuleStatus
-- @brief 캡슐 상태 갱신
-------------------------------------
function ServerData_CapsuleBox:applyCapsuleStatus(t_data)
	for i, box_key in pairs(L_BOX_KEY) do
		local struct_capsulebox = self.m_tStrurctCapsuleBox[box_key]
		local t_count = t_data[box_key]
		if (struct_capsulebox) and (t_count) then
			struct_capsulebox:setContentCount(t_count)
		end
	end
end

-------------------------------------
-- function getCapsuleBoxInfo
-------------------------------------
function ServerData_CapsuleBox:getCapsuleBoxInfo()
	return self.m_tStrurctCapsuleBox
end

-------------------------------------
-- function isOpen
-------------------------------------
function ServerData_CapsuleBox:isOpen()
	return self.m_open
end

-------------------------------------
-- function request_capsuleBoxInfo
-------------------------------------
function ServerData_CapsuleBox:request_capsuleBoxInfo(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		self:response_capsuleBoxInfo(ret)

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/capsule_box/info')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function response_capsuleBoxInfo
-------------------------------------
function ServerData_CapsuleBox:response_capsuleBoxInfo(ret)
	if (ret['capsule_box']) then
		self:init_data(ret['capsule_box'])
	end

	self.m_startTime = ret['start_time']/1000
	self.m_endTime = ret['end_time']/1000

    -- 스케쥴 날짜 갱신
    if ret['day'] then
        self.m_day = ret['day']
    end
    
    -- 캡슐 일정 테이블 정렬
    self:makeSortedScheduleList()

    -- 오늘의 캡슐 일정 데이터 갱신
    self:setTodaySchedule()
end

-------------------------------------
-- function makeSortedScheduleList
-------------------------------------
function ServerData_CapsuleBox:makeSortedScheduleList()
	
    -- 이미 만들어진 리스트가 있다면 return
    if (self.m_sortedScheduleList) then
        return
    end

    local schedule_map = TABLE:get('table_capsule_box_schedule')
    local schedule_list = table.MapToList(schedule_map)
    local schedule_valid_list = {}

     -- notice_visible 값 1인 목록만 테이블에 추가
    for _, v in pairs(schedule_list) do
        if (v['notice_visible'] == 1) then
            table.insert(schedule_valid_list, v)
        end
    end

    -- 캡슐 판매일 오래된 것부터 출력되도록 정렬
    local function sort_func(a, b)
        local a_time = a['day']
        local b_time = b['day']

        return a_time < b_time
    end
    table.sort(schedule_valid_list, sort_func)
    self.m_sortedScheduleList = schedule_valid_list
        
end

-------------------------------------
-- function setTodaySchedule
-------------------------------------
function ServerData_CapsuleBox:setTodaySchedule()
    
    -- 오늘의 캡슐 일정 데이터 갱신
    local today_schedule_info, today_schedule_idx = self:findTodaySchedule()
    self.m_todayScheduleIdx = today_schedule_idx
    self.m_todaySchedule = today_schedule_info

    -- 타이틀도 갱신
    if (today_schedule_info) then
        self.m_tStrurctCapsuleBox['first']:setCapsuleTitle(today_schedule_info['t_first_name'])
        self.m_tStrurctCapsuleBox['second']:setCapsuleTitle(today_schedule_info['t_second_name'])
    end
end

-------------------------------------
-- function findTodaySchedule
-- @brief 리스트 중에서 오늘 판매하는 상품 정보, 인덱스 반환
-------------------------------------
function ServerData_CapsuleBox:findTodaySchedule()
	local idx = 1
    -- ex) 20181224
    local date = pl.Date()
	local date_str = date:year() .. date:month() .. date:day()

    for i,v in pairs(self.m_sortedScheduleList) do
        if (date_str == tostring(v['day'])) then
            return v, idx
        end
        idx = idx + 1
    end

    return nil, nil
end

-------------------------------------
-- function request_capsuleBoxStatus
-------------------------------------
function ServerData_CapsuleBox:request_capsuleBoxStatus(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		self:applyCapsuleStatus(ret)

        -- 스케쥴 날짜 갱신
        if ret['day'] then
            self.m_day = ret['day']
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/capsule_box/status')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function request_capsuleBoxBuy
-------------------------------------
function ServerData_CapsuleBox:request_capsuleBoxBuy(box, price_type, finish_cb, fail_cb, count)
    -- 파라미터
    local uid = g_userData:get('uid')
    if (not count) then
        count = 1
    end

    -- 콜백 함수
    local function success_cb(ret)
		-- 캡슐 갱신
		self:applyCapsuleStatus(ret)

		-- 재화 갱신
		g_serverData:networkCommonRespone(ret)

		-- 메일 갱신
		if (ret['new_mail'] == true) then
			g_highlightData:setHighlightMail()
		end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/capsule_box/buy')
    ui_network:setParam('uid', uid)
	ui_network:setParam('box', box)
    ui_network:setParam('count', count)
	ui_network:setParam('price_type', price_type)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function openCapsuleBoxUI
-------------------------------------
function ServerData_CapsuleBox:openCapsuleBoxUI(show_reward_list)
	if (not self:isOpen()) then
		local msg = Str('캡슐 뽑기 준비중입니다.')
		UIManager:toastNotificationRed(msg)
		return
	end

	-- ui open function
	local function open_box()
		self:request_capsuleBoxStatus(function()
			local ui = UI_CapsuleBox()
            
            -- 나중에 2번 박스도 보여줘야 한다면 구조화하는게 좋을듯
			if (show_reward_list) then
				ui:click_rewardBtn('first')
			end
            
            -- 오늘의 전설 캡슐뽑기 보여주는 팝업 출력
            self:openTodayCapsuleBoxDtagon()
		end)
	end

	-- 종료시간과 비교하여 다음날 정보를 가져온다.
	if (self:checkReopen()) then
		local msg = Str('캡슐 상품을 갱신합니다.')
		UIManager:toastNotificationGreen(msg)
		self:request_capsuleBoxInfo(open_box)
		
	-- 바로 오픈
	else
		open_box()

	end
end

-------------------------------------
-- function checkReopen
-------------------------------------
function ServerData_CapsuleBox:checkReopen()
	local curr_time = Timer:getServerTime()
	return (curr_time > self.m_endTime)
end

-------------------------------------
-- function openTodayCapsuleBoxDtagon
-------------------------------------
function ServerData_CapsuleBox:openTodayCapsuleBoxDtagon()
    local cur_time = Timer:getServerTime()
    local cool_time = g_settingData:getPromoteExpired('capsule_box')
    
  
    -- 1. 쿨타임이 지났을 경우
    if (cur_time < cool_time) then
        return
    end
    
    do -- 2. 상품이 모두 드래곤일 경우
        local capsulebox_data = g_capsuleBoxData:getCapsuleBoxInfo()
        local table_item = TableItem()

        local rank = 1
        local l_reward = capsulebox_data['first']:getRankRewardList(rank)
        
        -- 아이템 하나라도 드래곤이 아니면 팝업 출력x
        for _,struct_reward in ipairs(l_reward) do
            local item_id = struct_reward['item_id']
            local did = table_item:getDidByItemId(item_id)
            if (did == '' or not did) then
                return
            end
        end
    end
    UI_CapsuleBoxTodayInfoPopup()

    
    -- 쿨타임 갱신 (하루)
    local next_cool_time = cur_time + datetime.dayToSecond(1)
    g_settingData:setPromoteCoolTime('capsule_box', next_cool_time)
    
end

-------------------------------------
-- function getRemainTimeText
-------------------------------------
function ServerData_CapsuleBox:getRemainTimeText()
	local curr_time = Timer:getServerTime()
	local remain_time = self.m_endTime - curr_time
	if (remain_time < 0) then
		remain_time = 0
	end

	local text = datetime.makeTimeDesc(remain_time, true)
	return text
end

-------------------------------------
-- function getScheduleDay
-- @brief table_capsule_box_schedule테이블에서 day값
-------------------------------------
function ServerData_CapsuleBox:getScheduleDay()
    local day = self.m_day

    -- 테스트를 위해 임시값 추가 (서버에서 실제로 값이 오면 동작하지 않을 코드)
    if (not day) then
        day = 20180901
    end

    return day
end

-------------------------------------
-- function getBadgeRes
-- @brief 뱃지 Sprite 경로 생성
-------------------------------------
function ServerData_CapsuleBox:getBadgeRes(badge_type)
    if (not badge_type) then
        return nil
    end

    if (badge_type == '') then
        return nil
    end

    local res = 'res/ui/frames/capsule_box_badge_%s.png'
    local res_number = ''

    -- ex) res/ui/frames/capsule_box_badge_0301.png
    if (badge_type == 'event') then
        res_number = '0301'
    elseif (badge_type == 'hot') then
        res_number = '0303'
    elseif (badge_type == 'new') then
        res_number = '0302'
    end

    local full_res = string.format(res, res_number)
    return full_res
end

-------------------------------------
-- function makeBadge
-- @brief 캡슐뽑기 아이템에 붙이는 뱃지 생성
-------------------------------------
function ServerData_CapsuleBox:makeBadge(schedule_info_per_day, reward_name)
    -- 뱃지용 UI 로드
    local badge_ui = UI()
    badge_ui:load('icon_badge.ui')
    badge_ui.vars['badgeNode']:setVisible(true)
    
    -- 뱃지 텍스쳐 설정 (event, hot, new)
    local badge_type = schedule_info_per_day['badge_' .. reward_name]
    local badge_res = self:getBadgeRes(badge_type)
    if (badge_res) then
        badge_ui.vars['badgeSprite']:setTexture(badge_res)
    else
        badge_ui.vars['badgeSprite']:setVisible(false)
    end
    return badge_ui
end