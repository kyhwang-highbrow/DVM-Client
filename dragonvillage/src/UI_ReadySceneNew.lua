local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable(), UI_FevertimeUIHelper:getCloneTable()) 

-------------------------------------
-- class UI_ReadySceneNew
-------------------------------------
UI_ReadySceneNew = class(PARENT,{
        m_stageID = 'number',
        m_subInfo = 'string',
        m_stageAttr = 'attr',

        -- UI_ReadyScene_Select 관련 변수
        m_readySceneSelect = 'UI_ReadySceneNew_Select',

        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadySceneNew_Deck',

        -- 정렬 도우미
		m_sortManagerDragon = '',
        m_sortManagerFriendDragon = '',
        m_uicSortList = 'UIC_SortList',

        m_bWithFriend = 'boolean',
        m_bUseCash = 'boolean',
        m_gameMode = 'number',
        m_bArena = 'boolean',

        -- 멀티덱 사용하는 경우 (클랜 던전, 고대 유적 던전)
        m_multiDeckMgr = 'MultiDeckMgr',
        m_numOfFevertimePopupOpened = 'number', -- 핫타임 팝업이 열린 횟수

        m_dontSaveOnExit = 'boolean',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew:init(stage_id, sub_info)
    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()
    self.m_gameMode = g_stageData:getGameMode(stage_id)
    self.m_subInfo = sub_info
    self.m_numOfFevertimePopupOpened = 0
	
    if (not stage_id) then
		stage_id = COLOSSEUM_STAGE_ID
	end
    self:init_MemberVariable(stage_id)

    -- 모험모드에서만 친구사용
    self.m_bWithFriend = (self.m_gameMode == GAME_MODE_ADVENTURE) and true or false
    self.m_bUseCash = false

    -- 아레나모드 (콜로세움 진입, 친구대전 진입시)
    self.m_bArena = false
    --if (stage_id == ARENA_STAGE_ID or stage_id == FRIEND_MATCH_STAGE_ID) then
    if isExistValue(stage_id, ARENA_NEW_STAGE_ID, ARENA_STAGE_ID, FRIEND_MATCH_STAGE_ID, CHALLENGE_MODE_STAGE_ID, GRAND_ARENA_STAGE_ID, CLAN_WAR_STAGE_ID) then
        self.m_bArena = true
    end

    local vars = self:load('battle_ready_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 레디씬 진입시 선택된 친구정보 초기화
    g_friendData:delSettedFriendDragon()

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_ReadySceneNew')

    self:initMultiDeckMode()
	self:checkDeckProper()
	self:initUI()
    self:initButton()
	
    self.m_readySceneSelect = UI_ReadySceneNew_Select(self)
    self.m_readySceneSelect:setFriend(self.m_bWithFriend)

    self:initDeck()

    self:refresh()

	self:init_sortMgr()

    -- 자동 전투 off
    if (stage_id == ARENA_STAGE_ID) then
        g_autoPlaySetting:setMode(AUTO_COLOSSEUM)
        
    elseif (stage_id == CLAN_WAR_STAGE_ID) then
        g_autoPlaySetting:setMode(AUTO_CLAN_WAR)

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (stage_id == GRAND_ARENA_STAGE_ID) then
        g_autoPlaySetting:setMode(AUTO_GRAND_ARENA)

    else        
        if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
            g_autoPlaySetting:setMode(AUTO_ANCIENT_TOWER)
        elseif (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            g_autoPlaySetting:setMode(AUTO_LEAGUE_RAID)
        elseif (self.m_gameMode == GAME_MODE_CHALLENGE_MODE) then
            g_autoPlaySetting:setMode(AUTO_CHALLENGE_MODE)
        else
            g_autoPlaySetting:setMode(AUTO_NORMAL)
        end
    end

    g_autoPlaySetting:setAutoPlay(false)

    -- 매일매일 다이아 풀팝업
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        g_fullPopupManager:show(FULL_POPUP_TYPE.AUTO_PICK)
    end

    -- 프리셋 버튼
    local curr_deck_name = g_deckData:getSelectedDeckName()
    local is_available_preset = g_deckPresetData:isAvailablePreset(curr_deck_name)
    vars['presetBtn']:setVisible(is_available_preset)

    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        vars['presetBtn']:setVisible(false)
        vars['preset2Btn']:setVisible(true)
        vars['cpNode1']:setPositionY(vars['cpNode2']:getPositionY())
    end

    -- @ TUTORIAL : 1-1 end , 104
	local tutorial_key = TUTORIAL.FIRST_END
	local check_step = 104
	TutorialManager.getInstance():continueTutorial(tutorial_key, check_step, self)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ReadySceneNew:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ReadySceneNew'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)

    if (self:isClanRaidTrainingMode(self.m_stageID)) then
        --self.m_staminaType = 'cldg_tr'
        self.m_staminaType = 'st'
        
    -- 죄악의 화신 토벌작전 이벤트의 경우 소모 재화가 없으므로 기본 값인 날개를 표시
    elseif (self:isClanRaidEventIncarnationOfSinsMode(self.m_stageID)) then
        self.m_staminaType = 'st'
    end

	-- 들어온 경로에 따라 sound가 다름
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_uiBgm = 'bgm_dungeon_ready'
	else
		self.m_uiBgm = 'bgm_lobby'
	end

end

-------------------------------------
-- function initDeck
-------------------------------------
function UI_ReadySceneNew:initDeck()
    local vars = self.vars
	self.m_readySceneDeck = UI_ReadySceneNew_Deck(self)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
        self:refresh_slotLight()
	end)
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_ReadySceneNew:init_MemberVariable(stage_id)
    self.m_stageID = stage_id

	if (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then
        -- 인연 던전의 경우라면 해당 드래곤의 속성을 스테이지 속성으로 설정
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        if (t_dungeon_info) then
            local did = t_dungeon_info['dragon']
            
            self.m_stageAttr = TableDragon():getValue(did, 'attr')
        end
    else
	    self.m_stageAttr = TableStageData():getValue(stage_id, 'attr')
    end
end

-------------------------------------
-- function checkDeckProper
-- @brief 해당 모드에 맞는 덱인지 체크하고 아니라면 바꿔준다.
-------------------------------------
function UI_ReadySceneNew:checkDeckProper()

    -- 콜로세움 별도 처리
    if (self.m_stageID == COLOSSEUM_STAGE_ID) then
        if (self.m_subInfo == 'atk') then
            g_deckData:setSelectedDeck('pvp_atk')
        elseif (self.m_subInfo == 'def') then
            g_deckData:setSelectedDeck('pvp_def')
        end
        return
    end

    -- 친선대전 별도 처리
    if (self.m_stageID == FRIEND_MATCH_STAGE_ID) then
        if (self.m_subInfo == 'fatk') then
            g_deckData:setSelectedDeck('fpvp_atk')
        end
        return
    end

    -- 콜로세움 (신규) 별도 처리
    if (self.m_stageID == ARENA_STAGE_ID) then
        g_deckData:setSelectedDeck('arena')
        return
    end

    -- 아레나 (개편 후) 별도 처리
    if (self.m_stageID == ARENA_NEW_STAGE_ID and self.m_subInfo) then
        g_deckData:setSelectedDeck(self.m_subInfo)
        return
    end

    -- 챌린지 모드 별도 처리
    if (self.m_stageID == CHALLENGE_MODE_STAGE_ID) then
        g_deckData:setSelectedDeck(DECK_CHALLENGE_MODE)
        return
    end

    -- 클랜전
    if (self.m_stageID == CLAN_WAR_STAGE_ID) then
        g_deckData:setSelectedDeck('clanwar')
        return
    end

    -- 레이드
    if (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
        g_deckData:setSelectedDeck(self.m_subInfo)
        return
    end

    -- 멀티덱 예외처리 (클랜 던전, 고대 유적 던전)
    local multi_deck_mgr = self.m_multiDeckMgr 
    if (multi_deck_mgr) then
        local deck_name = self.m_multiDeckMgr:getDeckName()
        if (deck_name) then
            g_deckData:setSelectedDeck(deck_name)
            return
        end
    end

    local curr_mode = TableDrop():getValue(self.m_stageID, 'mode')

    
    -- 차원문
    if (g_dmgateData:isStageDimensionGate(self.m_stageID)) then
        local dmgate_stage_id = g_dmgateData:getStageID(self.m_stageID)
        g_deckData:setSelectedDeck(curr_mode .. '_' .. tostring(dmgate_stage_id))
        return 
    end

    -- 시험의 탑인 경우 고대의 탑과 STAGE ID 같이 쓰이므로 덱네임 다시 받아옴
    if (curr_mode == 'ancient') then
        local deck_name = g_attrTowerData:getDeckName()
        if (deck_name) then
            g_deckData:setSelectedDeck(deck_name)
            return
        end
    end

	local curr_deck_name = g_deckData:getSelectedDeckName()
	if not (curr_mode == curr_deck_name) then
		g_deckData:setSelectedDeck(curr_mode)
	end
end

-------------------------------------
-- function condition_deck_idx
-- @breif 덱에 설정된 드래곤을 정렬 우선순위로 사용
-------------------------------------
function UI_ReadySceneNew:condition_deck_idx(a, b)
    local a_deck_idx = self.m_readySceneDeck.m_tDeckMap[a['data']['id']] or nil
    local b_deck_idx = self.m_readySceneDeck.m_tDeckMap[b['data']['id']] or nil
	 
    -- 둘 다 덱에 설정된 경우 우열을 가리지 않음
    if (a_deck_idx and b_deck_idx) then
        return nil

    -- A드래곤만 덱에 설정된 경우
    elseif a_deck_idx then
        return true

    -- B드래곤만 덱에 설정된 경우
    elseif b_deck_idx then
        return false

    -- 둘 다 덱에 설정되지 않은 경우
    else
        return nil
    end
end

-------------------------------------
-- function condition_cool_time
-------------------------------------
function UI_ReadySceneNew:condition_cool_time(a,b)
    -- 둘다 사용가능한 드래곤이라면 다음 정렬로 (최종시간은 계속 저장되기 때문에 시간만으로 비교하면 안됨)
    local a_enable = g_friendData:checkUseEnableDragon(a['data']['id'])
    local b_enable = g_friendData:checkUseEnableDragon(b['data']['id'])

    local a_value = g_friendData:getDragonCoolTimeFromDoid(a['data']['id']) or 0
    local b_value = g_friendData:getDragonCoolTimeFromDoid(b['data']['id']) or 0

    a_value = a_enable and 0 or a_value
    b_value = b_enable and 0 or b_value

    if (a_value == b_value) then
        return nil
    end
    
    return a_value < b_value
end

-------------------------------------
-- function condition_cool_time
-------------------------------------
function UI_ReadySceneNew:condition_cool_time(a,b)
    local a_enable = g_friendData:checkUseEnableDragon(a['data']['id'])
    local b_enable = g_friendData:checkUseEnableDragon(b['data']['id'])

    local a_value = g_friendData:getDragonCoolTimeFromDoid(a['data']['id']) or 0
    local b_value = g_friendData:getDragonCoolTimeFromDoid(b['data']['id']) or 0

    a_value = a_enable and 0 or a_value
    b_value = b_enable and 0 or b_value

    if (a_value == b_value) then
        return nil
    end
    
    return a_value < b_value
end


-------------------------------------
-- function condition_raid_deck
-------------------------------------
function UI_ReadySceneNew:condition_raid_deck(a,b)
    local using_dragons = g_leagueRaidData:getUsingDidTable()

    local a_deck_index = g_leagueRaidData:getDeckIndex(a['data']['id'])
    local b_deck_index = g_leagueRaidData:getDeckIndex(a['data']['id'])

    return a_deck_index < b_deck_index
end


-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_ReadySceneNew:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()
    self.m_sortManagerFriendDragon = SortManager_Dragon()
    
    -- 멀티덱 사용시 우선순위 추가
    if (self.m_multiDeckMgr) then
        local function cond(a, b)
            return self.m_multiDeckMgr:sort_multi_deck(a, b)
		end

        local function cond_raid(a, b)
            return self.m_multiDeckMgr:sort_multi_deck_raid(a, b)
        end

        if (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            self.m_sortManagerDragon:addPreSortType('multi_deck', false, cond_raid)
        else
            self.m_sortManagerDragon:addPreSortType('multi_deck', false, cond)
        end
    end

    do
        local function cond(a, b) return self:condition_deck_idx(a, b) end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
        self.m_sortManagerFriendDragon:addPreSortType('deck_idx', false, cond)
    end

    -- 친구 드래곤인 경우 쿨타임 정렬 추가
    local function cond(a, b)
		return self:condition_cool_time(a, b)
	end
    self.m_sortManagerFriendDragon:addPreSortType('used_time', false, cond)

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    
	-- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self.m_sortManagerFriendDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
        self.m_sortManagerDragon:setAllAscending(ascending)
        self.m_sortManagerFriendDragon:setAllAscending(ascending)
        self:apply_dragonSort()
        self:save_dragonSortInfo()

        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end)

    -- 세이브데이터에 있는 정렬 값을 적용
    self:apply_dragonSort_saveData()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ReadySceneNew:apply_dragonSort()
    local sort_func 
    sort_func = function(table_view, friend)
        if (table_view == nil) then return end
        local target_sort_mgr = (friend) and self.m_sortManagerFriendDragon or self.m_sortManagerDragon
        target_sort_mgr:sortExecution(table_view.m_itemList)
        table_view:setDirtyItemList()
    end
    
    sort_func(self.m_readySceneSelect.m_tableViewExtMine)

    if (self.m_bWithFriend) then
        sort_func(self.m_readySceneSelect.m_tableViewExtFriend, true)
    end
end

-------------------------------------
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_ReadySceneNew:save_dragonSortInfo()
    g_settingData:lockSaveData()

    -- 정렬 순서 저장
    local sort_order = self.m_sortManagerDragon.m_lSortOrder
    g_settingData:applySettingData(sort_order, 'dragon_sort_fight', 'order')

    -- 오름차순, 내림차순 저장
    local ascending = self.m_sortManagerDragon.m_defaultSortAscending
    g_settingData:applySettingData(ascending, 'dragon_sort_fight', 'ascending')

    g_settingData:unlockSaveData()
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_ReadySceneNew:apply_dragonSort_saveData()
    local l_order = g_settingData:get('dragon_sort_fight', 'order')
    local ascending = g_settingData:get('dragon_sort_fight', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_sortManagerDragon:pushSortOrder(sort_type)
    end
    self.m_sortManagerDragon:setAllAscending(ascending)
    self.m_uicSortList:setSelectSortType(sort_type)

    do -- 오름차순, 내림차순 아이콘
        local vars = self.vars
        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end
end

-------------------------------------
-- function initMultiDeckMode
-- @brief 멀티 덱 모드
-------------------------------------
function UI_ReadySceneNew:initMultiDeckMode()
    local make_deck = true

    -- @ 클랜 던전
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local attr = TableStageData:getStageAttr(self.m_stageID) 
        self.m_multiDeckMgr = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, make_deck, attr)

    -- @ 고대 유적 던전
    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        self.m_multiDeckMgr = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN, make_deck)

    -- @ 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
        self.m_multiDeckMgr = MultiDeckMgr(MULTI_DECK_MODE.EVENT_ARENA, make_deck)

    -- @ 레이드
    elseif (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
        self.m_multiDeckMgr = MultiDeckMgr(MULTI_DECK_MODE.LEAGUE_RAID, make_deck)

    end
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew:initUI()
    local vars = self.vars

    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end

    -- 배경
    local attr = TableStageData:getStageAttr(self.m_stageID)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

    -- 연속전투 불가능할때 UI 처리
    local set_autobtn_off = function()
        vars['autoStartOnBtn']:setVisible(false)
        vars['manageBtn']:setPositionX(80)
        vars['teamBonusBtn']:setPositionX(-80)
    end

    if isExistValue(self.m_gameMode, GAME_MODE_DIMENSION_GATE, GAME_MODE_LEAGUE_RAID) then
        set_autobtn_off()
    end

	-- 콜로세움 예외처리
	--if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID or self.m_stageID == ARENA_STAGE_ID) then
    if isExistValue(self.m_stageID, COLOSSEUM_STAGE_ID, FRIEND_MATCH_STAGE_ID, ARENA_NEW_STAGE_ID, ARENA_STAGE_ID, CHALLENGE_MODE_STAGE_ID) then
        vars['cpNode2']:setVisible(false)
        
		-- 배경 아무거나 넣어준다
		vars['bgNode']:removeAllChildren()
		local animator = ResHelper:getUIDragonBG('fire', 'idle')
        vars['bgNode']:addChild(animator.m_node)

        -- 테스트 모드일때 연속 전투 가능하게
        if (IS_ARENA_AUTOPLAY() and self.m_stageID == ARENA_STAGE_ID) then
        else
            set_autobtn_off()
        end
	end

    if (self.m_stageID == CLAN_WAR_STAGE_ID) then
        vars['clanWarBgMenu']:setVisible(true)
        set_autobtn_off()
    end
    
    -- 멀티덱 예외처리 (클랜 던전, 고대 유적 던전)
    local multi_deck_mgr = self.m_multiDeckMgr

    if (multi_deck_mgr and self.m_gameMode ~= GAME_MODE_LEAGUE_RAID) then
        vars['clanRaidMenu']:setVisible(true)
        vars['cpNode2']:setVisible(false)
        vars['formationNode']:setPositionX(-230)

        -- 클던만 연속전투 막음
        if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
            set_autobtn_off()

            -- 보스 정보 추가
            local struct_raid = g_clanRaidData:getClanRaidStruct()
            if (not struct_raid) then
                return
            end
            --[[
            vars['bossInfoMenu']:setVisible(true)

            local is_rich_label = true
            local name = struct_raid:getBossNameWithLv(is_rich_label)
            vars['bossNameLabel']:setString(name)

            local rate = struct_raid:getHpRate()
            vars['bossHpLabel']:setString(string.format('%0.2f%%', rate))

            local stage_id = struct_raid:getStageID()
            local _, boss_mid = g_stageData:isBossStage(stage_id)
            local l_monster = g_stageData:getMonsterIDList(stage_id)

            local ui = UI_MonsterCustomCard(l_monster[#l_monster])
            ui.vars['clickBtn']:setEnabled(false)
            vars['bossNode']:addChild(ui.root)
            --]]
            vars['synastryTipsMenu']:setVisible(true)
            vars['synastryInfoBtn']:registerScriptTapHandler(function() UI_HelpClan('clan_dungeon','clan_dungeon_summary', 'cldg_attr_bonus') end)
            vars['attrInfoSprite']:setVisible(false)
            -- 보너스 속성
            do
                local str, map_attr = struct_raid:getBonusSynastryInfo()
                vars['bonusTipsDscLabel']:setString(str)

                for k, v in pairs(map_attr) do
                    -- 속성 아이콘
                    local icon = IconHelper:getAttributeIconButton(k)
                    local target_node = vars['bonusTipsNode']
                    target_node:addChild(icon)
                end
            end

            -- 페널티 속성
            do
                local str, map_attr = struct_raid:getPenaltySynastryInfo()
                vars['panaltyTipsDscLabel']:setString(str)

                local cnt = table.count(map_attr)
                local idx = 0

                for k, v in pairs(map_attr) do
                    idx = idx + 1
                    -- 속성 아이콘
                    local icon = IconHelper:getAttributeIconButton(k)
                    local target_node = (cnt == 1) and 
                                        vars['panaltyTipsNode'] or 
                                        vars['panaltyTipsNode'..idx]
                    target_node:addChild(icon)
                end
            end
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadySceneNew:initButton()
    local vars = self.vars
	
	-- 드래곤 관리
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)

    -- 팀 보너스
    vars['teamBonusBtn']:registerScriptTapHandler(function() self:click_teamBonusBtn() end)

	-- 추천 배치, 모두 해제
    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)

    -- 프리셋
    vars['presetBtn']:registerScriptTapHandler(function() self:click_presetBtn() end)
    vars['preset2Btn']:registerScriptTapHandler(function() self:click_presetBtn() end)

    vars['runeBtn']:registerScriptTapHandler(function() self:click_runeBtn() end)

	-- 전투 시작
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
	vars['startBtn']:setClickSoundName('ui_game_start')

	-- 연속 전투
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:setManualMode(true)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)

	-- 테이머 변경
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['tamerBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

	-- 리더 변경
	vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

	-- 진형 관리
    vars['fomationBtn']:registerScriptTapHandler(function() self:click_fomationBtn() end)

    -- 골드 부스터
    vars['goldBoosterBtn']:registerScriptTapHandler(function() self:click_goldBoosterBtn() end)

    -- 경험치 부스터 
    vars['expBoosterBtn']:registerScriptTapHandler(function() self:click_expBoosterBtn() end)

    -- 일일 핫타임
    vars['fevertimeBtn']:registerScriptTapHandler(function() self:openFevertimePopup() end)

    -- 속성 도움말
    vars['attrInfoBtn']:registerScriptTapHandler(function() self:click_attrInfoBtn() end)
    if (g_clanRaidData:isClanRaidStageID(self.m_stageID)) then
        vars['attrInfoBtn']:setVisible(false)
    end

    -- 콜로세움일 경우
    if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID or self.m_stageID == CLAN_WAR_STAGE_ID ) then
        vars['actingPowerNode']:setVisible(false)
        vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
        vars['startBtnLabel']:setPositionX(0)
        vars['startBtnLabel']:setString(Str('변경 완료'))
    end

    -- 차원문
    if (g_dmgateData:isStageDimensionGate(self.m_stageID)) then
        vars['startBtnLabel']:setPositionX(0)
        vars['actingPowerNode']:setVisible(false)
    end

    -- 클랜던전 연습 모드
    if (self:isClanRaidTrainingMode(self.m_stageID)) then
        vars['startBtnLabel']:setPositionX(0)
        vars['actingPowerNode']:setVisible(false)
        --[[
        vars['startBtn']:setVisible(false)
        vars['trainingBtn']:setVisible(true)
        vars['trainingBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
        vars['trainingBtn']:setClickSoundName('ui_game_start')
        vars['trainingLabel']:setString(Str('{1}/{2}', g_clanRaidData.m_triningTicketCnt, g_clanRaidData.m_triningTicketMaxCnt))
        vars['trainingSetBtn']:setVisible(true)
        vars['trainingSetBtn']:registerScriptTapHandler(function() self:click_showTrainingBtn() end)]]
    end

    -- 클랜던전 죄악의 화신 토벌작전 이벤트 모드
    if (self:isClanRaidEventIncarnationOfSinsMode(self.m_stageID)) then
        vars['startBtn']:setVisible(false)
        vars['startRequireNoPowerBtn']:setVisible(true)
        vars['startRequireNoPowerBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
        vars['startRequireNoPowerBtn']:setClickSoundName('ui_game_start')
        vars['incarnationOfSinsSetBtn']:setVisible(true)
        vars['incarnationOfSinsSetBtn']:registerScriptTapHandler(function() self:click_incarnationOfSinsSetBtn() end)
    end
    
    -- 고대의 탑
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        if (not g_ancientTowerData:isAttrChallengeMode()) then
            vars['towerMenu']:setVisible(true)
            local best_score = g_settingDeckData:getAncientStageScore(self.m_stageID)
            vars['towerScoreLabel']:setString(Str('{1}층 팀 최고점수 : {2}', g_ancientTowerData:getFloorFromStageID(self.m_stageID), comma_value(best_score)))
            vars['loadLabel']:setString(Str('{1}층 베스트 팀 불러오기', g_ancientTowerData:getFloorFromStageID(self.m_stageID)))
            vars['loadBtn']:registerScriptTapHandler(function() self:click_loadBestTeam() end)
            vars['saveBtn']:registerScriptTapHandler(function() self:click_saveBestTeam() end)
        end
    end

    do -- 핫타임 팝업 버튼
        vars['fevertimeBtn']:setVisible(false) -- 기본값
        vars['fevertimeNotiSprite']:setVisible(false) -- 기본값

        -- 핫타임 팝업 노출 조건 체크
        local ret, usable_fevertime_count = self:checkFevertimePopupCondition()
        if (self:checkFevertimePopupCondition() == true) then
            vars['fevertimeBtn']:setVisible(true)

            if (1 <= usable_fevertime_count) then
                vars['fevertimeNotiSprite']:setVisible(true)
            end
        end
    end

end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadySceneNew:refresh()
    local stage_id = self.m_stageID
    local vars = self.vars

    do -- 스테이지 이름
        local str = g_stageData:getStageName(stage_id)
        if (stage_id == COLOSSEUM_STAGE_ID) then
            if (self.m_subInfo == 'atk') then
                str = Str('콜로세움 공격')
            elseif (self.m_subInfo == 'def') then
                str = Str('콜로세움 방어')
            else
                str = Str('콜로세움 준비')
            end

        elseif (stage_id == ARENA_STAGE_ID) then
            str = Str('콜로세움')

        elseif (stage_id == ARENA_NEW_STAGE_ID) then
            str = Str('콜로세움')

	    elseif (stage_id == FRIEND_MATCH_STAGE_ID) then
            str = Str('친선전 공격')

        elseif (stage_id == CHALLENGE_MODE_STAGE_ID) then
            str = Str('그림자의 신전')
        -- 클랜던전 연습모드의 경우
        elseif (self:isClanRaidTrainingMode(stage_id)) then         
            str = Str('클랜 던전 연습 전투')

		-- 클랜전
        elseif (stage_id == CLAN_WAR_STAGE_ID) then         
            str = Str('클랜전')

        -- 레이드
        elseif (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            local deck_name = g_deckData:getSelectedDeckName()
            local deck_no = pl.stringx.replace(deck_name, 'league_raid_', '')
            str = Str('레이드').. ' ' .. Str(tostring(deck_no) .. ' 공격대')
        end
        self.m_titleStr = str
        g_topUserInfo:setTitleString(str)
    end

    do -- 필요 활동력 표시
        if (stage_id == DEV_STAGE_ID) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local stamina_type, stamina_value = TableDrop:getStageStaminaType(self.m_stageID)
            vars['actingPowerLabel']:setString(stamina_value)
        end
    end

    -- 모험 소비 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        local active, value = g_hotTimeData:getActiveHotTimeInfo_stamina()
        if active then
            local stamina_type, stamina_value = TableDrop:getStageStaminaType(self.m_stageID)
            local cost_value = math_floor(stamina_value * (1 - value / 100))
            local str = string.format('-%d%%', value)
            vars['actingPowerLabel']:setString(cost_value)
            vars['actingPowerLabel']:setTextColor(cc.c4b(0, 255, 255, 255))
            vars['hotTimeSprite']:setVisible(true)
            vars['hotTimeStLabel']:setString(str)
            vars['staminaNode']:setVisible(false)
        else
            vars['actingPowerLabel']:setTextColor(cc.c4b(255, 255, 255, 255))
            vars['hotTimeSprite']:setVisible(false)
            vars['staminaNode']:setVisible(true)
        end

        g_hotTimeData:refresh_boosterMailInfo()

        vars['itemMenu']:setVisible(true)
        vars['itemMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update_item(dt) end, 0.1)
    end

    -- 고대 유적 던전 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        local type = 'dg_ar_st_dc'
        self:initStaminaFevertimeUI(vars, stage_id, type)
    end

    -- 룬 수호자 던전 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_RUNE_GUARDIAN) then
        local type = 'dg_rg_st_dc'
        self:initStaminaFevertimeUI(vars, stage_id, type)
    end

    -- 악몽 던전 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_NIGHTMARE) then
            local type = 'dg_nm_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end

    -- 거목 던전 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_TREE) then
            local type = 'dg_gt_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end

    -- 거대용 던전 활동력 핫타임 관련
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(stage_id)
        local dungeonMode = t_dungeon['dungeon_mode']
        if (dungeonMode == NEST_DUNGEON_EVO_STONE) then
            local type = 'dg_gd_st_dc'
            self:initStaminaFevertimeUI(vars, stage_id, type)
        end
    end

    -- 황금 던전 (골드라고라 던전)
    if (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
        vars['itemMenu']:setVisible(true)
        vars['itemMenu']:scheduleUpdateWithPriorityLua(function(dt) self:update_item(dt) end, 0.1)

        -- 자동 줍기 버튼만 활성화하고 나머지는 숨김
        vars['expBoosterBtn']:setVisible(false)
        vars['goldBoosterBtn']:setVisible(false)
    end

    self:refresh_tamer()
	self:refresh_buffInfo()
    self:refresh_combatPower()
end

-------------------------------------
-- function refresh_combatPower
-------------------------------------
function UI_ReadySceneNew:refresh_combatPower()
    local vars = self.vars

    local stage_id = self.m_stageID
    local game_mode = self.m_gameMode

	if (stage_id == COLOSSEUM_STAGE_ID or stage_id == FRIEND_MATCH_STAGE_ID or game_mode == GAME_MODE_CLAN_RAID or stage_id == ARENA_NEW_STAGE_ID or stage_id == ARENA_STAGE_ID or stage_id == CLAN_WAR_STAGE_ID) then
		vars['cp_Label']:setString('')
        vars['cp_Label2']:setString('')

        local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

    elseif isExistValue(game_mode, GAME_MODE_EVENT_ARENA) then
        vars['cp_Label']:setString('')
        vars['cp_Label2']:setString('')

        local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

	else
		local recommend = TableStageData():getRecommendedCombatPower(stage_id, game_mode)
        vars['cp_Label2']:setString(comma_value( math.floor(recommend + 0.5) ))

		local deck = self.m_readySceneDeck:getDeckCombatPower()

        -- 테이머
        do
            local tamer_id = self:getCurrTamerID()
            local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
            local table = g_constant:get('UI', 'TAMER_SKILL_COMBAT_POWER')
            
            for i = 1, 3 do
                local lv = t_tamer_data['skill_lv' .. i]
                if (lv and lv > 0) then
                    deck = deck + table[i] * (lv - 1)
                end
            end
        end

		vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))

	end
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_ReadySceneNew:refresh_tamer()
    local vars = self.vars

    vars['tamerNode']:removeAllChildren()

    local table_tamer = TableTamer()
    local tamer_id = self:getCurrTamerID()
	local tamer_res = table_tamer:getValue(tamer_id, 'res_sd')

    -- 코스튬 적용
    local t_costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
    if (t_costume_data) then
        tamer_res = t_costume_data:getResSD()
    end

    local animator = MakeAnimator(tamer_res)
	if (animator) then
		animator:setDockPoint(0.5, 0.5)
		animator:setAnchorPoint(0.5, 0.5)
		vars['tamerNode']:addChild(animator.m_node)
	end
end

-------------------------------------
-- function refresh_buffInfo
-------------------------------------
function UI_ReadySceneNew:refresh_buffInfo()
    local vars = self.vars
	
	if (not self.m_readySceneDeck) then
		return
	end

    -- 테이머 버프
    self:refresh_buffInfo_TamerBuff()

	-- 리더 버프
	do
        local leader_buff_str = self:getLeaderBuffDesc()
        if (leader_buff_str) then
            vars['leaderBuffLabel']:setString(leader_buff_str)
        else
            vars['leaderBuffLabel']:setString(Str('리더 버프 없음'))
        end
	end

	-- 진형 버프
    -- 콜로세움 (신규) - 버프 없어서 이름 표시
	if (self.m_bArena) then
        local l_formation = g_formationArenaData:getFormationInfoList()
		local curr_formation = self.m_readySceneDeck.m_currFormation
		local formation_data = l_formation[curr_formation]  
        local formation_name = TableFormationArena():getFormationName(formation_data['formation'])
        vars['fomationLabel']:setString(Str('진형 변경'))
        vars['formationBuffLabel']:setString(formation_name)

    else
		local l_formation = g_formationData:getFormationInfoList()
		local curr_formation = self.m_readySceneDeck.m_currFormation
		local formation_data = l_formation[curr_formation]        
		local formation_buff = TableFormation():getFormatioDesc(formation_data['formation'])

		vars['formationBuffLabel']:setString(formation_buff)
	end
end

-------------------------------------
-- function refresh_slotLight
-------------------------------------
function UI_ReadySceneNew:refresh_slotLight()
    local vars = self.vars
    local multi_deck_mgr = self.m_multiDeckMgr
    if (multi_deck_mgr) then
        local up_deck_cnt = multi_deck_mgr:getDeckDragonCnt('up')
        for idx = 1, 5 do
            local slot_light = vars['slotSprite'..idx]
            slot_light:setVisible(idx <= up_deck_cnt)
        end

        local down_deck_cnt = multi_deck_mgr:getDeckDragonCnt('down')
        for idx = 1, 5 do
            local slot_light = vars['slotSprite'..(idx + 5)]
            slot_light:setVisible(idx <= down_deck_cnt)
        end
    end
end


-------------------------------------
-- function getLeaderBuffDesc
-------------------------------------
function UI_ReadySceneNew:getLeaderBuffDesc()
    self.m_readySceneDeck:refreshLeader()
	
	local leader_buff		
	local leader_idx = self.m_readySceneDeck.m_currLeader
	local l_doid = self.m_readySceneDeck.m_lDeckList
	local leader_doid = l_doid[leader_idx]
    if (not leader_doid) then
        return nil
    end
    local t_dragon_data = g_dragonsData:getDragonDataFromUid(leader_doid)
    if (not t_dragon_data) then
        return nil
    end
	local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
	local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')
        
    if (not skill_info) then
        return nil
    end

	leader_buff = skill_info:getSkillDesc()
	return leader_buff	    
end
-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_ReadySceneNew:refresh_buffInfo_TamerBuff()
    local vars = self.vars

    -- 테이머 버프
    local tamer_id = self:getCurrTamerID()
	local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(2)	-- 2번이 패시브
	local tamer_buff = skill_info:getSkillDesc()

	vars['tamerBuffLabel']:setString(tamer_buff)
end

-------------------------------------
-- function update_item
-- @brief
-------------------------------------
function UI_ReadySceneNew:update_item(dt)    
    local vars = self.vars

    -- 경험치 부스터
    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_exp2x')
        local is_used = state == BOOSTER_ITEM_STATE.INUSE
        vars['expBoosterVisual']:setVisible(is_used)
        vars['expBoosterLabel']:setString(str)

        local btn = vars['expBoosterBtn']
        btn:setEnabled(not is_used)

        if (state == BOOSTER_ITEM_STATE.AVAILABLE) and (btn.m_bAutoShakeAction == false) then
            btn:setAutoShake(true)

        elseif (state ~= BOOSTER_ITEM_STATE.AVAILABLE) then
            btn:setAutoShake(false)
        end

    end

    -- 골드 부스터
    do
        local str, state = g_hotTimeData:getHotTimeBuffText('buff_gold2x')
        local is_used = state == BOOSTER_ITEM_STATE.INUSE
        vars['goldBoosterVisual']:setVisible(is_used)
        vars['goldBoosterLabel']:setString(str)

        local btn = vars['goldBoosterBtn']
        btn:setEnabled(not is_used)

        if (state == BOOSTER_ITEM_STATE.AVAILABLE) and (btn.m_bAutoShakeAction == false) then
            btn:setAutoShake(true)

        elseif (state ~= BOOSTER_ITEM_STATE.AVAILABLE) then
            btn:setAutoShake(false)
        end
    end
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_ReadySceneNew:click_backBtn()
	self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ReadySceneNew:click_exitBtn()
    local function next_func()
        self:close()
    end

    if (self.m_dontSaveOnExit) then next_func() return end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadySceneNew:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
end

-------------------------------------
-- function click_manageBtn
-- @breif 드래곤 관리
-------------------------------------
function UI_ReadySceneNew:click_manageBtn()
    local function next_func()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            local function func()
                self:refresh()
                self.m_readySceneSelect:init_dragonTableView()
                self.m_readySceneDeck:init_deck()
                
                do -- 정렬 도우미
					self:apply_dragonSort()
                end
            end
            self:sceneFadeInAction(func)
        end
        ui:setCloseCB(close_cb)
    end
    
    -- 덱 저장 후 이동
    self:checkChangeDeck(next_func)
end



-------------------------------------
-- function click_teamBonusBtn
-- @breif 팀 보너스
-------------------------------------
function UI_ReadySceneNew:click_teamBonusBtn()
    local l_deck = self.m_readySceneDeck.m_lDeckList
    local b_recommend = true
	local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck, nil, b_recommend)
    local refresh_cb = function(l_dragon_list)
        if (l_dragon_list) then
            self:applyDeck(l_dragon_list)
        end
    end

    ui:setCloseCB(refresh_cb)
end

-------------------------------------
-- function click_presetBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_presetBtn()
    local l_struct_preset_deck = {}
    local l_deck_name = {}
    local multi_deck_mgr = self.m_multiDeckMgr
    local is_league_raid = false
    local tab = self.m_readySceneDeck.m_selTab

    local cur_deck_name = g_deckData:getSelectedDeckName()
    if multi_deck_mgr ~= nil then
        cur_deck_name = multi_deck_mgr:getDeckName(tab)
    end

    if string.find(cur_deck_name, 'league_raid') ~= nil then
        l_deck_name = {'league_raid_1', 'league_raid_2', 'league_raid_3'}
        is_league_raid = true
    elseif string.find(cur_deck_name, 'clan_raid') ~= nil then
        table.insert(l_deck_name, cur_deck_name)
        local other_deck_name
        if string.find(cur_deck_name,'_up') ~= nil then
            other_deck_name = string.gsub(cur_deck_name, '_up', '_down')
        elseif string.find(cur_deck_name,'_up') ~= nil then
            other_deck_name = string.gsub(cur_deck_name, '_down', '_up')
        end        
        table.insert(l_deck_name, other_deck_name)

    elseif string.find(cur_deck_name, 'arena_new') ~= nil then
        l_deck_name = {'arena_new_a', 'arena_new_d'}
    end

    
    local cur_deck = nil
    for _, deck_str in ipairs(l_deck_name) do
        local l_deck, formation, deck_name, leader, tamer_id, formation_lv = g_deckData:getDeck(deck_str)
        local struct_preset_deck = StructPresetDeck()

        if cur_deck_name == deck_str then
            formation = self.m_readySceneDeck.m_currFormation
            l_deck = self.m_readySceneDeck.m_lDeckList
            leader = self.m_readySceneDeck.m_currLeader
        end

        struct_preset_deck:setDeckMap(l_deck)
        struct_preset_deck:setLeader(leader)
        struct_preset_deck:setFormation(formation)

        if cur_deck_name == deck_str then
            cur_deck = clone(struct_preset_deck)
        end

        table.insert(l_struct_preset_deck, struct_preset_deck)
    end

    local dirty = g_deckPresetData:makeDefaultDeck(cur_deck_name, l_struct_preset_deck)
    local cb_deck_change = function(struct_preset_deck)
        local l_deck = struct_preset_deck:getDeckMap()
        local formation_new = struct_preset_deck:getFormation()
        local leader = struct_preset_deck:getLeader()
        local name = struct_preset_deck:getPresetDeckName()

        -- 다른 번호 덱에 세팅되어 있는지 체크
        for _, doid in ipairs(l_deck) do
            if is_league_raid == true then
                if multi_deck_mgr and multi_deck_mgr:checkSameDidAnoterDeck_Raid(doid) == true then
                    return
                end
            else
                if multi_deck_mgr and multi_deck_mgr:checkSameDidAnoterDeck(tab, doid) == true then
                    return
                end
            end
        end

        local next_func = function ()
            self.m_readySceneDeck:init_deck()
            self:apply_dragonSort()
            UIManager:toastNotificationGreen(Str('{1}덱으로 설정되었습니다.', name))
        end
        
        self.m_readySceneDeck:setFormation(formation_new)
        self.m_readySceneDeck.m_currFormation = formation_new
        self.m_readySceneDeck.m_lDeckList = l_deck
        self.m_readySceneDeck.m_currLeader = leader

        self:refresh_combatPower()
        self:refresh_buffInfo()
        self.m_readySceneDeck:checkChangeDeck(next_func)
    end

    local ui = UI_PresetDeckList.open(cur_deck_name, cur_deck, cb_deck_change)
    ui:setDirty(dirty)
end

-------------------------------------
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_autoBtn()
    local stage_id = self.m_stageID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list

    local game_mode = self.m_gameMode
    local multi_deck_mgr = self.m_multiDeckMgr
    if (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑 (같은 속성 드래곤만 받아옴)
        if (attr) then
            l_dragon_list = g_dragonsData:getDragonsListWithAttr(attr)

        -- 고대의 탑
        else
            l_dragon_list = g_dragonsData:getDragonsList()
        end

    elseif (game_mode == GAME_MODE_LEAGUE_RAID) then
        local exist_dragons = g_leagueRaidData:getUsingDidTable()
        l_dragon_list = g_dragonsData:getDragonsListExceptTargetDoids(exist_dragons)

    -- 멀티덱 사용시 다른 위치 덱은 제외하고 추천
    elseif (multi_deck_mgr) then
        local mode = self.m_readySceneDeck.m_selTab
        local map_except_deck = multi_deck_mgr:getAnotherDeckMap(mode)
        l_dragon_list = g_dragonsData:getDragonsListExceptTarget(map_except_deck)

    else
        l_dragon_list = g_dragonsData:getDragonsList()
    end

    local helper = DragonAutoSetHelperNew(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    
    self:applyDeck(l_auto_deck)
end

-------------------------------------
-- function applyDeck
-------------------------------------
function UI_ReadySceneNew:applyDeck(l_deck)
    local new_deck = UI_ReadySceneNew_Deck:convertSimpleDeck(l_deck)
    local stage_id = self.m_stageID

    -- 시험의 탑 - 속성별 덱 추가 확인
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        local is_attr_tower = g_attrTowerData:getSelAttr()
        if (is_attr_tower) then
            if (not g_attrTowerData:checkDragonAttr(new_deck)) then
                return
            end
        end
    end

    -- 1. 덱을 비움
    local skip_sort = true
    self.m_readySceneDeck:clear_deck(skip_sort)

    -- 2. 덱을 채움
    for i,t_dragon_data in pairs(new_deck) do
        self.m_readySceneDeck:setFocusDeckSlotEffect(i)
        local skip_sort = true
        self:click_dragonCard(t_dragon_data, skip_sort, i)
    end

    -- 친구 드래곤 해제
    g_friendData:delSettedFriendDragon()

    -- 정렬
    self:apply_dragonSort()
end

-------------------------------------
-- function click_removeBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_removeBtn()
    -- 친구 드래곤 해제
    g_friendData:delSettedFriendDragon()

    self.m_readySceneDeck:clear_deck()
end

-------------------------------------
-- function click_teamBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_teamBtn(deck_name)
    local function next_func()
        self:changeTeam(deck_name)
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function changeTeam
-- @breif
-------------------------------------
function UI_ReadySceneNew:changeTeam(deck_name)
    -- 재료에서 "출전" 중 이라고 표시된 드래곤 해제
    for i,v in pairs(self.m_readySceneDeck.m_lDeckList) do
        local doid = v
        local table_view = self.m_readySceneSelect:getTableView()
        local item = table_view:getItem(doid)
        if (item and item['ui']) then
            item['ui']:setReadySpriteVisible(false)
        end
    end

    -- 선택된 덱 변경
    g_deckData:setSelectedDeck(deck_name)

    -- 변경된 덱으로 다시 초기화
    self.m_readySceneDeck:init_deck()

    -- 즉시 정렬
    self:apply_dragonSort()
end

-------------------------------------
-- function getNotUsedDailyFevertime
-- @breif 
-- @return table(list)
-------------------------------------
function UI_ReadySceneNew:getNotUsedDailyFevertime()
    local game_mode = self.m_gameMode

    if (game_mode == GAME_MODE_ADVENTURE) then
        return g_fevertimeData:getNotUsedDailyFevertime_adventure()
    end

    return {}
end

-------------------------------------
-- function checkFevertimePopupCondition
-- @breif 
-- @return boolean true일 경우 전투 시작 시 핫타임 팝업을 띄운다.
-- @return number usable_fevertime_count
-------------------------------------
function UI_ReadySceneNew:checkFevertimePopupCondition()
    local usable_fevertime_list = self:getNotUsedDailyFevertime()
    local usable_fevertime_count = table.count(usable_fevertime_list)

    -- 튜토리얼 진행 중이라면
    if (TutorialManager.getInstance():isDoing()) then
        return false
    end

    -- 핫타임 팝업이 1번 이상 열렸을 경우
    if (1 <= self.m_numOfFevertimePopupOpened) then
        return false
    end

    -- 해당하는 핫타임이 없음. 게임 시작 가능
    if (usable_fevertime_count == 0) then
        return false
    end

    -- 모험모드 1-7까지 클리어 체크
    if (not g_adventureData:isClearStage(1110107)) then
        return false
    end

    -- 하루에 한 번만 팝업을 띄움
    local save_key = 'ready_scene_fevertime_popup'
    local is_view = g_settingData:get('event_full_popup', save_key) or false
    if (is_view == true) then
        return false
    end
    g_settingData:applySettingData(true, 'event_full_popup', save_key)

    return true, usable_fevertime_count
end

-------------------------------------
-- function FevertimeConfirmPopup
-- @brief
-------------------------------------
function UI_ReadySceneNew:FevertimeConfirmPopup(struct_fevertime)
    local id = struct_fevertime:getFevertimeID()

    local function finish_cb(ret)
    end

    local function okBtn()
        g_fevertimeData:request_fevertimeActive(id, finish_cb)
    end

    local fevertime_name = struct_fevertime:getFevertimeName()
    local fevertime_description = struct_fevertime:getFevertimeDesc()
    local fevertime_period = struct_fevertime:getPeriodStr()
    local fevertime_value = struct_fevertime:getFevertimeValue()
    local fevertime_type = struct_fevertime:getFevertimeType()

    if (fevertime_period == '') or (struct_fevertime:isDailyHottime() == true) then
        fevertime_period = struct_fevertime:getTimeLabelStr()
    end
    UI_FevertimeConfirmPopup(fevertime_name, fevertime_period, fevertime_description, fevertime_value, fevertime_type, okBtn)
end

-------------------------------------
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_startBtn()
    local stage_id = self.m_stageID
    local can_start_game = true


    -- 핫타임 팝업 확인
    if (self:checkFevertimePopupCondition() == true) then
        -- 핫타임 팝업
        self:openFevertimePopup()
    
        -- 안내 팝업
        local msg = Str('일일 핫타임 사용 안내')
        local submsg = Str('아직 사용하지 않은 일일 핫타임이 있습니다.')
        local ok_cb = nil
        MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg, nil)
        return
    end

    -- 개발 스테이지
    if (stage_id == DEV_STAGE_ID) then
        self:checkChangeDeck(function()
            local scene = SceneGame(nil, stage_id, 'stage_dev', true)--SceneGame(nil, stage_id, 'stage_dev', true)
            --local scene = SceneGame(nil, EVENT_GOLD_STAGE_ID, 'stage_' .. EVENT_GOLD_STAGE_ID, true)
            --local scene = SceneGameEventArena(nil, ARENA_STAGE_ID, 'stage_colosseum', true)
            --local scene = SceneGameIntro()
            scene:runScene()
        end)
        return
    -- elseif (self.m_gameMode == GAME_MODE_DIMENSION_GATE) then
    --     self:checkChangeDeck(function()
    --         local scene = SceneGameTrial(nil, stage_id, 'stage_' .. stage_id, true)
    --         scene:runScene()
    --     end)
    --     return
     end

    -- 시작 가능한지 확인 (스태미나 등등)
    if (not self:check_startCondition(stage_id)) then    
		return
    end
	
    -- 클랜던전 연습모드의 경우
    if (self:isClanRaidTrainingMode(self.m_stageID)) then           
        self:startGame_clanRaidTraining()
        return
    end

    -- 클랜던전 죄악의 화신 토벌작전 이벤트의 경우
    if (self:isClanRaidEventIncarnationOfSinsMode(self.m_stageID)) then           
        self:startGame_eventIncarnationOfSins()
        return
    end

    -- 거대용던전 11층일 때 앱 설치 후 최초 한번만 경고팝업 노출
    if (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local uid = g_userData:get('uid') and g_userData:get('uid') or 'default'
        local stage_level = TableStageData():getValue(self.m_stageID, 'r_stage_info')
        local shown_alert = g_settingData:get('nest_eleven_alert', uid)

        local stage_ids = {1210011, 1210111, 1210211, 1210311, 1210411, 1210511}
        local is_eleventh_stage = false
        for i,v in ipairs(stage_ids) do
            if (self.m_stageID == v) then
                is_eleventh_stage = true
            end
        end

        if (is_eleventh_stage and shown_alert ~= true) then
            MakeSimplePopup(POPUP_TYPE.YES_NO, Str('난이도가 매우 높은 던전입니다. 도전하시겠습니까?'), 
                function() 
                    g_settingData:applySettingData(true, 'nest_eleven_alert', uid) 
                    self:startGame(stage_id)
                end)
            return
        end
    end
	
    self:startGame(stage_id)
end

-------------------------------------
-- function check_startCondition
-- @breif 시작 가능한 상태인지 체크하는 함수 분리 - 가능하면 true, 불가능하면 flase 반환
-------------------------------------
function UI_ReadySceneNew:check_startCondition(stage_id)
    local stamina_charge = true
    local multi_deck_mgr = self.m_multiDeckMgr

    -- 클랜던전은 활동력 충전 x 소비 o
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        stamina_charge = false
    end

    -- 멀티덱 - 상단덱과 하단덱 추가 확인
    if (multi_deck_mgr) then

        -- 상단, 하단 덱 모두 체크
        if (not multi_deck_mgr:checkDeckCondition()) then
            return false
        end

    -- 시험의 탑 - 속성별 덱 추가 확인
    elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        local is_attr_tower = g_attrTowerData:getSelAttr()
        if (is_attr_tower) then
            local l_deck = self.m_readySceneDeck.m_lDeckList
            if (not g_attrTowerData:checkDragonAttr(l_deck)) then
                return false
            end
        end
    end
    
    local difficulty, chapter, stage = parseAdventureID(stage_id)
    local is_advent = (chapter == SPECIAL_CHAPTER.ADVENT) or (chapter == SPECIAL_CHAPTER.RUNE_FESTIVAL)

    -- 모드 상관없이 공통으로 체크
    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed(Str('최소 1명 이상은 출전시켜야 합니다.'))
        return false
    -- 1명만 출전할 경우, 내 드래곤 없이 친구만 출전하는지 체크 @jhakim 친구를 1명만 데려갈 수 있다는 룰일 때만 유효
    elseif (self:getDragonCount() == 1) then
        if (not self.m_readySceneDeck:isContainMyDragon()) then
            UIManager:toastNotificationRed(Str('친구 드래곤만 출전할 수는 없습니다'))
            return false
        end
    elseif (not is_advent) and (not g_stageData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이전 스테이지를 클리어하세요.'))
        return false
    -- 스태미너 소모 체크
    elseif (stamina_charge) and (not g_staminasData:checkStageStamina(stage_id)) then
        g_staminasData:staminaCharge(stage_id)
        return false
    -- 룬 축제 이벤트 (일일 제한 확인)
    elseif (g_stageData:isRuneFestivalStage(stage_id) == true) then
            local stamina_type, req_count = g_staminasData:getStageStaminaCost(stage_id)
            if (g_eventRuneFestival:isDailyStLimit(req_count) == true) then
                local msg = Str('하루 날개 사용 제한을 초과했습니다.')
                local submsg = g_eventRuneFestival:getRuneFestivalStaminaText()
                MakeSimplePopup2(POPUP_TYPE.OK, msg, submsg)
                return false
            end
        else
    end
        
    return true
end

-------------------------------------
-- function startGame
-- @breif
-------------------------------------
function UI_ReadySceneNew:startGame(stage_id)
    local check_deck
    local check_dragon_inven
    local check_item_inven
    local check_cash
    local check_boss
    local start_game

    -- 덱 변경 유무 확인 후 저장
    check_deck = function()
        self:checkChangeDeck(check_dragon_inven)
    end

    -- 드래곤 가방 확인(최대 갯수 초과 시 획득 못함)
    check_dragon_inven = function()
        local function manage_func()
            self:click_manageBtn()
        end
        g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
    end

    -- 아이템 가방 확인(최대 갯수 초과 시 획득 못함)
    check_item_inven = function()
        local function manage_func()
            -- UI_Inventory() @kwkang 룬 업데이트로 룬 관리쪽으로 이동하게 변경 
            UI_RuneForge('manage')
        end
        g_inventoryData:checkMaximumItems(check_cash, manage_func)
    end

    -- 여의주 사용 확인
    check_cash = function()

        -- 클랜던전 여의주 사용
        if (g_clanRaidData:isClanRaidStageID(stage_id)) then
            local struct_raid = g_clanRaidData:getClanRaidStruct()
            
            -- 파이널 블로우의 경우 다이아 or 입장권 선택
            if (g_clanRaidData:isFinalBlow()) then
                local select_func = function(is_cash)
                    self.m_bUseCash = is_cash
                    check_boss()
                end
                g_clanRaidData:selectEnterWayPopup(select_func, stage_id)
            
            -- 활동력 체크 (소비 타입이 아니어서 여기서 체크)
            elseif (g_staminasData:checkStageStamina(stage_id)) then
                check_boss()

            -- 진행중인 유저 체크 추가 (덱 준비화면은 진행 여부 상관없이 진입 가능하게 수정됨)
            elseif (struct_raid and struct_raid:getState() == CLAN_RAID_STATE.CHALLENGE) then
                local msg = Str('이미 클랜 던전에 입장한 유저가 있습니다.')
                local refresh_cb = function()
                    g_clanRaidData:request_info(self.m_stageID)
                end
                MakeSimplePopup(POPUP_TYPE.OK, msg, refresh_cb)
            else
                UIManager:toastNotificationRed(Str('더이상 던전에 입장할 수 없습니다.'))
            end
        else
            start_game()
        end
    end

    check_boss = function()
        -- 클랜던전 보스 정보 동기화
        local finish_cb = function()
            -- 보스 정보가 변경되었다면 다시 모두 갱신
            if (not g_clanRaidData:checkBossStatus()) then
                UIManager:toastNotificationGreen(Str('던전 정보가 갱신되었습니다.'))
                UINavigator:goTo('clan_raid')
            else
                start_game()
            end
        end

        g_clanRaidData:request_info(self.m_stageID, finish_cb)
    end

    -- 게임 시작
    start_game = function()
        self:networkGameStart()
    end
        
    check_deck()
end

-------------------------------------
-- function askCashPlay
-------------------------------------
function UI_ReadySceneNew:askCashPlay(cnt, next_cb)
    local function ok_btn_cb()
        self.m_bUseCash = true
        next_cb()
    end

    local msg = Str('입장권이 부족합니다.\n{@impossible}다이아몬드 {1}개{@default}를 사용해 진행하시겠습니까?', cnt)
    UI_ConfirmPopup('cash', cnt, msg, ok_btn_cb)
end

-------------------------------------
-- function click_autoStartOnBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_autoStartOnBtn()
    local function refresh_btn()
        self.vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay())
    end

    local function load_best_deck()
        self:click_loadBestTeam()
    end

    local is_auto = g_autoPlaySetting:isAutoPlay()

    -- 바로 해제
    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
        refresh_btn()
    else
        local ui = UI_AutoPlaySettingPopup(self.m_gameMode)
        ui:setCloseCB(refresh_btn)
        if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
            if (not g_ancientTowerData:isAttrChallengeMode()) then
                ui:setLoadDeckCb(load_best_deck)
            end
        end
    end
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_fomationBtn()
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui
	if (self.m_bArena) then
        ui = UI_FormationArenaPopup(curr_formation_type)
    else
        ui = UI_FormationPopup(curr_formation_type)
    end

	-- 종료하면서 선택된 formation을 m_readySceneDeck으로 전달
	local function close_cb(formation_type)
        if formation_type then
		    self.m_readySceneDeck:setFormation(formation_type)
            self:refresh_combatPower()
		    self:refresh_buffInfo()
        end
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_showTrainingBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_showTrainingBtn()
	UI_ClanRaidTrainingPopup()
end

-------------------------------------
-- function click_incarnationOfSinsSetBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_incarnationOfSinsSetBtn()
    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local attr = struct_raid.attr
    local stage_lv = struct_raid:getLv()
    UI_EventIncarnationOfSinsEntryPopup(attr, stage_lv)
end

-------------------------------------
-- function click_goldBoosterBtn
-- @breif 골드 부스터
-------------------------------------
function UI_ReadySceneNew:click_goldBoosterBtn()
    local refresh_cb = function()
        -- 부스터 버튼 액션이 update문에서 엇갈려서 여기서 다시 액션 멈춰줌
        self.vars['expBoosterBtn']:setAutoShake(false)
        self.vars['goldBoosterBtn']:setAutoShake(false)

        g_hotTimeData:refresh_boosterMailInfo()
    end

    local booster_mail_info = g_hotTimeData.m_boosterMailInfo['buff_gold2x']
    -- 사용하기
    if (booster_mail_info) then
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.GOLD_BOOSTER, refresh_cb)

    -- 상점
    else
        local is_popup = true
        UINavigator:goTo('shop_booster', is_popup, refresh_cb)
    end
end

-------------------------------------
-- function click_expBoosterBtn
-- @breif 경험치 부스터
-------------------------------------
function UI_ReadySceneNew:click_expBoosterBtn()
    local refresh_cb = function()
        g_hotTimeData:refresh_boosterMailInfo()
    end

    local booster_mail_info = g_hotTimeData.m_boosterMailInfo['buff_exp2x']
    -- 사용하기
    if (booster_mail_info) then
        UINavigator:goTo('mail_select', MAIL_SELECT_TYPE.EXP_BOOSTER, refresh_cb)

    -- 상점
    else
        local is_popup = true
        UINavigator:goTo('shop_booster', is_popup, refresh_cb)
    end
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_tamerBtn()
    local function refresh_cb()
		self:refresh_tamer()
        self:refresh_combatPower()
		self:refresh_buffInfo()
	end
	UINavigator:goTo('tamer', nil, refresh_cb)
end

-------------------------------------
-- function click_leaderBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_leaderBtn()
	local l_doid = self.m_readySceneDeck.m_lDeckList
	local leader_idx = self.m_readySceneDeck.m_currLeader

	-- 리더버프 있는 드래곤 체크
	do
		local cnt = 0
		for _, doid in pairs(l_doid) do
			if (g_dragonsData:haveLeaderSkill(doid)) then
				cnt = cnt + 1
			end
		end
	end

	local ui = UI_ReadyScene_LeaderPopup(l_doid, leader_idx)
	ui:setCloseCB(function() 
		self.m_readySceneDeck.m_currLeader = ui.m_leaderIdx
        self.m_readySceneDeck.m_currLeaderOID = l_doid[ui.m_leaderIdx]
        self:refresh_combatPower()
		self:refresh_buffInfo()
	end)
end

-------------------------------------
-- function click_loadBestTeam
-- @breif 저장되어 있던 베스트 덱을 세팅
-------------------------------------
function UI_ReadySceneNew:click_loadBestTeam()
    local t_data = g_settingDeckData:getDeckAncient(tostring(self.m_stageID))
    if (not t_data) then
        UIManager:toastNotificationRed(Str('저장된 베스트 팀이 없습니다'))
        return
    end

    local l_deck = t_data['deck']
    -- 저장된 드래곤이 없어도 베스트 팀이 없다고 간주
    if (#l_deck == 0) then
        UIManager:toastNotificationRed(Str('저장된 베스트 팀이 없습니다'))
        return
    end
    
    -- 기존 덱에 있던 드래곤 내보냄
    self:click_removeBtn()

    local formation = t_data['formation']
    local deckname = t_data['deckName']
    local leader = t_data['leader']
    local tamer_id = t_data['tamer']


    local func_refresh = function()
        self:refresh_tamer()
        self:refresh_buffInfo()
        self:refresh_combatPower()
    end
    -- 테이머 세팅
    g_tamerData:request_setTamer(tamer_id, func_refresh)

    -- 덱 세팅
    self.m_readySceneDeck:setDeck(l_deck, formation, deckname, leader, tamer_id, nil)

    -- 정렬
    self:apply_dragonSort()
end

-------------------------------------
-- function click_saveBestTeam
-- @breif 베스트 팀 갱신, 최고 점수는 0으로 초기화
-------------------------------------
function UI_ReadySceneNew:click_saveBestTeam()
    local cur_stage_id = self.m_stageID
    local ok_btn_cb = function()
        local l_deck, formation, deck_name, leader, tamer_id = self.m_readySceneDeck:getCurDeckInfo()
        g_settingDeckData:saveAncientTowerDeck(l_deck, formation, leader, tamer_id, 0, cur_stage_id) -- l_deck, formation, leader, tamer_id, score
        
        -- 초기화된 점수 갱신
        local best_score = g_settingDeckData:getAncientStageScore(self.m_stageID)
        self.vars['towerScoreLabel']:setString(Str('{1}층 팀 최고점수 : {2}', g_ancientTowerData:getFloorFromStageID(self.m_stageID), comma_value(best_score)))
    end

    local cancel_btn_cb = function()
    end
    
    local msg = Str('현재 팀을 {1}층 베스트 팀으로 저장합니다.\n{1}층 팀 최고 점수는 초기화 됩니다.', cur_stage_id%1000)
    MakeSimplePopup(POPUP_TYPE.YES_NO, msg, ok_btn_cb, cancel_btn_cb)
end

-------------------------------------
-- function openFevertimePopup
-------------------------------------
function UI_ReadySceneNew:openFevertimePopup()

    -- 핫타임 팝업이 열린 횟수 증가
    self.m_numOfFevertimePopupOpened = (self.m_numOfFevertimePopupOpened + 1)

    -- 핫타임 팝업 띄움 (바로가기 버튼 사용 불가하게 설정)
    require('UI_Fevertime')
    local ui = UI_Fevertime(false) -- param : enabled_link_btn
    ui:openPopup()

    local function close_cb()
        local vars = self.vars
        local usable_fevertime_list = self:getNotUsedDailyFevertime()
        if (1 <= table.count(usable_fevertime_list)) then
            vars['fevertimeNotiSprite']:setVisible(true)
        else
            vars['fevertimeNotiSprite']:setVisible(false)
        end
    end
    ui:setCloseCB(close_cb)

    return ui
end

-------------------------------------
-- function replaceGameScene
-- @breif
-------------------------------------
function UI_ReadySceneNew:replaceGameScene(game_key)
    -- 시작이 두번 되지 않도록 하기 위함
    UI_BlockPopup()

    local stage_id = self.m_stageID
    local stage_name = 'stage_' .. stage_id
    local scene

    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        scene = SceneGameClanRaid(game_key, stage_id, stage_name, false)

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
        scene = SceneGameEventArena(nil, ARENA_STAGE_ID, 'stage_colosseum', false, false) -- game_key, stage_id, stage_name, develop_mode, friend_match

    else
        scene = SceneGame(game_key, stage_id, stage_name, false)
    end

    scene:runScene()
end

-------------------------------------
-- function networkGameStart
-- @breif
-------------------------------------
function UI_ReadySceneNew:networkGameStart()
    local function finish_cb(game_key)
        self:replaceGameScene(game_key)
    end

    local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = self.m_readySceneDeck:getDeckCombatPower()

    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local is_cash = self.m_bUseCash
        g_clanRaidData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb, is_cash)

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        g_ancientRuinData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)

    -- 그랜드 콜로세움 (이벤트 PvP 10대10)
    elseif (self.m_gameMode == GAME_MODE_EVENT_ARENA) then
        finish_cb(game_key)
    --elseif (self.m_gameMode == GAME_MODE_DIMENSION_GATE) then
        
    else
        g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)
    end
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ReadySceneNew:refresh_dragonCard(doid, is_friend)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid, is_friend)
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadySceneNew:checkChangeDeck(next_func)
    return self.m_readySceneDeck:checkChangeDeck(next_func)
