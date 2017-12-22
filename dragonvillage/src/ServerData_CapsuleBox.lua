-------------------------------------
-- class ServerData_CapsuleBox
-------------------------------------
ServerData_CapsuleBox = class({
        m_serverData = 'ServerData',
		m_tStrurctCapsuleBox = 'table',
		m_startTime = 'timestamp',
		m_endTime = 'timestamp',
		
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

		-- 총 갯수
		if (t_data['total']) then
			local total = t_data['total'][box_key]
			if (total) then
				struct_capsulebox:setTotal(total)
			end
		end

		-- 가격s
		if (t_data['price']) then
			local price_str = t_data['price'][box_key]
		end
		-- 내용물
		local t_content = t_data[box_key]
		if (t_content) then
			struct_capsulebox:setContents(t_content)
		end

		self.m_tStrurctCapsuleBox[box_key] = struct_capsulebox
	end
end

-------------------------------------
-- function apply
-------------------------------------
function ServerData_CapsuleBox:apply(t_data)
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
		if (ret['capsule_box']) then
			self:init_data(ret['capsule_box'])
		end

		self.m_startTime = ret['start_time']
		self.m_endTime = ret['end_time']

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
-- function request_capsuleBoxStatus
-------------------------------------
function ServerData_CapsuleBox:request_capsuleBoxStatus(finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
		self:apply(ret)

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
function ServerData_CapsuleBox:request_capsuleBoxBuy(box, finish_cb, fail_cb)
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/shop/capsule_box/buy')
    ui_network:setParam('uid', uid)
	ui_network:setParam('box', box)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end

-------------------------------------
-- function openCasuleBoxUI
-------------------------------------
function ServerData_CapsuleBox:openCasuleBoxUI()
	if (not self.m_open) then
		local msg = Str('캡슐 뽑기 준비중입니다.')
		UIManager:toastNotificationRed(msg)
		return
	end
	self:request_capsuleBoxStatus(function()
		UI_CapsuleBox()
	end)
end
