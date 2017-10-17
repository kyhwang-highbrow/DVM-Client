local PARENT = UI

-------------------------------------
-- class UI_ToastPopup
-------------------------------------
UI_ToastPopup = class(PARENT,{
		m_toastMsg = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ToastPopup:init(toast_str)
    local vars = self:load('popup_toast.ui')
    UIManager:open(self, UIManager.NORMAL)
	
	-- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

	self.m_toastMsg = toast_str or Str('보상을 수령하였습니다')

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ToastPopup:initUI()
	local cb_func = function()
		self:close()
	end

	SoundMgr:playEffect('UI', 'ui_out_item_get')

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
function UI_ToastPopup:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ToastPopup:refresh()
	local vars = self.vars

	local toast_msg = self.m_toastMsg
	vars['messageLabel']:setString(toast_msg)
end

-------------------------------------
-- function close
-------------------------------------
function UI_ToastPopup:close()
    if not self.enable then return end

    local function finish_cb()
        UI.close(self)
    end

    -- @ui_actions
    self:doActionReverse(finish_cb, 1, false)
end

--@CHECK
UI:checkCompileError(UI_ToastPopup)
