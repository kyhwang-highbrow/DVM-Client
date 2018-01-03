local PARENT = UI

-------------------------------------
-- class UI_UserInfoMini
-------------------------------------
UI_UserInfoMini = class(PARENT, {
        m_structUserInfo = 'StruntUserInfo',
    })

-------------------------------------
-- function init
-- @param struct_user_info StructUserInfo
-------------------------------------
function UI_UserInfoMini:init(struct_user_info)
    self.m_uiName = 'UI_UserInfoMini'
    self.m_structUserInfo = struct_user_info

    local vars = self:load('lobby_user_info_02.ui')
    UIManager:open(self, UIManager.POPUP)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoMini')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function open
-- @param struct_user_info StructUserInfo
-------------------------------------
function UI_UserInfoMini:open(struct_user_info)
    if (g_userData:get('uid') == struct_user_info.m_uid) then
        return nil
    end

    return UI_UserInfoMini(struct_user_info)
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_UserInfoMini:click_exitBtn()
    self:close()
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoMini:initUI()
    local vars = self.vars
    
	self:refresh_dragon()

    local struct_user_info = self.m_structUserInfo

	-- 이름
    vars['nameLabel']:setString(struct_user_info:getNickname())

	-- 레벨
    vars['lvLabel']:setString(Str('레벨 {1}', struct_user_info:getLv()))

	-- 타이틀
    local title = struct_user_info:getTamerTitleStr()
    if (not title) or (title == '') then
        title = ''
    end
	vars['titleLabel']:setString(title)

	-- 클랜 정보
	do
		local struct_clan = struct_user_info:getStructClan()    
		if (not struct_clan) then
			vars['clanLabel']:setVisible(false)
			vars['markNode']:setVisible(false)
			return
		end

		-- 클랜 이름
		if (vars['clanLabel']) then
			local clan_name = struct_clan:getClanName()
			vars['clanLabel']:setString(clan_name)
		end

		-- 클랜 마크
		if (vars['markNode']) then
			local mark_icon = struct_clan:makeClanMarkIcon()
			vars['markNode']:addChild(mark_icon)
		end
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoMini:initButton(t_user_info)
    local vars = self.vars
    vars['closeBtn']:registerScriptTapHandler(function() self:click_exitBtn() end)
    vars['infoBtn']:registerScriptTapHandler(function() self:click_infoBtn() end)
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
	vars['clanBtn']:registerScriptTapHandler(function() self:click_clanBtn() end)

    vars['whisperBtn']:registerScriptTapHandler(function() self:click_whisperBtn() end)
    vars['blockBtn']:registerScriptTapHandler(function() self:click_blockBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoMini:refresh()
    local vars = self.vars
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_UserInfoMini:refresh_dragon()
	local vars = self.vars

	vars['dragonNode']:removeAllChildren(true)
	
	local t_dragon_data = self.m_structUserInfo:getLeaderDragonObject()
	local did = t_dragon_data['did']
	local t_dragon = TableDragon():get(did)

	-- 드래곤 애니
	local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
	vars['dragonNode']:addChild(animator.m_node)
end

-------------------------------------
-- function click_infoBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_infoBtn()
    local uid = self.m_structUserInfo:getUid()
    local is_visit = true
    RequestUserInfoDetailPopup(uid, is_visit)
end

-------------------------------------
-- function click_requestBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_requestBtn()
    local nickname = self.m_structUserInfo:getNickname()
    local function finish_cb(ret)
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', nickname)
        UIManager:toastNotificationGreen(msg)
    end

    local friend_ui = self.m_structUserInfo:getUid()
    g_friendData:request_invite(friend_ui, finish_cb)
end

-------------------------------------
-- function click_clanBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_clanBtn()
	local struct_user_info = self.m_structUserInfo
	local struct_clan = struct_user_info:getStructClan()
	if (not struct_clan) then
        local msg = Str('소속된 클랜이 없습니다.')
        UIManager:toastNotificationRed(msg)
		return
	end

	local clan_object_id = struct_clan:getClanObjectID()
	g_clanData:requestClanInfoDetailPopup(clan_object_id)
end

-------------------------------------
-- function click_whisperBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_whisperBtn()
   local nickname = self.m_structUserInfo:getNickname()
   g_chatManager:openChatPopup_whisper(nickname)
   self:close()
end

-------------------------------------
-- function click_blockBtn
-- @brief
-------------------------------------
function UI_UserInfoMini:click_blockBtn()
    local uid = self.m_structUserInfo:getUid()
    local nickname = self.m_structUserInfo:getNickname()
    g_chatIgnoreList:addIgnore(uid, nickname)
end





--@CHECK
UI:checkCompileError(UI_UserInfoMini)
