local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversary
-------------------------------------
UI_EventThankAnniversary = class(PARENT, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversary:init(content_type, list_cnt)
    local vars = self:load('event_thanks_anniversary.ui')

    self:initUI()
    self:initButton()
    self:refresh()

end

-------------------------------------
-- function initUI
-------------------------------------
function UI_EventThankAnniversary:initUI()
    local vars = self.vars
    local user_state = 1 -- 1: 신규 2 : 복귀 3: 기존
    vars['userLabel1']:setVisible(false)
    vars['userLabel2']:setVisible(false)
    vars['userLabel3']:setVisible(false)
    
    if (user_state == 1) then
        vars['userLabel1']:setVisible(true)
    elseif (user_state == 2) then
        vars['userLabel2']:setVisible(true)
    else
        vars['userLabel3']:setVisible(true)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversary:initButton()
    local vars = self.vars
    vars['rewardBtn1']:registerScriptTapHandler(function() self:click_rewardBtn(1) end)
    vars['rewardBtn2']:registerScriptTapHandler(function() self:click_rewardBtn(2) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:refresh()

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:onEnterTab()
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_EventThankAnniversary:click_rewardBtn(reward_num)
    self:request_evnetThankReward(reward_num)
end

-------------------------------------
-- function click_rewardBtn
-------------------------------------
function UI_EventThankAnniversary:request_evnetThankReward(reward_num, finish_cb)  
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
    ui_network:setParam('choice', reward_num) -- adventrue(모험)
    ui_network:setSuccessCB(success_cb)
    ui_network:setFailCB(fail_cb)
    ui_network:setRevocable(true)
    ui_network:setReuse(false)
    ui_network:request()

	return ui_network
end