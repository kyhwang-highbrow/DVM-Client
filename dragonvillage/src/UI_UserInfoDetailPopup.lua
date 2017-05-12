local PARENT = UI

-------------------------------------
-- class UI_UserInfoDetailPopup
-------------------------------------
UI_UserInfoDetailPopup = class(PARENT, {
	m_tUserInfo = 'table',
	m_isVisit = 'bool',
})

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
	self.m_isVisit = not (t_user_info['uid'] == g_userData:get('uid'))

    self:initUI()
    self:initButton()
    self:refresh()

	if (self.m_isVisit) then
		self:setVisitMode()
	end
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
	local exp_per = 50.19
	vars['expLabel']:setString(string.format('%.2f%%', exp_per))
	vars['expGuage']:setPercentage(exp_per)

	-- 닉네임
	local nick_name = self.m_tUserInfo['nick']
	vars['nameLabel']:setString(nick_name)

	-- 칭호
	local title_str = self.m_tUserInfo['title'] or Str('칭호 없음')
	vars['titleLabel']:setString(title_str)

	-- 길드
	local guild_name = self.m_tUserInfo['guild'] or Str('길드 없음')
	vars['guildLabel']:setString(guild_name)
	
	-- 플레이 기록
	do
		local title_str, context_str = self:makeHistroyText()
		vars['historyLabel1']:setString(title_str)
		vars['historyLabel2']:setString(context_str)
	end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_UserInfoDetailPopup:initButton()
    local vars = self.vars
	vars['profileBtn']:registerScriptTapHandler(function() self:click_profileBtn() end)
	vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
	vars['dragonBtn']:registerScriptTapHandler(function() self:click_dragonBtn() end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_UserInfoDetailPopup:refresh()
    local vars = self.vars

	self:refresh_profile()
	self:refresh_tamer()
	self:refresh_dragon()
end

-------------------------------------
-- function refresh_profile
-------------------------------------
function UI_UserInfoDetailPopup:refresh_profile()
	local vars = self.vars

	vars['iconNode']:removeAllChildren(true)

	-- 프로필 아이콘
	-- vars['iconNode']:addChild()
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_UserInfoDetailPopup:refresh_tamer()
	local vars = self.vars

	vars['tamerNode']:removeAllChildren(true)

	-- 테이머 애니
	local tamer_id = 110000 + math_random(6) -- self.m_tUserInfo['tamer']
	local t_tamer = TableTamer():get(tamer_id)
	local illustration_res = t_tamer['res']
	local illustration_animator = MakeAnimator(illustration_res)
	illustration_animator:changeAni('idle', true)
	illustration_animator:setScale(0.6)
	illustration_animator.m_node:setPositionY(-150)
	vars['tamerNode']:addChild(illustration_animator.m_node)

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
	vars['starNode']:removeAllChildren(true)

	local t_dragon_data = StructDragonObject(self.m_tUserInfo['leader'])
	local did = t_dragon_data['did']
	local t_dragon = TableDragon():get(did)

	-- 드래곤 애니
	local animator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], t_dragon_data['evolution'], t_dragon['attr'])
	animator:setScale(0.6)
	vars['dragonNode']:addChild(animator.m_node)

	-- 드래곤 별
	local star_icon = IconHelper:getDragonGradeIcon(t_dragon_data:getGrade(), t_dragon_data:getEclv(), 2)
	vars['starNode']:addChild(star_icon)
	
	-- 드래곤 이름
	local dragon_name = t_dragon_data:getDragonNameWithEclv()
	vars['dragonLabel']:setString(dragon_name)
end


-------------------------------------
-- function setVisitMode
-------------------------------------
function UI_UserInfoDetailPopup:setVisitMode()
    local vars = self.vars
	vars['profileBtn']:setVisible(false)
	vars['tamerBtn']:setVisible(false)
	vars['dragonBtn']:setVisible(false)
end

local T_TITLE = {
	clr_stage_cnt = '클리어한 스테이지 수',
    play_cnt = '게임 플레이 횟수',
    clogin_max = '최대 연속 접속일',
    pvp_win = '콜로세움 누적 승률',
    tier = '현재 콜로세움 Tier',
    ancient_stage = '현재 고대의 탑 층 수',
    pvp_cnt = '콜로세움 누적 플레이 횟수',
    adv_time = '총 탐험 시간',
    d_6g_cnt = '6등급 드래곤의 수',
    d_cnt = '만난 드래곤 수',
    d_maxlv_cnt = 'Max 레벨 달성한 드래곤의 수',
    d_have_cnt = '현재 보유한 드래곤 수',
    created_at = '최초 접속일',
    cpoint = '테이머 포인트',
    login_days = '누적 접속일',
}

-------------------------------------
-- function makeHistroyText
-------------------------------------
function UI_UserInfoDetailPopup:makeHistroyText()
	local t_info = self.m_tUserInfo['info'] or {}
	local title_str = ''
	local context_str = ''

	for title, context in pairs(t_info) do
		title_str = title_str .. self:makeTitleByKey(title)  .. '\n'
		context_str = context_str .. self:makeContextByTitle(title, context) .. '\n'
	end

	return title_str, context_str
end

-------------------------------------
-- function makeTitleByKey
-------------------------------------
function UI_UserInfoDetailPopup:makeTitleByKey(key)
	local title = T_TITLE[key] or '미정의된 플레이 기록'
	
	return Str(title)
end

-------------------------------------
-- function makeContextByTitle
-------------------------------------
function UI_UserInfoDetailPopup:makeContextByTitle(key, value)
	local str

	if (key == 'pvp_win') then
		str = string.format('%.2f%%', value)

	elseif (key == 'tier') then
		str = ColosseumUserInfo:getTierName(value)

	elseif (key == 'ancient_stage') then
		str = value - 1401000

	elseif (key == 'created_at') then
		local date = pl.Date()
		date:set(value/1000)
		str = pl.Date.Format:tostring(date)

	else
		str = value
	end

	return str
end

-------------------------------------
-- function click_profileBtn
-- @brief-------------------------------------
function UI_UserInfoDetailPopup:click_profileBtn()
	ccdisplay('프로필 버튼은 준비중입니다.')
end

-------------------------------------
-- function click_tamerBtn
-------------------------------------
function UI_UserInfoDetailPopup:click_tamerBtn()
	local before_tamer = g_tamerData:getCurrTamerTable('type')

	local function close_cb()
		local curr_tamer = g_tamerData:getCurrTamerTable('type')

		if (before_tamer ~= curr_tamer) then
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
	ccdisplay('드래곤은 준비중입니다.')
end

-------------------------------------
-- function RequestUserDeckInfoPopup
-------------------------------------
function RequestUserInfoDetailPopup(peer_uid, close_cb)
	-- 유저 ID
    local uid = g_userData:get('uid')
	local peer_uid = peer_uid

    local function success_cb(ret)
		local t_user_info = ret['user_info']
        local ui = UI_UserInfoDetailPopup(t_user_info)
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
