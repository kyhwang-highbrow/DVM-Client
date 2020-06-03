
local PARENT = UI
local MAX_NICK = 10
-------------------------------------
-- class UI_SelectNickname
-------------------------------------
UI_SelectNickname = class(PARENT,{
		m_selectIdx = 'number',
		m_makeAccountFunc = 'func',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_SelectNickname:init(idx, make_account_func)
    local vars = self:load('account_create_03.ui')
    UIManager:open(self, UIManager.POPUP)
	
	-- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_SelectNickname')

	self.m_selectIdx = idx
	self.m_makeAccountFunc = make_account_func

	self:initUI()
    self:initButton()
    self:initEditBox()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_SelectNickname:initUI()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_SelectNickname:initButton()
    local vars = self.vars

    vars['createBtn']:registerScriptTapHandler(function() self:click_changeNickBtn() end)
	vars['closeBtn']:registerScriptTapHandler(function() self:close() end)
end

-------------------------------------
-- function initEditBox
-------------------------------------
function UI_SelectNickname:initEditBox()
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
			CheckNickName(str, proceed_func, cancel_func)
        end
    end

    vars['editBox']:setMaxLength(MAX_NICK)
    vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

-------------------------------------
-- function click_createBtn
-- @brief 계정 생성
-------------------------------------
function UI_SelectNickname:click_createBtn()
    local vars = self.vars
    local idx = self.m_selectIdx
    local nick = vars['editBox']:getText()

	local l_starting_data = UI_SelectStartingDragon.getStartingData()
    local user_type = l_starting_data[idx]['user_type']

    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('사용 할 닉네임을 입력하세요.'))
        return
    end

    local function finish_cb()
		self.m_makeAccountFunc()
		self:close()
	end

	g_startTamerData:request_createAccount(user_type, nil, nick, finish_cb)
end

-------------------------------------
-- function click_changeNickBtn
-- @brief 닉네임 변경
-------------------------------------
function UI_SelectNickname:click_changeNickBtn()
    local vars = self.vars
    local nick = vars['editBox']:getText()

    if (nick == '') then
        MakeSimplePopup(POPUP_TYPE.OK, Str('사용 할 닉네임을 입력하세요.'))
        return
    end

    local function finish_cb()
		self.m_makeAccountFunc()
		self:close()
	end

    --g_startTamerData:request_createAccount(user_type, nil, nick, finish_cb)
    g_userData:request_changeNick(nil, nil, nick, finish_cb)
end
