local PARENT = UI

-------------------------------------
-- class UI_LoadingArena
-------------------------------------
UI_LoadingArena = class(PARENT,{
        m_lLoadingStrList = 'List<string>',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_LoadingArena:init(curr_scene)
	self.m_uiName = 'UI_LoadingArena'
    
	local vars = self:load('arena_loading.ui')

    local guide_type = curr_scene.m_loadingGuideType
	if (guide_type) then
		self.m_lLoadingStrList = table.sortRandom(GetLoadingStrList())
	end
    
	self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_LoadingArena:initUI()
    local vars = self.vars

    do -- 플레이어 유저 덱
        local user_info = g_arenaData:getPlayerArenaUserInfo()
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

    do -- 상대방 유저 덱
        local user_info = g_arenaData:getMatchUserInfo()
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
    
    do -- 플레이어 유저 정보
        local user_info = g_arenaData:getPlayerArenaUserInfo()
        local struct_clan = user_info:getStructClan()

        -- 랭킹
        vars['rankLabel1']:setString(user_info:getRankText(true))

        -- 레벨, 닉네임
        vars['userLabel1']:setString(user_info:getUserText())

        -- 클랜
        local clan_name = struct_clan:getClanName()
        vars['clanLabel1']:setString(clan_name)

        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode1']:addChild(icon)
        end

        -- 전투력
        local str = user_info:getDeckCombatPower()
        vars['powerLabel1']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        local icon = user_info:getDeckTamerIcon()
        if (icon) then
            vars['tamerNode1']:addChild(icon)
        end
    end

    do -- 상대방 유저 정보
        local user_info = g_arenaData:getMatchUserInfo()
        local struct_clan = user_info:getStructClan()

        -- 랭킹
        vars['rankLabel2']:setString(user_info:getRankText(true))

        -- 레벨, 닉네임
        vars['userLabel2']:setString(user_info:getUserText())

        -- 클랜
        local clan_name = struct_clan:getClanName()
        vars['clanLabel2']:setString(clan_name)

        local icon = struct_clan:makeClanMarkIcon()
        if (icon) then
            vars['markNode2']:addChild(icon)
        end

        -- 전투력
        local str = user_info:getDeckCombatPower()
        vars['powerLabel2']:setString(Str('전투력 : {1}', str))

        -- 아이콘
        local icon = user_info:getDeckTamerIcon()
        if (icon) then
            vars['tamerNode2']:addChild(icon)
        end
    end
end

-------------------------------------
-- function initButton
-- @brief 버튼 UI 초기화
-------------------------------------
function UI_LoadingArena:initButton()
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_LoadingArena:refresh()
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

--@CHECK
UI:checkCompileError(UI_LoadingArena)
