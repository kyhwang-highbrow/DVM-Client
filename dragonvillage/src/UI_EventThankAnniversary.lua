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
    local user_state = g_eventData:getEventUserState()
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
    vars['rewardBtn1']:registerScriptTapHandler(function() self:click_chooseBtn(1) end)
    vars['rewardBtn2']:registerScriptTapHandler(function() self:click_chooseBtn(2) end)

	vars['itemInfoBtn1']:registerScriptTapHandler(function() self:click_infoBtn(1) end)
	vars['itemInfoBtn2']:registerScriptTapHandler(function() self:click_infoBtn(2) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:refresh()
    local vars = self.vars

	local is_reward_done = g_eventData:isEventUserRewardDone()
    vars['rewardBtn1']:setVisible(not is_reward_done)
    vars['rewardBtn2']:setVisible(not is_reward_done)
    if (not is_reward_done) then
        vars['dscLabel1']:setString(Str('{@yellow}한 가지 선물만 선택이 가능{@default}하며 선택 후 되돌릴 수 없으니 신중하게 선택해주세요!'))
    else
        vars['dscLabel1']:setString(Str('보상이 우편함으로 전송되었습니다.'))
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversary:onEnterTab()
end

-------------------------------------
-- function click_chooseBtn
-------------------------------------
function UI_EventThankAnniversary:click_chooseBtn(reward_num)
	local reward_cb = function()
		self:refresh()
	end
	UI_EventThankAnniversary_showDetaillPopup(reward_num, reward_cb)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventThankAnniversary:click_infoBtn(select_num)
	if (select_num == 1) then
		UI_PickDragon.makePickDragon(nil, 700612, nil, true) -- mid, item_id, , is_info
	else
		UI_ItemPickPopup(nil, 700701, false) -- mid, item_id, is_draw
	end
end

