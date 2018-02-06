-------------------------------------
-- class ServerData_Tutorial
-------------------------------------
ServerData_Tutorial = class({
        m_serverData = 'ServerData',
        m_tTutorialClearInfo = 'table',	-- 클리어한 튜토리얼 테이블
		m_tTutorialStepInfo = 'table', -- 튜토리얼 별 진행중 스텝 (튜토리얼 테이블에 지정된 스텝만 저장)
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_Tutorial:init(server_data)
    self.m_serverData = server_data
    self.m_tTutorialClearInfo = {}
	self.m_tTutorialStepInfo = {}
end

-------------------------------------
-- function applyData
-------------------------------------
function ServerData_Tutorial:applyData(l_tutorial)
    if (not l_tutorial) then
        return
    end
    for _, tutorial_key in pairs(l_tutorial) do
        self.m_tTutorialClearInfo[tutorial_key] = true
    end
end

-------------------------------------
-- function isTutorialDone
-- @brief 해당 튜토리얼 클리어 여부
-------------------------------------
function ServerData_Tutorial:isTutorialDone(tutorial_key, cb_func)
    return self.m_tTutorialClearInfo[tutorial_key]
end

-------------------------------------
-- function setStep
-------------------------------------
function ServerData_Tutorial:setStep(tutorial_key, step)
	self.m_tTutorialStepInfo[tutorial_key] = step
end

-------------------------------------
-- function getStep
-------------------------------------
function ServerData_Tutorial:getStep(tutorial_key)
	return self.m_tTutorialStepInfo[tutorial_key]
end

-------------------------------------
-- function request_tutorialInfo
-- @brief 해당 튜토리얼 정보
-------------------------------------
function ServerData_Tutorial:request_tutorialInfo(finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local tutorial_key = tutorial_key

    -- 성공 콜백
    local function success_cb(ret)
        -- 튜토리얼 클리어 정보 저장
        self:applyData(ret['tutorial_list'])
		
		-- 튜토리얼 스텝 정보 저장
		self.m_tTutorialStepInfo = ret['tutorial_step']

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tutorial/info')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tutorial', tutorial_key)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end

-------------------------------------
-- function request_tutorialSave
-- @brief 해당 튜토리얼 클리어 상태 저장
-------------------------------------
function ServerData_Tutorial:request_tutorialSave(tutorial_key, step, finish_cb, fail_cb)
    -- 유저 ID
    local uid = g_userData:get('uid')

    local tutorial_key = tutorial_key
	local _step = step or 1 -- step 개념이 라이브 중간에 생겨서 nil이 1로 저장됨. 1이면 클리어된 상태

    -- 성공 콜백
    local function success_cb(ret)

		-- 튜토리얼 클리어 저장
		if (not step) then
	        self.m_tTutorialClearInfo[tutorial_key] = true
		end

		-- 스텝 정보 저장
		self:setStep(tutorial_key, step)

        if (tutorial_key == TUTORIAL.INTRO_FIGHT) then
            -- @analytics
            Analytics:firstTimeExperience('Tutorial_Intro_Finish')
        end

        if finish_cb then
            finish_cb(ret)
        end
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/tutorial/done')
    ui_network:setParam('uid', uid)
    ui_network:setParam('tutorial', tutorial_key)
	ui_network:setParam('step', _step)
    ui_network:hideLoading()
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(false)
    ui_network:setReuse(false)
    ui_network:request()

    return ui_network
end