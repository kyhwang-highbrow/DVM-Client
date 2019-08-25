local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary_showDetaillPopup
-------------------------------------
UI_EventThankAnniversary_showDetaillPopup = class(PARENT, {
	m_reward_num = 'number',
})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:init(reward_num)
    local vars = self:load('event_thanks_anniversary_popup_01.ui')
	UIManager:open(self, UIManager.POPUP)	

	-- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_QuestPopup')	

	self.m_reward_num = reward_num

    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
	vars['dragonInfoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:refresh()

end

-------------------------------------
-- function click_okBtn
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:click_okBtn()
	local finish_cb = function()
		UI_EventThankAnniversary_rewardPopup(self.m_reward_num)
		self:close()
	end
	self:request_evnetThankReward(finish_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:click_infoBtn()  
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_EventThankAnniversary_showDetaillPopup:request_evnetThankReward(finish_cb)  
    -- 파라미터
    local uid = g_userData:get('uid')

    -- 콜백 함수
    local function success_cb(ret)
        
        if (finish_cb) then
            finish_cb()
        end
    end

    -- 콜백 함수
    local function fail_cb(ret)
    end

    -- 네트워크 통신 UI 생성
    local ui_network = UI_Network()
    ui_network:setUrl('/users/get_comeback_reward')
    ui_network:setParam('uid', uid)
    ui_network:setParam('choice', self.m_reward_num) -- 1: 신규 2 : 복귀
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end