end

-------------------------------------
-- function isContainMyDragon
-------------------------------------
function UI_ReadySceneNew:isContainMyDragon()
    return self.m_readySceneDeck:isContainMyDragon()
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ReadySceneNew:getDragonCount()
    return self.m_readySceneDeck:getDragonCount()
end

-------------------------------------
-- function getStageStaminaInfo
-- @brief stage_id에 해당하는 필요 스태미너 타입, 갯수 리턴
-------------------------------------
function UI_ReadySceneNew:getStageStaminaInfo()
    local stage_id = self.m_stageID
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    -- 'stamina' 추후에 타입별 stamina 사용 예정
    local cost_type, cost_value
	if (stage_id == COLOSSEUM_STAGE_ID) then
		cost_type = 'pvp'
		cost_value = 1
    elseif (stage_id == FRIEND_MATCH_STAGE_ID) then
		cost_type = 'fpvp'
		cost_value = 1
    elseif (stage_id == ARENA_STAGE_ID) then
        cost_type = 'arena'
		cost_value = 1
    elseif (stage_id == ARENA_NEW_STAGE_ID) then
        cost_type = 'arena'
		cost_value = 1
	else
		cost_type = 'st'
		cost_value = t_drop['cost_value']	
	end
    return cost_type, cost_value
