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
function UI_ToastPopup:init(toast_str, delay_time)
    local vars = self:load('popup_toast.ui')
    UIManager:open(self, UIManager.NORMAL)

    --if (UIManager.m_toastPopup) then
    --    UIManager.m_toastPopup:closeWithAction()
    --end
	--UIManager.m_toastPopup = self

	-- @UI_ACTION
    self:addAction(self.root, UI_ACTION_TYPE_OPACITY, 0, 0.5)
    self:doActionReset()
    self:doAction(nil, false)

	self.m_toastMsg = toast_str or Str('보상을 수령하였습니다')

    self:initUI(delay_time)
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ToastPopup:initUI(_delay_time)
	local cb_func = function()
		self:closeWithAction()
        --UIManager.m_toastPopup = nil
	end

	SoundMgr:playEffect('UI', 'ui_out_item_get')

    -- 애니메이션 지속 시간
    local delay_time = 1.5
    if (_delay_time) then
        delay_time = _delay_time
    end
	self.root:runAction(
		cc.Sequence:create( 
			cc.DelayTime:create(delay_time),
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

--@CHECK
UI:checkCompileError(UI_ToastPopup)
