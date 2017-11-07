local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_ChatPopup
-------------------------------------
UI_ChatPopup = class(PARENT, {
        m_mTabUI = '',
        m_chatTableView = '',
     })

-------------------------------------
-- function init
-------------------------------------
function UI_ChatPopup:init()
    local vars = self:load('chat.ui')
    --UIManager:open(self, UIManager.NORMAL)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_closeBtn() end, 'UI_ChatPopup')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    --self:doActionReset()
    --self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    for i,msg in ipairs(g_chatManager.m_lMessage) do
        self:msgQueueCB(msg)
    end

    for i,msg in ipairs(g_clanChatManager.m_lMessage) do
        self:msgQueueCB_clan(msg)
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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ChatPopup:refresh()
    local vars = self.vars
end


-------------------------------------
-- function closeBtn
-------------------------------------
function UI_ChatPopup:click_closeBtn()
    self:close()
end

-------------------------------------
-- function click_enterBtn
-------------------------------------
function UI_ChatPopup:click_enterBtn()
    -- 채팅 비활성화 시
    if (g_chatIgnoreList:isGlobalIgnore()) then
        UIManager:toastNotificationRed(Str('채팅이 비활성화 상태입니다.'))
        return
    end

    local vars = self.vars

    local msg = vars['editBox']:getText()
    msg = utf8_sub(msg, CHAT_MAX_MESSAGE_LENGTH)

    local len = string.len(msg)
    if (len <= 0) then
        UIManager:toastNotificationRed('메시지를 입력하세요.')
        return
    end

    -- 비속어 필터링
    if (not FilterMsg(msg)) then
        vars['editBox']:setText('')
        UIManager:toastNotificationRed('사용할 수 없는 표현이 포함되어 있습니다.')
        return
    end

    if g_chatManager:sendNormalMsg(msg) then
        vars['editBox']:setText('')
    else
        UIManager:toastNotificationRed('메시지 전송에 실패하였습니다.')
    end
end

-------------------------------------
-- function click_blockListBtn
-------------------------------------
function UI_ChatPopup:click_blockListBtn()
    local visible = (not self.vars['blockNode']:isVisible())
    self.vars['blockNode']:setVisible(visible)

    if visible then
        self:refresh_blockUI()
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
        
            if (not self:confirmChannelName(channel_name)) then
                return
            end

            if (not g_chatManager:requestChangeChannel(channel_name)) then
                UIManager:toastNotificationRed('채널 이동 요청을 실패하였습니다.')
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
        UIManager:toastNotificationRed('1~9999 사이의 숫자를 입력해주세요.')
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