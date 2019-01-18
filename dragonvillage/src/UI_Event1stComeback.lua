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

    self:initUI()
    self:initButton()
    self:refresh()
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
    local vars = self.vars
    vars['rewardBtn']:registerScriptTapHandler(function() self:click_rewardBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_Event1stComeback:refresh()
    local vars = self.vars
    vars['rewardBtn']:setVisible(g_eventData:isComebackUser_1st())
end


-------------------------------------
-- function click_rewardBtn
-- @brief 아이템 수령
-------------------------------------
function UI_Event1stComeback:click_rewardBtn()
    self:request_comebackReward()
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
        UI_ToastPopup(msg)
		
		g_eventData:setComebackUser_1st(ret['comeback_reward'])
        self:refresh()
    end

    -- 네트워크 통신
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_comeback_reward')
    ui_network:setParam('uid', uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()
end

-------------------------------------
-- function onEnterTab
-- @brief
-------------------------------------
function UI_Event1stComeback:onEnterTab()
    local vars = self.vars
end