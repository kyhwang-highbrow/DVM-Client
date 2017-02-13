local PARENT = UI

-------------------------------------
-- class UI_RewardPopup
-------------------------------------
UI_RewardPopup = class(PARENT,{
		m_lRewardTable = 'Reward Table List',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_RewardPopup:init(l_tReward)
    self.m_lRewardTable = l_tReward

    local vars = self:load('popup_toast.ui')
    UIManager:open(self, UIManager.NORMAL)
	
	-- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_RewardPopup:initUI()
	local cb_func = function()
		self:close()
	end

	self.root:runAction(
		cc.Sequence:create(
			cc.DelayTime:create(1.5),
			cc.CallFunc:create(cb_func)
		)
	)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_RewardPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_RewardPopup:refresh()
	local vars = self.vars

	local toast_msg = self:getRewardStr()
	vars['messageLabel']:setString(toast_msg)
end

-------------------------------------
-- function getRewardStr
-------------------------------------
function UI_RewardPopup:getRewardStr()
	local ret_str

	if (false) then 

	else
		ret_str = Str('보상을 수령하였습니다')
	end

	return ret_str
end

-------------------------------------
-- function close
-------------------------------------
function UI_RewardPopup:close()
    if not self.enable then return end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 1, false)
end

--@CHECK
UI:checkCompileError(UI_RewardPopup)
