local PARENT = UI
local WAITING_TIME = 10

-------------------------------------
-- class UI_LoadingArenaNew
-------------------------------------
UI_LoadingArenaNew = class(PARENT,{
        m_lLoadingStrList = 'List<string>',
        m_bFriendMatch = 'boolean',

        m_remainTimer = 'number',
        m_bSelected = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingArenaNew:init()
	self.m_uiName = 'UI_LoadingArenaNew'

    self.m_remainTimer = WAITING_TIME
    self.m_bSelected = false

	local vars = self:load('arena_new_loading.ui')

	if (guide_type) then
		self.m_lLoadingStrList = table.sortRandom(GetLoadingStrList())
	end
    
	self:initUI()
    self:initButton()

    -- 자체적으로 업데이트를 돌린다.
	self.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingArenaNew:initUI()
    local vars = self.vars
    local is_friend_match = self.m_bFriendMatch

	vars['arenaVisual']:setVisible(true)
	--vars['challengeModeVisual']:setVisible(false)

	-- 플레이어
    do
		local struct_user_info = is_friend_match and g_friendMatchData.m_playerUserInfo or g_arenaNewData:getPlayerArenaUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('left', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('left', struct_user_info)
		end
    end

	 -- 상대방
    do
		local struct_user_info = is_friend_match and g_friendMatchData.m_matchInfo or g_arenaNewData:getMatchUserInfo()
		if (struct_user_info) then
			-- 덱
			local l_dragon_obj = struct_user_info:getDeck_dragonList()

            ccdump(struct_user_info.m_pvpDeck)
			local leader = struct_user_info.m_pvpDeck['leader']
			local formation = struct_user_info.m_pvpDeck['formation']
			self:initDeckUI('right', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('right', struct_user_info)
		end
    end

    -- 연속 전투 상태 여부에 따라 버튼이나 로딩 게이지 표시
    do
        local is_autoplay = g_autoPlaySetting:isAutoPlay()
    
        vars['btnNode']:setVisible(not is_autoplay)
        vars['loadingNode']:setVisible(is_autoplay)
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingArenaNew:initButton()
    local vars = self.vars

    -- 수동 전투
    vars['manualBtn']:registerScriptTapHandler(function()
        self:selectAuto(false)
    end)

    -- 자동 전투
    vars['autoBtn']:registerScriptTapHandler(function()
        self:selectAuto(true)
    end)
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingArenaNew:refresh()
end

-------------------------------------
-- function initDeckUI
-- @param direction 'left' or 'light'
-------------------------------------
function UI_LoadingArenaNew:initDeckUI(direction, l_dragon_obj, leader, formation)

    local vars = self.vars
    local parent_node
    if (direction == 'left') then
        parent_node = vars['formationNode1']
    elseif (direction == 'right') then
        parent_node = vars['formationNode2']
    end

    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection(direction)
    parent_node:addChild(player_2d_deck.root)
    player_2d_deck:initUI()

    -- 드래곤 생성 (리더도 함께)
    player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
    -- 진형 설정
    player_2d_deck:setFormation(formation)
end

-------------------------------------
-- function initUserInfo
-------------------------------------
function UI_LoadingArenaNew:initUserInfo(direction, struct_user_info)
	local vars = self.vars
    local struct_clan = struct_user_info:getStructClan()
    local icon

	local idx
    if (direction == 'left') then
        idx = 1
    elseif (direction == 'right') then
        idx = 2
    end

    -- 티어
	if (struct_user_info.m_tier ~= nil) then
		icon = struct_user_info:makeTierIcon(nil, 'small')
		if (icon) then
			vars['tierNode' .. idx]:addChild(icon)
		end
	end

    -- 랭킹
    vars['rankLabel' .. idx]:setString(struct_user_info:getRankText(true))

    -- 레벨, 닉네임
    vars['userLabel' .. idx]:setString(struct_user_info:getUserText())

    -- 클랜
    local clan_name = struct_clan and struct_clan:getClanName() or ''
    vars['clanLabel' .. idx]:setString(clan_name)

    icon = struct_clan and struct_clan:makeClanMarkIcon()
    if (icon) then
        vars['markNode' .. idx]:addChild(icon)
    end

    -- 전투력
    local str = struct_user_info:getDeckCombatPower()
    vars['powerLabel' .. idx]:setString(Str('전투력 : {1}', str))

    -- 아이콘
    icon = struct_user_info:getDeckTamerIcon()
    if (icon) then
        vars['tamerNode' .. idx]:addChild(icon)
    end
end

-------------------------------------
-- function prepare
-------------------------------------
function UI_LoadingArenaNew:prepare()
    return self.m_bSelected
end

-------------------------------------
-- function update
-------------------------------------
function UI_LoadingArenaNew:update(dt)
    if (self.m_bSelected) then return end

    local prev = math_floor(self.m_remainTimer)
    self.m_remainTimer = self.m_remainTimer - dt

    local next = math_floor(self.m_remainTimer)

    if (self.m_remainTimer <= 0) then
        -- 타임아웃시 자동모드 강제 설정
        self:selectAuto(true)

    elseif (prev ~= next) then
        local msg = Str('{1}초 후 전투가 시작됩니다.', next)
        local label = self.vars['countdownLabel']
        label:setString(msg)
        cca.uiReactionSlow(label)
    end
end

-------------------------------------
-- function setNextLoadingStr
-------------------------------------
function UI_LoadingArenaNew:setNextLoadingStr()
	if (not self.m_lLoadingStrList) then
		return
	end

	local random_str = self.m_lLoadingStrList[1]
	if (random_str) then
		self.vars['loadingLabel']:setString(random_str)
		table.remove(self.m_lLoadingStrList, 1)
	end
end

-------------------------------------
-- function setLoadingGauge
-------------------------------------
function UI_LoadingArenaNew:setLoadingGauge(percent, is_not_use_label)
    local vars = self.vars

	vars['loadingGauge']:setPercentage(percent)
	if (not is_not_use_label) then
		self:setNextLoadingStr()
	end
end

-------------------------------------
-- function getLoadingGauge
-------------------------------------
function UI_LoadingArenaNew:getLoadingGauge()
	return self.vars['loadingGauge']:getPercentage()
end

-------------------------------------
-- function selectAuto
-------------------------------------
function UI_LoadingArenaNew:selectAuto(auto_mode)
    if (self.m_bSelected) then return end

    local vars = self.vars

    self.m_bSelected = true

    g_autoPlaySetting:set('auto_mode', auto_mode)

    vars['btnNode']:setVisible(false)
    vars['loadingNode']:setVisible(true)

    -- 서버 Log를 위해 임시저장
    g_arenaData.m_tempLogData['is_auto'] = auto_mode
end

--@CHECK
UI:checkCompileError(UI_LoadingArenaNew)