end

-------------------------------------
-- function close
-------------------------------------
function UI_ReadySceneNew:close()
    UI.close(self)
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_ReadySceneNew:getCurrTamerID()
    local tamer_id = g_tamerData:getCurrTamerID()
    return tamer_id
end

-------------------------------------
-- function startGame_clanRaidTraining
-------------------------------------
function UI_ReadySceneNew:startGame_clanRaidTraining()
    --[[
    if (g_clanRaidData.m_triningTicketCnt <= 0) then
        UIManager:toastNotificationRed(Str('{1}이 부족합니다.', Str('연습 전투 입장권')))
        return 
    end]]
    
    local function finish_cb()
        self:replaceGameScene()
    end

    local func_start = function()
        local struct_raid = g_clanRaidData:getClanRaidStruct()
        g_stageData:requestGameStart_training(struct_raid:getStageID(), struct_raid.attr, finish_cb, nil)
    end

    self:checkChangeDeck(func_start)
end


-------------------------------------
-- function isClanRaidTrainingMode
-------------------------------------
function UI_ReadySceneNew:isClanRaidTrainingMode(stage_id)
    if (g_clanRaidData) then
        if (g_clanRaidData:isClanRaidStageID(stage_id)) then
            local struct_raid = g_clanRaidData:getClanRaidStruct()
            if (struct_raid:isTrainingMode()) then
                return true
            end
        end
    end
    return false
