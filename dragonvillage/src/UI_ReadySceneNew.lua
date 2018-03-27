local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable(), ITabUI:getCloneTable()) 

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
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew:init(stage_id, sub_info)
    -- spine 캐시 정리
    SpineCacheManager:getInstance():purgeSpineCacheData()
    self.m_gameMode = g_stageData:getGameMode(stage_id)
    self.m_subInfo = sub_info
	if (not stage_id) then
		stage_id = COLOSSEUM_STAGE_ID
	end
    self:init_MemberVariable(stage_id)

    -- 모험모드에서만 친구사용
    self.m_bWithFriend = (self.m_gameMode == GAME_MODE_ADVENTURE) and true or false
    self.m_bUseCash = false

    local vars = self:load('battle_ready_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 레디씬 진입시 선택된 친구정보 초기화
    g_friendData:delSettedFriendDragon()

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_ReadySceneNew')

	self:checkDeckProper()
    
	self:initUI()
    self:initButton()
	
    self.m_readySceneSelect = UI_ReadySceneNew_Select(self)
    self.m_readySceneSelect:setFriend(self.m_bWithFriend)

	self.m_readySceneDeck = UI_ReadySceneNew_Deck(self)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
        self:refresh_slotLight()
	end)

    self:refresh()

	self:init_sortMgr()

    -- 자동 전투 off
    if (stage_id == COLOSSEUM_STAGE_ID) then
        g_autoPlaySetting:setMode(AUTO_COLOSSEUM)
    else
        g_autoPlaySetting:setMode(AUTO_NORMAL)
    end
    g_autoPlaySetting:setAutoPlay(false)

    -- 매일매일 다이아 풀팝업
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        g_fullPopupManager:show(FULL_POPUP_TYPE.AUTO_PICK)
    end
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

    
	-- 들어온 경로에 따라 sound가 다름
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_uiBgm = 'bgm_dungeon_ready'
	else
		self.m_uiBgm = 'bgm_lobby'
	end

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

	local curr_mode = TableDrop():getValue(self.m_stageID, 'mode')

    -- 클랜 던전 별도 처리 
    if (curr_mode == 'clan') then
        local deck_name = g_clanRaidData:getDeckName()
        if (deck_name) then
            g_deckData:setSelectedDeck(deck_name)
            return
        end
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
-- function condition_clan_raid
-- @breif 1,2공격대에 설정된 드래곤을 정렬 우선순위로 사용
-------------------------------------
function UI_ReadySceneNew:condition_clan_raid(a, b)
    local is_setted_1, num_1 = g_clanRaidData:isSettedClanRaidDeck(a['data']['id']) 
    local is_setted_2, num_2 = g_clanRaidData:isSettedClanRaidDeck(b['data']['id']) 

    if (is_setted_1) and (is_setted_2) then
        return nil

    elseif (is_setted_1) then
        return true

    elseif (is_setted_2) then
        return false

    else
        return nil
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
-- function init_sortMgr
-------------------------------------
function UI_ReadySceneNew:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()
    self.m_sortManagerFriendDragon = SortManager_Dragon()
    
    -- 클랜던전 1,2 공격대 덱을 맨위로
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local function cond(a, b)
			return self:condition_clan_raid(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('clan_raid', false, cond)
    end

    do
        local function cond(a, b)
			return self:condition_deck_idx(a, b)
		end
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

	-- 콜로세움 예외처리
	if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID) then		
        vars['cpNode2']:setVisible(false)
        
		-- 배경 아무거나 넣어준다
		vars['bgNode']:removeAllChildren()
		local animator = ResHelper:getUIDragonBG('fire', 'idle')
        vars['bgNode']:addChild(animator.m_node)

        set_autobtn_off()
	end

    -- 클랜던전 예외처리
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        vars['clanRaidMenu']:setVisible(true)
        vars['cpNode2']:setVisible(false)
        vars['formationNode']:setPositionX(-230)
        set_autobtn_off()
    end

    -- 이벤트 골드 던전 예외처리
    if (self.m_stageID == EVENT_GOLD_STAGE_ID) then
        set_autobtn_off()
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

    -- 광고 보기
    vars['itemAutoBtn']:registerScriptTapHandler(function() self:click_itemAutoBtn() end)

    -- 골드 부스터
    vars['goldBoosterBtn']:registerScriptTapHandler(function() self:click_goldBoosterBtn() end)

    -- 경험치 부스터 
    vars['expBoosterBtn']:registerScriptTapHandler(function() self:click_expBoosterBtn() end)

    -- 콜로세움일 경우
    if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID) then
        vars['actingPowerNode']:setVisible(false)
        vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
        vars['startBtnLabel']:setPositionX(0)
        vars['startBtnLabel']:setString(Str('변경 완료'))
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

	    elseif (stage_id == FRIEND_MATCH_STAGE_ID) then
            str = Str('친구대전 공격')
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
            local cost_value = math_floor(stamina_value / 2)
            vars['actingPowerLabel']:setString(cost_value)
            vars['actingPowerLabel']:setTextColor(cc.c4b(0, 255, 255, 255))
            vars['hotTimeSprite']:setVisible(true)
            vars['hotTimeStLabel']:setString('1/2')
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

	if (stage_id == COLOSSEUM_STAGE_ID or stage_id == FRIEND_MATCH_STAGE_ID or game_mode == GAME_MODE_CLAN_RAID) then
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
		self.m_readySceneDeck:refreshLeader()
		
		local leader_buff		
		local leader_idx = self.m_readySceneDeck.m_currLeader
		local l_doid = self.m_readySceneDeck.m_lDeckList
		local leader_doid = l_doid[leader_idx]
		if (leader_doid) then
			local t_dragon_data = g_dragonsData:getDragonDataFromUid(leader_doid)
			local skill_mgr = MakeDragonSkillFromDragonData(t_dragon_data)
			local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx('Leader')

			if (skill_info) then
				leader_buff = skill_info:getSkillDesc()
			else
				leader_buff = Str('리더 버프 없음')
			end
		else
			leader_buff = Str('리더 버프 없음')
		end
		vars['leaderBuffLabel']:setString(leader_buff)
	end

	-- 진형 버프
	do
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
    local stage_id = self.m_stageID

    -- 클랜던전 slot light
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local up_deck_cnt = g_clanRaidData:getDeckDragonCnt('up')
        for idx = 1, 5 do
            local slot_light = vars['slotSprite'..idx]
            slot_light:setVisible(idx <= up_deck_cnt)
        end

        local down_deck_cnt = g_clanRaidData:getDeckDragonCnt('down')
        for idx = 1, 5 do
            local slot_light = vars['slotSprite'..(idx + 5)]
            slot_light:setVisible(idx <= down_deck_cnt)
        end
    end
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

    -- 광고보기 (추가)
    do
        local str, active = g_advertisingData:getCoolTimeStatus(AD_TYPE.AUTO_ITEM_PICK)
        vars['itemAutoLabel']:setString(str)
    end

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
	local ui = UI_TeamBonus(TEAM_BONUS_MODE.TOTAL, l_deck)
    local refresh_cb = function(l_dragon_list)
        if (l_dragon_list) then
            self:applyDeck(l_dragon_list)
        end
    end

    ui:setCloseCB(refresh_cb)
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
    if (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- 시험의 탑 (같은 속성 드래곤만 받아옴)
        if (attr) then
            l_dragon_list = g_dragonsData:getDragonsListWithAttr(attr)

        -- 고대의 탑
        else
            l_dragon_list = g_dragonsData:getDragonsList()
        end

    elseif (game_mode == GAME_MODE_CLAN_RAID) then
        local mode = self.m_readySceneDeck.m_selTab
        local map_except_deck = g_clanRaidData:getAnotherDeckMap(mode)

        -- 클랜던전 다른덱 제외하고 추천덱
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
    if (g_ancientTowerData:isAncientTowerStage(stage_id)) then
        if (not g_attrTowerData:checkDragonAttr(new_deck)) then
            return
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
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_startBtn()
    local stage_id = self.m_stageID

    -- 개발 스테이지
    if (stage_id == DEV_STAGE_ID) then
        self:checkChangeDeck(function()
            --local scene = SceneGame(nil, stage_id, 'stage_dev', true)
            --local scene = SceneGame(nil, EVENT_GOLD_STAGE_ID, 'stage_' .. EVENT_GOLD_STAGE_ID, true)
            local scene = SceneGame(nil, ANCIENT_RUIN_STAGE_ID, 'stage_' .. ANCIENT_RUIN_STAGE_ID)
            scene:runScene()
        end)
        return
    end

    if (self:check_startCondition(stage_id)) then
        self:startGame(stage_id)
    end
end

-------------------------------------
-- function check_startCondition
-- @breif 시작 가능한 상태인지 체크하는 함수 분리 - 가능하면 true, 불가능하면 flase 반환
-------------------------------------
function UI_ReadySceneNew:check_startCondition(stage_id)
    local stamina_charge = true

    -- 클랜던전 - 상단덱과 하단덱 추가 확인
    if (g_clanRaidData:isClanRaidStageID(stage_id)) then

        -- 클랜던전은 활동력 충전 x 소비 o
        stamina_charge = false

        -- 상단, 하단 덱 모두 체크
        if (not self:checkClanRaidDragon()) then
            return false
        end

    -- 시험의 탑 - 속성별 덱 추가 확인
    elseif (g_ancientTowerData:isAncientTowerStage(stage_id)) then
        local l_deck = self.m_readySceneDeck.m_lDeckList
        if (not g_attrTowerData:checkDragonAttr(l_deck)) then
            return false
        end
    end

    -- 모드 상관없이 공통으로 체크
    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed(Str('최소 1명 이상은 출전시켜야 합니다.'))
        return false

    elseif (not g_stageData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('이전 스테이지를 클리어하세요.'))
        return false

    -- 스태미너 소모 체크
    elseif (stamina_charge) and (not g_staminasData:checkStageStamina(stage_id)) then
        g_staminasData:staminaCharge(stage_id)
        return false
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
            UI_Inventory()
        end
        g_inventoryData:checkMaximumItems(check_cash, manage_func)
    end

    -- 여의주 사용 확인
    check_cash = function()

        -- 클랜던전 여의주 사용
        if (g_clanRaidData:isClanRaidStageID(stage_id)) then
            
            -- 개발모드에서 클랜던전 무조건 입장
--            if IS_TEST_MODE() then
--                start_game()
--                return
--            end

            -- 활동력 체크 (소비 타입이 아니어서 여기서 체크)
            if (g_staminasData:checkStageStamina(stage_id)) then
                start_game()

            -- 여의주 사용가능
            elseif (g_clanRaidData:isPossibleUseCash()) then
                local cash_cnt = g_clanRaidData:getUseCashCnt()
                self:askCashPlay(cash_cnt, start_game)

            else
                UIManager:toastNotificationRed(Str('더이상 던전에 입장할 수 없습니다.'))
            end
        else
            start_game()
        end
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

    local is_auto = g_autoPlaySetting:isAutoPlay()

    -- 바로 해제
    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
        refresh_btn()
    else
        local ui = UI_AutoPlaySettingPopup(self.m_gameMode)
        ui:setCloseCB(refresh_btn)
    end
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_fomationBtn()
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationPopup(curr_formation_type)
	
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
-- function click_itemAutoBtn
-- @breif 광고 보기
-------------------------------------
function UI_ReadySceneNew:click_itemAutoBtn()
    g_subscriptionData:openSubscriptionPopup()
end

-------------------------------------
-- function click_goldBoosterBtn 
-- @breif 골드 부스터
-------------------------------------
function UI_ReadySceneNew:click_goldBoosterBtn()
    local refresh_cb = function()
        g_hotTimeData:refresh_boosterMailInfo()
    end

    local booster_mail_info = g_hotTimeData.m_boosterMailInfo['buff_gold2x']
    -- 사용하기
    if (booster_mail_info) then
        local use_cb = function()
            booster_mail_info:readMe(refresh_cb)
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('골드 부스터를 사용하시겠습니까?'), use_cb)

    -- 상점
    else
        local is_popup = true
        UINavigator:goTo('shop_daily', is_popup, refresh_cb)
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
        local use_cb = function()
            booster_mail_info:readMe(refresh_cb)
        end
        MakeSimplePopup(POPUP_TYPE.YES_NO, Str('경험치 부스터를 사용하시겠습니까?'), use_cb)

    -- 상점
    else
        local is_popup = true
        UINavigator:goTo('shop_daily', is_popup, refresh_cb)
    end
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_tamerBtn()
    local ui = UI_TamerManagePopup()
	ui:setCloseCB(function() 
		self:refresh_tamer()
        self:refresh_combatPower()
		self:refresh_buffInfo()
	end)
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
-- function getDragonCount
-------------------------------------
function UI_ReadySceneNew:getDragonCount()
    return self.m_readySceneDeck:getDragonCount()
end

-------------------------------------
-- function checkClanRaidDragon
-------------------------------------
function UI_ReadySceneNew:checkClanRaidDragon()
    return self.m_readySceneDeck:checkClanRaidDragon()
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

--@CHECK
UI:checkCompileError(UI_ReadySceneNew)
