local PARENT = UI
local MAX_NICK = 10
-------------------------------------
-- class UI_ChangeNickPopup
-------------------------------------
UI_ChangePresetNamePopup = class(PARENT,{
        m_successCB = 'function',
        m_mid = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChangePresetNamePopup:init(success_cb)
    local vars = self:load('preset_name_change.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChangePresetNamePopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)
    self.m_successCB = success_cb

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChangePresetNamePopup:initUI()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            local editbox = pSender
            local str = editbox:getText()
			
			-- 닉네임 검증
			local function proceed_func()
			end
			local function cancel_func()
                editbox:setText('')
			end
			CheckNickName(str, proceed_func, cancel_func, nil, true)
        end
    end

    vars['editBox']:setMaxLength(MAX_NICK)
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChangePresetNamePopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function click_okBtn
-- @brief 계정 생성
-------------------------------------
function UI_ChangePresetNamePopup:click_okBtn()
    local vars = self.vars
    local nick = vars['editBox']:getText()

    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('사용 할 이름을 입력하세요.'))
        return
    end

    if (self.m_successCB) then
        self.m_successCB(nick)
    end
    self:close()
    UI_ToastPopup(Str('{1}(으)로 변경되었습니다.', nick))
end
