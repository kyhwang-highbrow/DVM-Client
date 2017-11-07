local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable())

local L_KEY_INDEX = {
	'created_at',
	'login_days',
	'clogin_max',
	
	'enter',
	
	'play_cnt',
	'clr_stage_cnt',
	'adv_time',
	
	'enter',
	
	'd_cnt',
	'd_maxlv_cnt',
	'd_6g_cnt',
	'd_have_cnt',

	'enter',

	'ancient_score',
	'tier',
	'pvp_cnt',
	'pvp_win',
}

local L_KEY_INDEX_VISIT = {
	'created_at',

	'enter',
	
	'd_cnt',
	'd_maxlv_cnt',
	'd_6g_cnt',
	'd_have_cnt',

	'enter',

	'ancient_score',
	'tier',
	'pvp_cnt',
	'pvp_win',
}


-------------------------------------
-- class UI_UserInfoDetailPopup
-------------------------------------
UI_UserInfoDetailPopup = class(PARENT, {
	m_tUserInfo = 'table',
	m_isVisit = 'bool',
    m_hasClan = 'bool'
})

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_UserInfoDetailPopup:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_UserInfoDetailPopup'
    self.m_bVisible = true
    self.m_titleStr = Str('유저 상세 정보')
    self.m_bUseExitBtn = true
    self.m_bShowChatBtn = true
end