end

-------------------------------------
-- function startGame_eventIncarnationOfSins
-------------------------------------
function UI_ReadySceneNew:startGame_eventIncarnationOfSins()
    local function finish_cb()
        self:replaceGameScene()
    end

    local func_start = function()
        local struct_raid = g_clanRaidData:getClanRaidStruct()
        local stage = struct_raid.stage
        local attr = struct_raid.attr

        local multi_deck_mgr = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)
        local deck_name1 = multi_deck_mgr:getDeckName('up')
        local deck_name2 = multi_deck_mgr:getDeckName('down')

        local token1 = g_stageData:makeDragonToken(deck_name1)
        local token2 = g_stageData:makeDragonToken(deck_name2)

        g_eventIncarnationOfSinsData:request_eventIncarnationOfSinsStart(stage, attr, deck_name1, deck_name2, token1, token2, finish_cb, nil)
    end

    self:checkChangeDeck(func_start)
end


-------------------------------------
-- function isClanRaidEventIncarnationOfSinsMode
-------------------------------------
function UI_ReadySceneNew:isClanRaidEventIncarnationOfSinsMode(stage_id)
    if (g_clanRaidData) then
        if (g_clanRaidData:isClanRaidStageID(stage_id)) then
            local struct_raid = g_clanRaidData:getClanRaidStruct()
            if (struct_raid:isEventIncarnationOfSinsMode()) then
                return true
            end
        end
    end
    return false
end

-------------------------------------
-- function click_attrInfoBtn
-------------------------------------
function UI_ReadySceneNew:click_attrInfoBtn()
    UI_HelpDragonGuidePopup('attr')
end

-------------------------------------
-- function click_runeBtn
-------------------------------------
function UI_ReadySceneNew:click_runeBtn()
    local vars = self.vars

    local is_visible = (not vars['runeSprite']:isVisible())

    vars['runeSprite']:setVisible(is_visible)
    self.m_readySceneDeck:setVisibleEquippedRunes(is_visible)
end

--@CHECK
UI:checkCompileError(UI_ReadySceneNew)
