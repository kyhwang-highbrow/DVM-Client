local PARENT = UI

local MIN_NICK = 2
local MAX_NICK = 12

-------------------------------------
-- class UI_ChangeNickPopup
-------------------------------------
UI_ChangeNickPopup = class(PARENT,{
        m_successCB = 'function',
        m_mid = 'string',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ChangeNickPopup:init(mid, success_cb)
    local vars = self:load('popup_name_change.ui')
    UIManager:open(self, UIManager.POPUP)
    
    -- backkey 지정
	g_currScene:pushBackKeyListener(self, function() self:click_cancelBtn() end, 'UI_ChangeNickPopup')

	-- @UI_ACTION
	self:doActionReset()
	self:doAction(nil, false)

    self.m_mid = mid
    self.m_successCB = success_cb

	self:initUI()
    self:initButton()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ChangeNickPopup:initUI()
    local vars = self.vars

    -- editBox handler 등록
	local function editBoxTextEventHandle(strEventName, pSender)
        if (strEventName == "return") then
            local editbox = pSender
            local str = editbox:getText()
			local len = uc_len(str)

            if (len < MIN_NICK) or (len > MAX_NICK)then
                UIManager:toastNotificationRed(Str('{1}자~{2}자 이내로 입력해주세요.', MIN_NICK, MAX_NICK))
            end

            if (len > MAX_NICK) then
                editbox:setText(string.sub(str, 1, MAX_NICK))
            end
        end
    end

    vars['editBox']:setMaxLength(MAX_NICK)
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ChangeNickPopup:initButton()
    local vars = self.vars
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
end

-------------------------------------
-- function click_cancelBtn
-------------------------------------
function UI_ChangeNickPopup:click_cancelBtn()
    self:closeWithAction()
end

-------------------------------------
-- function click_okBtn
-- @brief 계정 생성
-------------------------------------
function UI_ChangeNickPopup:click_okBtn()
    local vars = self.vars

    local mid = self.m_mid
    local nick = vars['editBox']:getText()

    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('사용 할 닉네임을 입력하세요.'))
        return
    end

    local function cb_func()
        if (self.m_successCB) then
            self.m_successCB()
        end
        self:click_cancelBtn()

        UI_ToastPopup(Str('{1}(으)로 변경되었습니다.', nick))
    end

    g_userData:request_changeNick(mid, nick, cb_func)
end