-------------------------------------
-- function init
-------------------------------------
function UI_UserInfoDetailPopup:init(t_user_info, is_visit)
    self.m_uiName = 'UI_UserInfoDetailPopup'

    local vars = self:load('user_info.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:close() end, 'UI_UserInfoDetailPopup')

    self.m_tUserInfo = t_user_info
	self.m_isVisit = is_visit or (t_user_info['uid'] ~= g_userData:get('uid'))
    self.m_hasClan = t_user_info['clan_info'] and true or false

    self:initUI()
    self:initButton()
    self:refresh()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_UserInfoDetailPopup:initUI()
    local vars = self.vars
	
	-- 레벨
	local lv = self.m_tUserInfo['lv']
	vars['levelLabel']:setString(string.format('LV. %d', lv))

	-- 경험치 및 게이지
	local user_exp = self.m_tUserInfo['exp']
	local user_exp_per = TableUserLevel():getUserLevelExpPercentage(lv, user_exp)
	vars['expLabel']:setString(string.format('%.2f%%', user_exp_per))
	vars['expGuage']:setPercentage(user_exp_per)

	-- 닉네임
	local nick_name = self.m_tUserInfo['nick']
	vars['nameLabel']:setString(nick_name)

    -- 클랜
    if (self.m_hasClan) then
        local t_clan_info = self.m_tUserInfo['clan_info']
        local clan_name = t_clan_info['name']
        vars['clanLabel']:setString(clan_name)

        local clan_mark = StructClanMark:create(t_clan_info['mark'])
        local icon = clan_mark:makeClanMarkIcon()
        vars['markNode']:addChild(icon)
    else
        vars['clanLabel']:setVisible(false)
        vars['markNode']:setVisible(false)
    end

	-- 플레이 기록
	self:init_historyView()

    -- 방문시 처리
	self:setVisitMode(self.m_isVisit)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup:initButton()
    local vars = self.vars
	vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
	vars['dragonBtn']:registerScriptTapHandler(function() self:click_dragonBtn() end)
    vars['deckBtn']:registerScriptTapHandler(function() self:click_deckBtn() end)
    vars['requestBtn']:registerScriptTapHandler(function() self:click_requestBtn() end)
    vars['titleChangeBtn']:registerScriptTapHandler(function() self:click_titleChangeBtn() end)
    vars['dragonInfoBtn']:registerScriptTapHandler(function() self:click_dragonInfoBtn() end)

    if (self.m_hasClan) then
        vars['clanBtn1']:registerScriptTapHandler(function() self:click_clanBtn() end)
        vars['clanBtn2']:registerScriptTapHandler(function() self:click_clanBtn() end)
    else
        vars['clanBtn1']:setVisible(false)
        vars['clanBtn2']:setVisible(false)
    end

    --[[
    -- 사전 등록 닉네임
    if (not self.m_isVisit) then
        vars['couponBtn']:registerScriptTapHandler(function() self:click_nicknameCouponBtn() end)
        vars['couponBtn']:setVisible(false)
    end
    ]]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup:refresh()
    local vars = self.vars

    self:refresh_title()
	self:refresh_tamer()
	self:refresh_dragon()
end

-------------------------------------
-- function refresh_title
-------------------------------------
function UI_UserInfoDetailPopup:refresh_title()
	local vars = self.vars

    local title_id = self.m_tUserInfo['tamer_title']
    local title = TableTamerTitle:getTamerTitleStr(title_id)
    if (not title) or (title == '') then
        title = Str('칭호가 설정되어있지 않습니다.')
    end
	vars['titleLabel']:setString(title)
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_UserInfoDetailPopup:refresh_tamer()
	local vars = self.vars

	vars['tamerNode']:removeAllChildren(true)

	-- 테이머 애니
	local tamer_id = self.m_tUserInfo['tamer']
	local t_tamer = TableTamer():get(tamer_id)
    if (not t_tamer) then
        error('tamer_id : ' .. tamer_id)
    end
	local sd_res = t_tamer['res_sd']
	local sd_animator = MakeAnimator(sd_res)
	sd_animator:changeAni('idle', true)
	vars['tamerNode']:addChild(sd_animator.m_node)

	-- 테이머 이름
	local tamer_name = t_tamer['t_name']
	vars['tamerLabel']:setString(tamer_name)
end

-------------------------------------
-- function refresh_dragon
-------------------------------------
function UI_UserInfoDetailPopup:refresh_dragon()
	local vars = self.vars

	vars['dragonNode']:removeAllChildren(true)

	local t_dragon_data = StructDragonObject(self.m_tUserInfo['leader'])
	local did = t_dragon_data['did']
	local t_dragon = TableDragon():get(did)

	-- 드래곤 애니
	local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
	vars['dragonNode']:addChild(animator.m_node)

	-- 드래곤 이름
	local dragon_name = t_dragon_data:getDragonNameWithEclv()
	vars['dragonLabel']:setString(dragon_name)
end

-------------------------------------
-- function setVisitMode
-------------------------------------
function UI_UserInfoDetailPopup:setVisitMode(is_visit)
    local vars = self.vars
	vars['tamerBtn']:setVisible(not is_visit)
	vars['dragonBtn']:setVisible(not is_visit)
    vars['titleChangeBtn']:setVisible(not is_visit)

    -- 방문용
    vars['dragonInfoBtn']:setVisible(is_visit)
    vars['deckBtn']:setVisible(is_visit)
    
    -- 친구신청 버튼
    local friend_uid = self.m_tUserInfo['uid']
    local is_friend = g_friendData:isFriend(friend_uid)
    vars['requestBtn']:setVisible(is_visit and not is_friend)
end

-------------------------------------
-- function makeHistroyText
-------------------------------------
function UI_UserInfoDetailPopup:init_historyView()
	local vars = self.vars
	local node = vars['listNode']

	-- 구조화된 플레이 기록 리스트
	local l_item_list = self:makeHistoryList()

	-- cell size 정의
	local width = vars['listNode']:getContentSize()['width']
	local height = 30 + 2

	-- ui class 없이 생성
	local create_func = function(data)
		local ui = class(UI, ITableViewCell:getCloneTable())()
		ui:load('user_info_history_item.ui')
		
		local vars = ui.vars
		vars['historyLabel1']:setString(data['title'])
		vars['historyLabel2']:setString(data['context'])

		return ui
    end

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(width, height)
    table_view:setCellUIClass(create_func)
	table_view:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    table_view:setItemList(l_item_list)
end

-------------------------------------
-- function makeHistroyText
-------------------------------------
function UI_UserInfoDetailPopup:makeHistoryList()
	local t_info = self.m_tUserInfo['info'] or {}
	local l_ret = {}
    local l_key_list = nil
	local title_str = ''
	local context_str = ''

    if (self.m_isVisit) then
        l_key_list = clone(L_KEY_INDEX_VISIT)
    else
        l_key_list = clone(L_KEY_INDEX)
    end

	for _, title in pairs(l_key_list) do
		context = t_info[title]
		title_str = getUserInfoTitle(title)
		context_str = self:makeContextByTitle(title, context)

		table.insert(l_ret, {title = title_str, context = context_str})
	end

	return l_ret
end

-------------------------------------
-- function makeContextByTitle
-------------------------------------
function UI_UserInfoDetailPopup:makeContextByTitle(key, value)
	if (not value) then
		if (key == 'enter') then
			return ''
		else
			return '-'
		end
	end

	local str

	if (key == 'pvp_win') then
		local pvp_cnt = self.m_tUserInfo['info']['pvp_cnt']
		
		value = (pvp_cnt == 0) and (0) or (value/pvp_cnt) * 100

		str = string.format('%.2f%%', value)

	elseif (key == 'tier') then
		str = StructUserInfoColosseum:getTierName(value)

	elseif (key == 'created_at') then
		-- 날짜 정보 세팅
		local date = pl.Date()
		date:set(value/1000)

		-- 날짜 포맷 세팅
		local date_format = pl.Date.Format('yyyy-mm-dd')
		str = date_format:tostring(date)

	else
		str = value

	end

	return str
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_exitBtn()
	self:close()
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_tamerBtn()
	local before_tamer = g_tamerData:getCurrTamerTable('tid')

	local function close_cb()
		local curr_tamer = g_tamerData:getCurrTamerTable('tid')

		if (before_tamer ~= curr_tamer) then
			self.m_tUserInfo['tamer'] = curr_tamer
			self:refresh_tamer()
		end
	end

    local ui = UI_TamerManagePopup()
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_dragonBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_dragonBtn()
	local before_doid = self.m_tUserInfo['leader']['id']

	local function close_cb()
		local curr_doid = self.m_tUserInfo['leader']['id']

		if (before_doid ~= curr_doid) then
			self:refresh_dragon()
		end
	end

	local ui = UI_UserInfoDetailPopup_SetLeader(self.m_tUserInfo)
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_deckBtn
-- @brief 상대의 방어덱을 본다.. 왜 방어덱만?
-------------------------------------
function UI_UserInfoDetailPopup:click_deckBtn()
    local uid = self.m_tUserInfo['uid']
    local deck_name = 'def'
    RequestUserDeckInfoPopup(uid, deck_name)
end

-------------------------------------
-- function click_requestBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_requestBtn()
    local nickname = self.m_tUserInfo['nick']
    local function finish_cb(ret)
        local msg = Str('[{1}]에게 친구 요청을 하였습니다.', nickname)
        UIManager:toastNotificationGreen(msg)
    end

    local friend_ui = self.m_tUserInfo['uid']
    g_friendData:request_invite(friend_ui, finish_cb)
end

-------------------------------------
-- function click_titleChangeBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_titleChangeBtn()
    local function cb_func(l_title_list)
        local ui = UI_UserInfoDetailPopup_SetTitle(l_title_list)
        local curr_title_id = self.m_tUserInfo['tamer_title']

        ui:setCloseCB(function(title_id)
            if (curr_title_id ~= title_id) then
                self.m_tUserInfo['tamer_title'] = title_id
                self:refresh_title()
            end
        end)
    end
    g_userData:request_getTitleList(cb_func)
end

-------------------------------------
-- function click_clanBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_dragonInfoBtn()
    ccdisplay('드래곤 정보 보기는 구현중입니다.')
end

-------------------------------------
-- function click_clanBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_clanBtn()
    if (not self.m_hasClan) then
        return
    end

    local clan_object_id = self.m_tUserInfo['clan_info']['id']
    g_clanData:requestClanInfoDetailPopup(clan_object_id)
end

-------------------------------------
-- function click_nicknameCouponBtn
-- @brief 사전 등록 닉네임
-------------------------------------
function UI_UserInfoDetailPopup:click_nicknameCouponBtn()
--[[
    local ui = UI_CouponPopupPreOccupancyNick:open()
    if (not ui) then
        return
    end

    local function close_cb()
        if (ui.m_couponCode and ui.m_retNick) then
            local function cb_func(ret)
                UI_ToastPopup(Str('{1}(으)로 변경되었습니다.', ret['nick']))

                -- 닉네임
	            local nick_name = self.m_tUserInfo['nick']
	            self.vars['nameLabel']:setString(ret['nick'])
            end

            g_userData:request_changeNick(nil, ui.m_couponCode, ui.m_retNick, cb_func)
        end
    end

    ui:setCloseCB(close_cb)
    ]]
end


-------------------------------------
-- function RequestUserInfoDetailPopup
-------------------------------------
function RequestUserInfoDetailPopup(peer_uid, is_visit, close_cb)
	-- 유저 ID
    local uid = g_userData:get('uid')
	local peer_uid = peer_uid

    local function success_cb(ret)
		local t_user_info = ret['user_info']
        local ui = UI_UserInfoDetailPopup(t_user_info, is_visit)
		ui:setCloseCB(close_cb)
    end

    local ui_network = UI_Network()
    ui_network:setRevocable(true)
    ui_network:setUrl('/users/get/user_info')
	ui_network:setParam('uid', uid)
    ui_network:setParam('peer', peer_uid)
    ui_network:setSuccessCB(success_cb)
    ui_network:request()    
end

--@CHECK
UI:checkCompileError(UI_UserInfoDetailPopup)