local PARENT = UI

-------------------------------------
-- class UI_EventThankAnniversaryNoChoice
-------------------------------------
UI_EventThankAnniversaryNoChoice = class(PARENT, {

})

-------------------------------------
-- function init
-------------------------------------
function UI_EventThankAnniversaryNoChoice:init(content_type, list_cnt)
    local vars = self:load('event_thanks_anniversary.ui')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_EventThankAnniversaryNoChoice:initButton()
    local vars = self.vars
    --vars['rewardBtn1']:registerScriptTapHandler(function() self:click_chooseBtn(1) end)
    vars['rewardBtn2']:registerScriptTapHandler(function() self:click_chooseBtn(2) end)

	--vars['itemInfoBtn1']:registerScriptTapHandler(function() self:click_infoBtn(1) end)
	vars['itemInfoBtn2']:registerScriptTapHandler(function() self:click_infoBtn(2) end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_EventThankAnniversaryNoChoice:refresh()
    local vars = self.vars

	local is_reward_done = g_eventData:isEventUserRewardDone()
    --vars['rewardBtn1']:setVisible(not is_reward_done)
    vars['rewardBtn2']:setVisible(not is_reward_done)
    if (not is_reward_done) then
        vars['dscLabel1']:setString('')
        --vars['dscLabel1']:setString(Str('{@yellow}한 가지 선물만 선택이 가능{@default}하며 선택 후 되돌릴 수 없으니 신중하게 선택해주세요!'))
    else
        vars['dscLabel1']:setString(Str('보상이 우편함으로 전송되었습니다.'))
    end
end

-------------------------------------
-- function onEnterTab
-------------------------------------
function UI_EventThankAnniversaryNoChoice:onEnterTab()
end

-------------------------------------
-- function click_chooseBtn
-------------------------------------
function UI_EventThankAnniversaryNoChoice:click_chooseBtn(reward_num)
	--UI_EventThankAnniversary_showDetaillPopup(reward_num, reward_cb)

    local finish_cb = function()
		UI_EventThankAnniversary_rewardPopup(2)
		self:refresh()
	end

	UI_EventThankAnniversary_showDetaillPopup:request_evnetThankReward(finish_cb, reward_num)
end

-------------------------------------
-- function click_infoBtn
-------------------------------------
function UI_EventThankAnniversaryNoChoice:click_infoBtn(select_num)
	--if (select_num == 1) then
	--	UI_PickDragon.makePickDragon(nil, 700612, nil, true) -- mid, item_id, , is_info
	--else
		UI_ItemPickPopup(nil, 700701, false) -- mid, item_id, is_draw
	--end
end

