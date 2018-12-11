local PARENT = class(UI, ITabUI:getCloneTable())

-------------------------------------
-- class UI_GrandArenaMatchList
-------------------------------------
UI_GrandArenaMatchList = class(PARENT, {
        m_bPreseason = 'boolean',
        m_selectedMatchUserUI = 'UI_GrandArenaMatchListItem',
        m_matchUserUIList = 'list[UI_GrandArenaMatchListItem]',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_GrandArenaMatchList:init(is_preseason)
    self.m_bPreseason = is_preseason
    local vars = self:load('grand_arena_match_list.ui')
    UIManager:open(self, UIManager.SCENE)

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_exitBtn() end, 'UI_GrandArenaMatchList')

    self:initUI()
    self:initButton()
    self:refresh()

    self:sceneFadeInAction()--function() self:appearDone() end)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_GrandArenaMatchList:initUI()
    local vars = self.vars

    -- 플레이어
    do
		local struct_user_info = g_grandArena:getPlayerGrandArenaUserInfo()
		if (struct_user_info) then
			-- 덱
            local deck_name = 'grand_arena_up'
			local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
            local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
			local leader = t_deck_lowdata['leader']
			local formation = t_deck_lowdata['formation']
			self:initDeckUI('left', 'up', l_dragon_obj, leader, formation)

            -- 덱
            local deck_name = 'grand_arena_down'
			local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
            local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
			local leader = t_deck_lowdata['leader']
			local formation = t_deck_lowdata['formation']
			self:initDeckUI('left', 'down', l_dragon_obj, leader, formation)

			-- 유저 정보
			self:initUserInfo('left', struct_user_info)
		end
    end


    self.m_matchUserUIList = {}
    local match_list_low_data = g_grandArena.m_matchListStructUserInfo
    for i,struct_user_info in ipairs(match_list_low_data) do
        local ui = UI_GrandArenaMatchListItem(struct_user_info)
        vars['tamerBtnItemNode' .. i]:addChild(ui.root)
        ui.vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn(ui, struct_user_info) end)
        ui.vars['tamerIconBtn']:registerScriptTapHandler(function() self:click_tamerBtn(ui, struct_user_info) end)
        table.insert(self.m_matchUserUIList, ui)
    end

    -- 매칭된 상대방 숫자 표기
    local match_list_cnt = table.count(match_list_low_data)
    vars['normalGuideLabel']:setString(Str('대전 상대 {1}명을 찾았습니다.\n상대 팀을 선택해주세요', match_list_cnt))

    -- 상대방을 선택하기 전 visible off
    vars['selectedNode']:setVisible(false)
    vars['startBtn']:setVisible(false)
    vars['selectedGuideLabel']:setVisible(false)
    vars['normalGuideLabel']:setVisible(true)
end

-------------------------------------
-- function refresh
-- @brief
-------------------------------------
function UI_GrandArenaMatchList:refresh()
    local vars = self.vars
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_GrandArenaMatchList:initButton()
    local vars = self.vars
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
end

