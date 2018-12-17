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