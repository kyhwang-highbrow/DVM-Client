local PARENT = UI

local MIN_NICK = 2
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

    vars['createBtn']:registerScriptTapHandler(function() self:click_createBtn() end)
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

    local finish_cb = self.m_makeAccountFunc
    g_startTamerData:request_createAccount(user_type, nil, nick, finish_cb)
end