-------------------------------------
-- function initDeckUI
-- @param direction 'left' or 'light'
-------------------------------------
function UI_GrandArenaMatchList:initDeckUI(direction, direction_v, l_dragon_obj, leader, formation)

    local vars = self.vars
    local parent_node
    if (direction == 'left') then
        if (direction_v == 'up') then
            parent_node = vars['formationNode1']
        else
            parent_node = vars['formationNode2']
        end
    elseif (direction == 'right') then
        if (direction_v == 'up') then
            parent_node = vars['formationNode3']
        else
            parent_node = vars['formationNode4']
        end
    end

    local player_2d_deck = UI_2DDeck(true, true)
    player_2d_deck:setDirection(direction)
    parent_node:removeAllChildren()
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
function UI_GrandArenaMatchList:initUserInfo(direction, struct_user_info)
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
    vars['rankLabel' .. idx]:setString(struct_user_info:getGrandArena_RankText(true))

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
    local str = struct_user_info:getDeckCombatPowerByDeckname('grand_arena_up') + struct_user_info:getDeckCombatPowerByDeckname('grand_arena_down')
    vars['powerLabel' .. idx]:setString(Str('전투력 : {1}', comma_value(str)))

    -- 아이콘
    icon = struct_user_info:getDeckTamerIcon('grand_arena_up') -- deckname
    if (icon) then
        vars['tamerNode' .. idx]:removeAllChildren()
        vars['tamerNode' .. idx]:addChild(icon)
    end
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_GrandArenaMatchList:click_tamerBtn(ui, struct_user_info)
    local vars = self.vars

    local is_first = (self.m_selectedMatchUserUI == nil)
    local old_ui = self.m_selectedMatchUserUI
    self.m_selectedMatchUserUI = ui
    
    if (is_first == true) then
        for _,_ui in pairs(self.m_matchUserUIList) do
            _ui.vars['guideVisual']:setVisible(false)
            _ui.vars['tamerInfoSprite']:setVisible(false)
        end 

        -- 상대방 선택 버튼 위치 조정
        --vars['tamerBtnMenu']:setPositionX(320)
        local position_y = vars['tamerBtnMenu']:getPositionY()
        vars['tamerBtnMenu']:stopAllActions()
        vars['tamerBtnMenu']:runAction((cc.EaseInOut:create(cc.MoveTo:create(0.3, cc.p(320, position_y)), 2)))

        -- 선택 상태에 따른 visible 정리
        vars['startBtn']:setVisible(true)
        vars['selectedNode']:setVisible(true)
        vars['selectedGuideLabel']:setVisible(true)
        vars['normalGuideLabel']:setVisible(false)
    end

    if old_ui then
        old_ui.vars['selectedSprite']:setVisible(false)
    end

    if ui then
        ui.vars['selectedSprite']:setVisible(true)
    end


    vars['selectedNode']:setVisible(true)
	if (struct_user_info) then
		-- 덱
        local deck_name = 'grand_arena_up'
		local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
        local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
		local leader = t_deck_lowdata['leader']
		local formation = t_deck_lowdata['formation']
		self:initDeckUI('right', 'up', l_dragon_obj, leader, formation)

        -- 덱
        local deck_name = 'grand_arena_down'
		local l_dragon_obj = struct_user_info:getDeck_dragonObjList(deck_name)
        local t_deck_lowdata = struct_user_info:getDeckLowData(deck_name)
		local leader = t_deck_lowdata['leader']
		local formation = t_deck_lowdata['formation']
		self:initDeckUI('right', 'down', l_dragon_obj, leader, formation)

		-- 유저 정보
		self:initUserInfo('right', struct_user_info)
	end
end

-------------------------------------
-- function click_startBtn
-- @brief 전투 준비 버튼
-------------------------------------
function UI_GrandArenaMatchList:click_startBtn()
    if (not self.m_selectedMatchUserUI) then
        return
    end

    if (not self.m_selectedMatchUserUI.m_structUserInfo) then
        return
    end
    
    
    local struct_user_info = self.m_selectedMatchUserUI.m_structUserInfo
    g_grandArena:setMatchUserInfo(struct_user_info)


    local function finish_cb(game_key, develop_mode)
        -- 매칭 상대 데이터 설정
        -- 시작이 두번 되지 않도록 하기 위함
        UI_BlockPopup()

        local scene = SceneGameEventArena(game_key, ARENA_STAGE_ID, 'stage_colosseum', develop_mode, false) -- game_key, stage_id, stage_name, develop_mode, friend_match
        scene:runScene()
    end

    -- 연습전
    if (self.m_bPreseason) then
        local game_key = nil
        local develop_mode = true
        finish_cb(game_key, develop_mode)
        return
    end

    local vs_uid = struct_user_info:getUid()
    local combat_power = struct_user_info:getDeckCombatPowerByDeckname('grand_arena_up') + struct_user_info:getDeckCombatPowerByDeckname('grand_arena_down')
    g_grandArena:requestGameStart(vs_uid, combat_power, finish_cb, nil) -- vs_uid, finish_cb, fail_cb)
end

-------------------------------------
-- function click_exitBtn
-- @brief
-------------------------------------
function UI_GrandArenaMatchList:click_exitBtn()
    -- 그랜드 콜로세움 매치리스트 UI에서는 뒤로가기를 할 수 없음
end