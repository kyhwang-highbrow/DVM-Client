local PARENT = UI
local WAITING_TIME = 10

-------------------------------------
-- class UI_LoadingArena
-------------------------------------
UI_LoadingArena = class(PARENT,{
        m_lLoadingStrList = 'List<string>',
        m_bFriendMatch = 'boolean',

        m_remainTimer = 'number',
        m_bSelected = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingArena:init(curr_scene)
	self.m_uiName = 'UI_LoadingArena'
    self.m_bFriendMatch = curr_scene.m_bFriendMatch

    self.m_remainTimer = WAITING_TIME
    self.m_bSelected = false

	local vars = self:load('arena_loading.ui')

    local guide_type = curr_scene.m_loadingGuideType
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
function UI_LoadingArena:initUI()
    local vars = self.vars
    local is_friend_match = self.m_bFriendMatch

    do -- 플레이어 유저 덱
        local user_info = is_friend_match and g_friendMatchData.m_playerUserInfo or g_arenaData:getPlayerArenaUserInfo()
        if (user_info) then
            local t_pvp_deck = user_info.m_pvpDeck

            local player_2d_deck = UI_2DDeck(true, true)
            player_2d_deck:setDirection('left')
            vars['formationNode1']:addChild(player_2d_deck.root)
            player_2d_deck:initUI()

            local l_dragon_obj = user_info:getDeck_dragonList()
            local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
            player_2d_deck:setDragonObjectList(l_dragon_obj, leader)
        
            -- 진형 설정
            local formation = 'attack'
            if t_pvp_deck then
                formation = t_pvp_deck['formation'] or 'attack'
            end
            player_2d_deck:setFormation(formation)
        end
    end

    do -- 상대방 유저 덱
        local user_info = is_friend_match and g_friendMatchData.m_matchInfo or g_arenaData:getMatchUserInfo()
        if (user_info) then
            local t_pvp_deck = user_info.m_pvpDeck

            local player_2d_deck = UI_2DDeck(true, true)
            player_2d_deck:setDirection('right')
            vars['formationNode2']:addChild(player_2d_deck.root)
            player_2d_deck:initUI()

            local l_dragon_obj = user_info:getDeck_dragonList()
            local leader = t_pvp_deck and t_pvp_deck['leader'] or 0
            player_2d_deck:setDragonObjectList(l_dragon_obj, leader)

            -- 진형 설정
            local formation = 'attack'
            if t_pvp_deck then
                formation = t_pvp_deck['formation'] or 'attack'
            end
            player_2d_deck:setFormation(formation)
        end
    end
    
    do -- 플레이어 유저 정보
        local user_info = is_friend_match and g_friendMatchData.m_playerUserInfo or g_arenaData:getPlayerArenaUserInfo()
        if (user_info) then
            local struct_clan = user_info:getStructClan()
            local icon

            -- 티어
            icon = user_info:makeTierIcon(nil, 'small')
            if (icon) then
                vars['tierNode1']:addChild(icon)
            end

            -- 랭킹
            vars['rankLabel1']:setString(user_info:getRankText(true))

            -- 레벨, 닉네임
            vars['userLabel1']:setString(user_info:getUserText())

            -- 클랜
            local clan_name = struct_clan and struct_clan:getClanName() or ''
            vars['clanLabel1']:setString(clan_name)

            icon = struct_clan and struct_clan:makeClanMarkIcon()
            if (icon) then
                vars['markNode1']:addChild(icon)
            end

            -- 전투력
            local str = user_info:getDeckCombatPower()
            vars['powerLabel1']:setString(Str('전투력 : {1}', str))

            -- 아이콘
            icon = user_info:getDeckTamerIcon()
            if (icon) then
                vars['tamerNode1']:addChild(icon)
            end
        end
    end

    do -- 상대방 유저 정보
        local user_info = is_friend_match and g_friendMatchData.m_matchInfo or g_arenaData:getMatchUserInfo()
        if (user_info) then
            local struct_clan = user_info:getStructClan()
            local icon

            -- 티어
            icon = user_info:makeTierIcon(nil, 'small')
            if (icon) then
                vars['tierNode2']:addChild(icon)
            end

            -- 랭킹
            vars['rankLabel2']:setString(user_info:getRankText(true))

            -- 레벨, 닉네임
            vars['userLabel2']:setString(user_info:getUserText())

            -- 클랜
            local clan_name = struct_clan and struct_clan:getClanName() or ''
            vars['clanLabel2']:setString(clan_name)

            icon = struct_clan and struct_clan:makeClanMarkIcon()
            if (icon) then
                vars['markNode2']:addChild(icon)
            end

            -- 전투력
            local str = user_info:getDeckCombatPower()
            vars['powerLabel2']:setString(Str('전투력 : {1}', str))

            -- 아이콘
            icon = user_info:getDeckTamerIcon()
            if (icon) then
                vars['tamerNode2']:addChild(icon)
            end
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
function UI_LoadingArena:initButton()
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
function UI_LoadingArena:refresh()
end

-------------------------------------
-- function prepare
-------------------------------------
function UI_LoadingArena:prepare()
    return self.m_bSelected
end

-------------------------------------
-- function update
-------------------------------------
function UI_LoadingArena:update(dt)
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
function UI_LoadingArena:setNextLoadingStr()
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
function UI_LoadingArena:setLoadingGauge(percent, is_not_use_label)
    local vars = self.vars

	vars['loadingGauge']:setPercentage(percent)
	if (not is_not_use_label) then
		self:setNextLoadingStr()
	end
end

-------------------------------------
-- function getLoadingGauge
-------------------------------------
function UI_LoadingArena:getLoadingGauge()
	return self.vars['loadingGauge']:getPercentage()
end

-------------------------------------
-- function selectAuto
-------------------------------------
function UI_LoadingArena:selectAuto(auto_mode)
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
UI:checkCompileError(UI_LoadingArena)
