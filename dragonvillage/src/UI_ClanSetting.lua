local PARENT = UI

-------------------------------------
-- class UI_ClanSetting
-------------------------------------
UI_ClanSetting = class(PARENT, {
        m_bChangedClanSet = 'bool',
        m_bRet = 'bool',

        -- clan value
        m_structClanMark = 'StructClanMark',
        m_clanAutoJoin = 'boolean',
        m_clanIntroText = 'string',
        m_clanNoticeText = 'string',

        m_clanJoinRadioBtn = 'UIC_RadioBtn',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ClanSetting:init()
    local vars = self:load('clan_setting.ui')
    UIManager:open(self, UIManager.POPUP)

    self.m_uiName = 'UI_ClanSetting'
    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_ClanSetting')

    -- @UI_ACTION
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    g_clanData.m_needClanSetting = false
    self.m_bRet = false
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ClanSetting:click_exitBtn()
    self:close()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ClanSetting:initUI()
    local vars = self.vars
    
    self:initEditBox()
    self:initJoinRadioBtn()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanSetting:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['disbandBtn']:registerScriptTapHandler(function() self:click_disbandBtn() end)
    vars['leaveBtn']:registerScriptTapHandler(function() self:click_leaveBtn() end)
    vars['markBtn']:registerScriptTapHandler(function() self:click_markBtn() end)
    vars['okBtn']:registerScriptTapHandler(function() self:click_okBtn() end)
    vars['noticeChangeBtn']:registerScriptTapHandler(function() self:click_noticeChangeBtn() end)
    vars['introduceChangeBtn']:registerScriptTapHandler(function() self:click_introduceChangeBtn() end)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ClanSetting:initEditBox()
    local vars = self.vars

    -- intro editBox handler 등록
	local function intro_event_handler(event_name, p_sender)
        if (event_name == "changed") then
            local editbox = p_sender
            local str = editbox:getText()
            vars['introduceLabel']:setString(str)
            self.m_clanIntroText = str
            self.m_bChangedClanSet = true
        end
    end
    vars['introduceEditBox']:registerScriptEditBoxHandler(intro_event_handler)

    -- notice editBox handler 등록
	local function notice_event_handler(event_name, p_sender)
        if (event_name == "changed") then
            local editbox = p_sender
            local str = editbox:getText()
            vars['noticeLabel']:setString(str)
            self.m_clanNoticeText = str
            self.m_bChangedClanSet = true
        end
    end
    vars['noticeEditBox']:registerScriptEditBoxHandler(notice_event_handler)
end

-------------------------------------
-- function initJoinRadioBtn
-- @brief
-------------------------------------
function UI_ClanSetting:initJoinRadioBtn()
	local vars = self.vars

	-- radio button 선언
    local radio_button = UIC_RadioButton()
	radio_button:setChangeCB(function(join_type)
        self.m_clanAutoJoin = join_type
        self.m_bChangedClanSet = true
    end)
	self.m_clanJoinRadioBtn = radio_button

    -- 버튼 등록
	for i, join_type in ipairs({true, false}) do
		local join_btn = vars['joinTypeBtn' .. i]
        local join_sprite = vars['joinTypeSprite' .. i]
		radio_button:addButton(join_type, join_btn, join_sprite)
	end 
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ClanSetting:refresh()
    local vars = self.vars

    local struct_clan = g_clanData:getClanStruct()

    -- 클랜 마크
    self:refresh_mark()

    -- 클랜 이름
    local clan_name = struct_clan:getClanName()
    vars['nameLabel']:setString(clan_name)

    -- 클랜 가입 방식
    local clan_join = struct_clan:getClanJoin()
    self.m_clanJoinRadioBtn:setSelectedButton(clan_join)

    -- 클랜 소개
    local clan_intro = struct_clan:getClanIntro() or vars['introduceEditBox']:getText()
    vars['introduceLabel']:setString(clan_intro)

    -- 클랜 공지사항
    local clan_notice = struct_clan:getClanNotice() or vars['noticeEditBox']:getText()
    vars['noticeLabel']:setString(clan_notice)

    -- 탈퇴 / 해체 버튼 처리
    self:refresh_auth()

    -- 초기화도 한번 해준다.
    self.m_bChangedClanSet = false
    self.m_structClanMark = nil
    self.m_clanAutoJoin = nil
    self.m_clanIntroText = nil
    self.m_clanNoticeText = nil
end

-------------------------------------
-- function refresh_mark
-- @brief 마크만 갱신
-------------------------------------
function UI_ClanSetting:refresh_mark()
    local vars = self.vars
    local struct_clan_mark = self:getClanMarkStruct()
    local icon = struct_clan_mark:makeClanMarkIcon()
    vars['markNode']:removeAllChildren()
    vars['markNode']:addChild(icon)
end

-------------------------------------
-- function refresh_auth
-------------------------------------
function UI_ClanSetting:refresh_auth()
    local vars = self.vars

    local is_member = (g_clanData:getMyMemberType() == 'member')

    vars['disbandBtn']:setVisible(not is_member)
    vars['leaveBtn']:setVisible(is_member)
    vars['noticeChangeBtn']:setVisible(not is_member)
    vars['introduceChangeBtn']:setVisible(not is_member)
    vars['okBtn']:setVisible(not is_member)
    vars['markBtn']:setVisible(not is_member)
end

-------------------------------------
-- function click_introduceChangeBtn
-- @brief 클랜 소개 변경
-------------------------------------
function UI_ClanSetting:click_introduceChangeBtn()
    self.vars['introduceEditBox']:openKeyboard()
end

-------------------------------------
-- function click_noticeChangeBtn
-- @brief 공지사항 변경
-------------------------------------
function UI_ClanSetting:click_noticeChangeBtn()
    self.vars['noticeEditBox']:openKeyboard()
end

-------------------------------------
-- function click_disbandBtn
-- @brief 클랜 해체
-------------------------------------
function UI_ClanSetting:click_disbandBtn()

    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('클랜을 해체하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_func)
    end

    request_func = function()
        g_clanData:request_clanDestroy(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜이 해체되었습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_leaveBtn
-- @brief 클랜 탈퇴
-------------------------------------
function UI_ClanSetting:click_leaveBtn()

    local ask_func
    local request_func
    local popup_func
    local finish_cb

    ask_func = function()
        local msg = Str('클랜을 탈퇴하시겠습니까?')
        MakeSimplePopup(POPUP_TYPE.YES_NO, msg, request_func)
    end

    request_func = function()
        g_clanData:request_clanExit(popup_func)
    end

    popup_func = function()
        local msg = Str('클랜에서 탈퇴하였습니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg, finish_cb)
    end

    finish_cb = function(ret)
        if g_clanData:isNeedClanInfoRefresh() then
            UINavigator:closeClanUI()
            UINavigator:goTo('clan')
        end
    end

    ask_func()
end

-------------------------------------
-- function click_markBtn
-- @brief 클랜 마크
-------------------------------------
function UI_ClanSetting:click_markBtn()
    local ui = UI_ClanMarkTwo(self:getClanMarkStruct())

    local function close_cb()
        if ui.m_bChanged then
            self.m_bChangedClanSet = true
            self.m_structClanMark = ui.m_structClanMark
            self:refresh_mark()
        end
    end
    ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_okBtn
-- @brief 적용 버튼
-------------------------------------
function UI_ClanSetting:click_okBtn()
    local finish_cb = function()
        self.m_bRet = true
        local msg = Str('변경사항이 적용되었습니다.')
        local ok_cb = function()
            self:close()
        end
        MakeSimplePopup(POPUP_TYPE.OK, msg, ok_cb)
    end

    if (not self.m_bChangedClanSet) then
        ccdisplay('변경 사항이 없습니다.')
        self:close()
        return
    end

    local fail_cb = nil

    local intro = self.m_clanIntroText
    local notice = self.m_clanNoticeText
    local join = self.m_clanAutoJoin
    local mark = self.m_structClanMark and self.m_structClanMark:tostring() or nil

    g_clanData:request_clanSetting(finish_cb, fail_cb, intro, notice, join, mark)
end

-------------------------------------
-- function getClanMarkStruct
-- @brief
-------------------------------------
function UI_ClanSetting:getClanMarkStruct()
    if self.m_structClanMark then
        return self.m_structClanMark
    end

    local struct_clan = g_clanData:getClanStruct()
    return struct_clan.m_structClanMark
end

--@CHECK
UI:checkCompileError(UI_ClanSetting)
