local PARENT = UI

-------------------------------------
-- class UI_Event1stComeback
-- @desc 1주년 이벤트 : 복귀 유저 환영 이벤트
-------------------------------------
UI_Event1stComeback = class(PARENT,{

    })


-------------------------------------
-- function init
-------------------------------------
function UI_Event1stComeback:init()
    local vars = self:load('event_1st_comeback.ui')

    --self:initUI()
    --self:initButton()
    --self:refresh()

	self:setCloseCB(function() self:request_comebackReward() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_Event1stComeback:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_Event1stComeback:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Event1stComeback:refresh()
end

-------------------------------------
-- function request_comebackReward
-------------------------------------
function UI_Event1stComeback:request_comebackReward()
	-- 유저 ID
    local uid = g_userData:get('uid')
    
    -- 성공 콜백
    local function success_cb(ret)
        local msg = Str('복귀유저 이벤트 선물이 우편함으로 지급되었습니다.')
		MakeSimplePopup(POPUP_TYPE.OK, msg)
		
		g_eventData:setComebackUser_1st(ret['comback_reward_one_year'])
    end

    -- 네트워크 통신
    --local ui_network = UI_Network()
    --ui_network:setUrl('/users/comback_one_year/reward')
    --ui_network:setParam('uid', uid)
    --ui_network:setSuccessCB(success_cb)
    --ui_network:setRevocable(true)
    --ui_network:setReuse(false)
    --ui_network:request()

	success_cb()
end
