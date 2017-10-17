local PARENT = UI

local MIN_NICK = 2
local MAX_NICK = 10

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
	g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_ChangeNickPopup')

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

            local is_name = true
            if (len < MIN_NICK) or (len > MAX_NICK) or (not IsValidText(str, is_name)) then
                editbox:setText('')

                local msg = Str('닉네임은 한글, 영어, 숫자를 사용하여 최소{1}자부터 최대 {2}자까지 생성할 수 있습니다. \n \n 특수문자, 한자, 비속어는 사용할 수 없으며, 중간에 띄어쓰기를 할 수 없습니다.', MIN_NICK, MAX_NICK)
                MakeSimplePopup(POPUP_TYPE.OK, msg)
                return
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
    vars['cancelBtn']:registerScriptTapHandler(function() self:close() end)
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
        self:close()

        UI_ToastPopup(Str('{1}(으)로 변경되었습니다.', nick))
    end

    g_userData:request_changeNick(mid, nil, nick, cb_func)
end
