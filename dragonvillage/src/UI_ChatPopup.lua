local PARENT = class(UI, ITabUI:getCloneTable())
local MACRO_INTERVAL = 3

-------------------------------------
-- class UI_ChatPopup
-------------------------------------
UI_ChatPopup = class(PARENT, {
        m_mTabUI = '',
        m_chatTableView = '',
		m_prevMacroTime = 'timer',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup:init()
    self.m_uiName = 'UI_ChatPopup'
    local vars = self:load('chat.ui')
    --UIManager:open(self, UIManager.NORMAL)

    -- backkey 지정
    --g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ChatPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

	self.m_prevMacroTime = 0

    self:initUI()
    self:initButton()
    self:refresh()

    for i,msg in ipairs(g_chatManager.m_lMessage) do
        self:msgQueueCB(msg)
    end

    if (g_clanChatManager) then
        for i,msg in ipairs(g_clanChatManager.m_lMessage) do
            self:msgQueueCB_clan(msg)
        end
    end

    self:refresh_connectStatus(g_chatManager:getStatus())
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_ChatPopup:initUI()
    local vars = self.vars
    
    do -- 채팅 EditBox에서 입력 완료 후 바로 전송하기
        local function editBoxTextEventHandle(strEventName,pSender)
            if (strEventName == "return") then
                self:click_enterBtn()
            end
        end
        vars['editBox']:registerScriptEditBoxHandler(editBoxTextEventHandle)
        vars['editBox']:setMaxLength(CHAT_MAX_MESSAGE_LENGTH) -- 글자 입력 제한 40자
    end

    self:init_tableView()

    self:initTab()
end

-------------------------------------
-- function init_tableView
-------------------------------------
function UI_ChatPopup:init_tableView()
    local vars = self.vars
    local node = vars['chatNode']

    self.m_chatTableView = UIC_ChatView(node)
end


-------------------------------------
-- function initButton
-------------------------------------
function UI_ChatPopup:initButton()
    local vars = self.vars

    vars['closeBtn']:registerScriptTapHandler(function() self:click_closeBtn() end)
    vars['enterBtn']:registerScriptTapHandler(function() self:click_enterBtn() end)
    vars['blockListBtn']:registerScriptTapHandler(function() self:click_blockListBtn() end)
    vars['macroBtn']:registerScriptTapHandler(function() self:click_macroBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function click_closeBtn
-------------------------------------
function UI_ChatPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enterBtn
-- @brief 일반 채팅 전송
-------------------------------------
function UI_ChatPopup:click_enterBtn()
	local edit_box = self.vars['editBox']
	local msg = edit_box:getText()
	self.sendMsg(msg, self.m_currTab, edit_box)
end

-------------------------------------
-- function click_macroListItem
-- @brief 매크로 채팅 전송
-------------------------------------
function UI_ChatPopup:click_macroListItem(msg)
	local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
	
	-- 매크로 성공
	if (curr_time - self.m_prevMacroTime > MACRO_INTERVAL) then
		self.sendMsg(msg, self.m_currTab, nil, self.m_mTabUI['whisper'].m_peerUserNickname)
		self.m_prevMacroTime = curr_time

	-- 매크로 쿨타임
	else
		local ramain_time = math_ceil(MACRO_INTERVAL - (curr_time - self.m_prevMacroTime) + 1)
		UIManager:toastNotificationRed(Str('재사용까지 {1}초 남았습니다.', ramain_time))
	end
end

-------------------------------------
-- function sendMsg
-- @param msg : 전송할 메세지
-- @param tab : 현재 탭, 어느 곳에 메세지를 보낼 지 결정한다
-- @param edit_box : 메세지를 지울 에딧박스 @Nullable
-- @param whisper_nick : 귓말 보낼 유저 닉네임
-- @comment 매크로 처리를 위해서 하나로 합침
-------------------------------------
function UI_ChatPopup.sendMsg(msg, tab, edit_box, whisper_nick)
    -- 채팅 비활성화 시
    if (g_chatIgnoreList:isGlobalIgnore()) then
        UIManager:toastNotificationRed(Str('채팅이 비활성화 상태입니다.'))
        return
    end

    local msg = utf8_sub(msg, CHAT_MAX_MESSAGE_LENGTH)
    local len = string.len(msg)
    if (len <= 0) then
        UIManager:toastNotificationRed(Str('메시지를 입력하세요.'))
        return
    end

    -- 비속어 필터링
    local function proceed_func()
		-- 현재 탭에 따라 메세지 전송 분기 처리
		local chat_ret = false
		if (tab == 'general') then
			chat_ret = g_chatManager:sendNormalMsg(msg)

		elseif (tab == 'clan') then
			chat_ret = g_clanChatManager:sendNormalMsg(msg)

		elseif (tab == 'whisper') then
			if (whisper_nick) then
				chat_ret = g_chatManager:sendWhisperMsg(whisper_nick, msg)
			else
				UIManager:toastNotificationRed(Str('귓속말 상대방 닉네임을 입력하세요.'))
				return
			end

		end

        if (chat_ret) then
			if (edit_box) then
				edit_box:setText('')
			end
        else
			local msg
			if (tab == 'whisper') then
				msg = Str('[{1}]유저를 찾을 수 없습니다.', whisper_nick)
			else
				msg = Str('메시지 전송에 실패하였습니다.')
			end
            UIManager:toastNotificationRed(msg)
        end
    end
    local function cancel_func()
		if (edit_box) then
			edit_box:setText('')
		end
    end
    CheckBlockStr(msg, proceed_func, cancel_func)
end

-------------------------------------
-- function click_blockListBtn
-------------------------------------
function UI_ChatPopup:click_blockListBtn()
    local vars = self.vars
    local visible = (not vars['blockNode']:isVisible())
    vars['blockNode']:setVisible(visible)

    if visible then
        self:refresh_blockUI()
    end

    -- 매크로리스트가 켜져있다면 꺼준다.
    if (vars['macroNode']:isVisible()) then
        vars['macroNode']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_blockUI
-------------------------------------
function UI_ChatPopup:refresh_blockUI()
    local vars = self.vars

    local str = Str('차단 목록 ({1}/30)', g_chatIgnoreList:getIgnoreCount())
    vars['blockListLabel']:setString(str)

    do
        local node = vars['blockListNode']
        node:removeAllChildren()

        local l_item_list = g_chatIgnoreList:getIgnoreList()
        local table_view

        -- 생성 콜백
        local function create_func(ui, data)
            ui.vars['cancelBtn']:registerScriptTapHandler(function()
                    local uid = data['uid']
                    local nickname = data['nickname']
                    g_chatIgnoreList:removeIgnore(uid, nickname)

                    table_view:delItem(uid)
                end)
        end

        -- 테이블 뷰 인스턴스 생성
        table_view = UIC_TableView(node)
        table_view.m_defaultCellSize = cc.size(254, 100 + 3)
        table_view:setCellUIClass(UI_ChatIgnoreListItem, create_func)
        table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        table_view:setItemList(l_item_list)

    end
end

-------------------------------------
-- function click_macroBtn
-------------------------------------
function UI_ChatPopup:click_macroBtn()
    local vars = self.vars
    local visible = (not vars['macroNode']:isVisible())
    vars['macroNode']:setVisible(visible)

    if visible then
        self:refresh_macroUI()
    end

    -- 차단 리스트가 켜져있다면 꺼준다
    if (vars['blockNode']:isVisible()) then
        vars['blockNode']:setVisible(false)
    end
end

-------------------------------------
-- function refresh_macroUI
-------------------------------------
function UI_ChatPopup:refresh_macroUI()
    local vars = self.vars

    local node = vars['macroListNode']
    node:removeAllChildren()

    local l_item_list = g_chatMacroData:getMacroTable()
    local table_view

    -- 생성 콜백
    local function create_func(ui, data)
        ui.vars['macroBtn']:registerScriptTapHandler(function()
            local msg = ui.m_macro
            self:click_macroListItem(msg)
        end)
    end

    -- 테이블 뷰 인스턴스 생성
    table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(340, 64 + 3)
    table_view:setCellUIClass(UI_ChatMacroListItem, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function msgQueueCB
-------------------------------------
function UI_ChatPopup:msgQueueCB(chat_content)
    local category = chat_content:getContentCategory()    

    -- 서버와의 연결 상태
    if (category == 'change_status') then
        local status = chat_content['message']
        self:refresh_connectStatus(status)

    elseif (category == 'general') then
        self.m_chatTableView:addChatContent(chat_content)

    elseif (category == 'whisper') then
        self.m_mTabUI['whisper']:msgQueueCB(chat_content)
    end
end

-------------------------------------
-- function msgQueueCB_clan
-------------------------------------
function UI_ChatPopup:msgQueueCB_clan(chat_content)
    self.m_mTabUI['clan']:msgQueueCB(chat_content)
end

-------------------------------------
-- function refresh_channelName
-------------------------------------
function UI_ChatPopup:refresh_channelName(channel_name)
    local str = Str('채널 {1}', channel_name)
    self.vars['sortOrderLabel']:setString(str)
end

-------------------------------------
-- function refresh_clanName
-------------------------------------
function UI_ChatPopup:refresh_clanName(clan_name)
    --self.vars['clanNameLabel']:setString(clan_name)
end

-------------------------------------
-- function refresh_connectStatus
-------------------------------------
function UI_ChatPopup:refresh_connectStatus(status)
    local vars = self.vars

    if (status == 'Success') then
        vars['connectLabel']:setString(Str('연결됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 119, 255, 0))

    elseif (status == 'Connecting') then
        vars['connectLabel']:setString(Str('연결 중'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 255, 18))

    elseif (status == 'Disconnected') then
        vars['connectLabel']:setString(Str('연결 해제됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 35, 18))

    elseif (status == 'Closed') then
        vars['connectLabel']:setString(Str('연결 해제됨'))
        vars['connectSprite']:stopAllActions()
        vars['connectSprite']:runAction(cc.TintTo:create(0.2, 255, 35, 18))

    end
end

-------------------------------------
-- function onDestroyUI
-------------------------------------
function UI_ChatPopup:onDestroyUI()
    self.vars['blockNode']:setVisible(false)
    self.vars['macroNode']:setVisible(false)
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ChatPopup:initTab()
    self.m_mTabUI = {}
    self.m_mTabUI['whisper'] = UI_ChatPopup_WhisperTab(self)
    self.m_mTabUI['clan'] = UI_ChatPopup_ClanTab(self)

    local vars = self.vars
    self:addTabAuto('general', vars, vars['generalMenu'])
    self:addTabAuto('whisper', vars, vars['whisperMenu'])
    self:addTabAuto('clan', vars, vars['clanMenu'])
    self:setTab('general')
end

-------------------------------------
-- function openPopup
-------------------------------------
function UI_ChatPopup:openPopup()
    UIManager:open(self, UIManager.NORMAL)
    -- backkey 지정
    -- 매번 열어줄 때마다 한번씩 씬 backkey를 설정해 주어야 한다.
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ChatPopup')
    self.closed = false

    -- @UI_ACTION
    self:doActionReset()
    self:doAction()

    self:onChangeTab(self.m_currTab, false)

    -- 채팅 비활성화 시
    if (g_chatIgnoreList:isGlobalIgnore()) then
        UIManager:toastNotificationRed(Str('채팅이 비활성화 상태입니다.'))
        return
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ChatPopup:onChangeTab(tab, first)
    local vars = self.vars

    -- 뱃지 UI
    if (tab == 'general') then
        g_chatManager:removeNoti('general')
    elseif (tab == 'whisper') then
        g_chatManager:removeNoti('whisper')
    elseif (tab == 'clan') then
        g_clanChatManager:removeNoti()
    end

    if (tab == 'general') then
        local channel_name = g_chatManager:getChannelName()
        local str = Str('채널 {1}', channel_name or '')
        vars['sortOrderLabel']:setString(str)
        vars['sortBtn']:registerScriptTapHandler(function() self:click_changeChannelBtn() end)
    end

    if self.m_mTabUI[tab] then
        self.m_mTabUI[tab]:onEnterTab(first)
    end
end

-------------------------------------
-- function click_changeChannelBtn
-------------------------------------
function UI_ChatPopup:click_changeChannelBtn()
    local edit_box = UI_SimpleEditBoxPopup()
    edit_box:setPopupTitle(Str('이동할 채널 번호를 입력해주세요. (1~9999)'))
    edit_box:setPopupDsc(Str('이동할 채널 번호를 입력해주세요. (1~9999)'))
    edit_box:setPlaceHolder(Str('입력하세요.'))

    local function confirm_cb(str)
        return self:confirmChannelName(str)
    end
    edit_box:setConfirmCB(confirm_cb)

    local function close_cb()
        if (edit_box.m_retType == 'ok') then
            local channel_name = edit_box.m_str

            -- 채팅 채널에서 소수점을 지원하지 않음
            local channel_name_num = tonumber(edit_box.m_str)
            if (channel_name_num ~= nil) then
                channel_name = math_floor(channel_name_num)
            end
        
            if (not self:confirmChannelName(channel_name)) then
                return
            end

            if (not g_chatManager:requestChangeChannel(channel_name)) then
                UIManager:toastNotificationRed(Str('채널 이동 요청을 실패하였습니다.'))
            end
        end
    end
    edit_box:setCloseCB(close_cb)
end

-------------------------------------
-- function confirmChannelName
-- @brief 채널이 1~9999 사이의 숫자인지 체크
-------------------------------------
function UI_ChatPopup:confirmChannelName(channel_name)
    local channel_num = tonumber(channel_name)

    if (not channel_num) or (channel_num <= 0) or (9999 < channel_num) then
        UIManager:toastNotificationRed(Str('1~9999 사이의 숫자를 입력해주세요.'))
        return false
    end

    return true
end

-------------------------------------
-- function setWhisperUser
-------------------------------------
function UI_ChatPopup:setWhisperUser(nickname)
    self:setTab('whisper')
    self.m_mTabUI['whisper']:setPeerUserNickname(nickname)
    self.m_mTabUI['whisper'].vars['editBox_whisper']:openKeyboard()
end

-------------------------------------
-- function isVisibleCategory
-------------------------------------
function UI_ChatPopup:isVisibleCategory(category)
    if self.closed then
        return false
    end

    if (self.m_currTab == category) then
        return true
    end

    return false
end