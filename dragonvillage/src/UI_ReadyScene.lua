local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable()) --ITabUI:getCloneTable())

-------------------------------------
-- class UI_ReadyScene
-------------------------------------
UI_ReadyScene = class(PARENT,{
        m_stageID = 'number',
        m_stageAttr = 'attr',

        -- UI_ReadyScene_Select 관련 변수
        m_readySceneSelect = 'UI_ReadyScene_Select',

        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadyScene_Deck',

        -- 정렬 도우미
		m_sortManagerDragon = '',
        m_sortManagerFriendDragon = '',
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadyScene:init(stage_id)
	if (not stage_id) then
		stage_id = COLOSSEUM_STAGE_ID
	end
    self:init_MemberVariable(stage_id)

    local vars = self:load('battle_ready.ui')
    UIManager:open(self, UIManager.SCENE)

	-- 들어온 경로에 따라 sound가 다름
	local game_mode = g_stageData:getGameMode(self.m_stageID)
	if (game_mode == GAME_MODE_ADVENTURE) then
		SoundMgr:playBGM('bgm_dungeon_ready')
	else
		SoundMgr:playBGM('bgm_lobby')
	end

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_ReadyScene')

	self:checkDeckProper()
    
	self:initUI()
    self:initButton()
	
    self.m_readySceneSelect = UI_ReadyScene_Select(self)
    
    local with_friend = true
	self.m_readySceneDeck = UI_ReadyScene_Deck(self, with_friend)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
	end)

    self:refresh()

	self:init_sortMgr()

	self:init_battleGift()

    -- 자동 전투 off
    g_autoPlaySetting:setAutoPlay(false)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ReadyScene:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ReadyScene'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)
end

-------------------------------------
-- function init_MemberVariable
-------------------------------------
function UI_ReadyScene:init_MemberVariable(stage_id)
    self.m_stageID = stage_id
	self.m_stageAttr = TableDrop():getValue(stage_id, 'attr')
end

-------------------------------------
-- function checkDeckProper
-- @brief 해당 모드에 맞는 덱인지 체크하고 아니라면 바꿔준다.
-------------------------------------
function UI_ReadyScene:checkDeckProper()
	local curr_mode = TableDrop():getValue(self.m_stageID, 'mode')
	local curr_deck_name = g_deckData:getSelectedDeckName()
	if not (curr_mode == curr_deck_name) then
		g_deckData:setSelectedDeck(curr_mode)
	end
end

-------------------------------------
-- function condition_battle_gift
-------------------------------------
function UI_ReadyScene:condition_battle_gift(a, b)
	local gift_dragon = g_dragonsData:getBattleGiftDragon()
	if (not gift_dragon) then
		return nil
	end

	if (a['data']['id'] == gift_dragon['id']) then
		return true

	elseif (b['data']['id'] == gift_dragon['id']) then
		return false

	else
		return nil
	end
end

-------------------------------------
-- function condition_deck_idx
-------------------------------------
function UI_ReadyScene:condition_deck_idx(a, b)
	for doid, v in pairs(self.m_readySceneDeck.m_tDeckMap) do
	end

    local a_deck_idx = self.m_readySceneDeck.m_tDeckMap[a['data']['id']] or 999
    local b_deck_idx = self.m_readySceneDeck.m_tDeckMap[b['data']['id']]  or 999
	 
    -- 덱에 설정된 데이터로 우선 정렬
    if (a_deck_idx ~= b_deck_idx) then
        return a_deck_idx < b_deck_idx
    end
end

-------------------------------------
-- function condition_cool_time
-------------------------------------
function UI_ReadyScene:condition_cool_time(a,b)
    local a_value = g_friendData:getDragonCoolTimeFromDoid(a['data']['id']) or 0
    local b_value = g_friendData:getDragonCoolTimeFromDoid(b['data']['id']) or 0

    if (a_value == b_value) then
        return nil
    end

    return a_value < b_value
end

-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_ReadyScene:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()
    self.m_sortManagerFriendDragon = SortManager_Dragon()
    
	-- 나중에 정리
	do
		local function cond(a, b)
			return self:condition_deck_idx(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
        self.m_sortManagerFriendDragon:addPreSortType('deck_idx', false, cond)
	end

	if SensitivityHelper:isPassedBattleGiftSeenOnce() then
		-- 최적화에 필요한것이 많음
		local function cond(a, b)
			return self:condition_battle_gift(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('battle_gift', false, cond)
	end

    -- 친구 드래곤인 경우 쿨타임 정렬 추가
    local function cond(a, b)
		return self:condition_cool_time(a, b)
	end
    self.m_sortManagerFriendDragon:addPreSortType('used_time', false, cond)

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    --self.m_uicSortList = uic_sort_list
    

	-- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self.m_sortManagerFriendDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
        self.m_sortManagerDragon:setAllAscending(ascending)
        self.m_sortManagerFriendDragon:setAllAscending(ascending)
        self:apply_dragonSort()
        --self:save_dragonSortInfo()

        vars['sortOrderSprite']:stopAllActions()
        if ascending then
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 180))
        else
            vars['sortOrderSprite']:runAction(cc.RotateTo:create(0.15, 0))
        end
    end)

	-- 최초 정렬
	self:apply_dragonSort()
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_ReadyScene:apply_dragonSort()
    -- 정렬은 본인/친구 테이블 양쪽에 모두 적용
    local table_view_mine = self.m_readySceneSelect.m_tableViewExtMine
    if (table_view_mine== nil) then return end
    self.m_sortManagerDragon:sortExecution(table_view_mine.m_itemList)
    table_view_mine:setDirtyItemList()

    local table_view_friend = self.m_readySceneSelect.m_tableViewExtFriend
    if (table_view_friend== nil) then return end
    self.m_sortManagerFriendDragon:sortExecution(table_view_friend.m_itemList)
    table_view_friend:setDirtyItemList()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadyScene:initUI()
    local vars = self.vars

    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end

    -- 배경
    local attr = TableDrop:getStageAttr(self.m_stageID)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

	-- 콜로세움 에외처리
	if (self.m_stageID == COLOSSEUM_STAGE_ID) then
		vars['friendToggleBtn']:setEnabled(false)
		vars['autoStartOnBtn']:setEnabled(false)

		-- 배경 아무거나 넣어준다
		vars['bgNode']:removeAllChildren()
		local animator = ResHelper:getUIDragonBG('fire', 'idle')
        vars['bgNode']:addChild(animator.m_node)
	end
end

--[[
-------------------------------------
-- function initTab
-------------------------------------
function UI_ReadyScene:initTab()
    local vars = self.vars
    self:addTab('buff', vars['buffInfoBtn'], vars['buffNode'])
    self:addTab('reward', vars['rewardInfoBtn'], vars['rewardListView'])
    self:addTab('monster', vars['mosnterInfoBtn'], vars['monsterListView'])

    self:setTab('reward')
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ReadyScene:onChangeTab(tab, first)
    PARENT.onChangeTab(self, tab, first)

    if (tab == 'buff') then

    elseif (tab == 'reward') then
        if first then
            self:init_rewardListView()
        end

    elseif (tab == 'monster') then
        if first then
            self:init_monsterListView()
        end
    end
end
]]
-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadyScene:initButton()
    local vars = self.vars
	
	-- 드래곤 관리
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)

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
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadyScene:refresh()
    local stage_id = self.m_stageID
    local vars = self.vars

    do -- 스테이지 이름
        local str = g_stageData:getStageName(stage_id)
		if (not str) then
			str = Str('콜로세움 준비')
		end
        self.m_titleStr = str
        g_topUserInfo:setTitleString(str)
    end

    do -- 필요 활동력 표시
        if (stage_id == DEV_STAGE_ID) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local stamina_type, stamina_value = self:getStageStaminaInfo()
            vars['actingPowerLabel']:setString(stamina_value)
        end
    end

    self:refresh_tamer()
	self:refresh_buffInfo()
end

-------------------------------------
-- function refresh_combatPower
-------------------------------------
function UI_ReadyScene:refresh_combatPower()
    local vars = self.vars

    local stage_id = self.m_stageID
	if (stage_id == COLOSSEUM_STAGE_ID) then
		vars['cpNode']:setVisible(false)

	else
		local recommend = TableStageDesc:getRecommendedCombatPower(stage_id)
		vars['cp_Label2']:setString(comma_value(recommend))

		local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label']:setString(comma_value(deck))

	end
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_ReadyScene:refresh_tamer()
    local vars = self.vars

    vars['tamerNode']:removeAllChildren()

	local tamer_res = g_tamerData:getCurrTamerTable('res_sd')
    local animator = MakeAnimator(tamer_res)
	if (animator) then
		animator:setDockPoint(0.5, 0.5)
		animator:setAnchorPoint(0.5, 0.5)
		animator:setScale(2)
		animator:setPosition(0, 50)
		vars['tamerNode']:addChild(animator.m_node)
	end
end

-------------------------------------
-- function refresh_buffInfo
-------------------------------------
function UI_ReadyScene:refresh_buffInfo()
    local vars = self.vars
	
	if (not self.m_readySceneDeck) then
		return
	end

	-- 테이머 버프
	do
		local t_tamer_data = g_tamerData:getTamerServerInfo()
		local skill_mgr = MakeTamerSkillManager(t_tamer_data)
		local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(3)	-- 3번이 패시브
		local tamer_buff = skill_info:getSkillDesc()

		vars['tamerBuffLabel']:setString(tamer_buff)
	end

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
-- function init_battleGift
-------------------------------------
function UI_ReadyScene:init_battleGift()
	-- 대상 드래곤
	local gift_dragon = g_dragonsData:getBattleGiftDragon()

	-- 없다면 탈출
	if (not gift_dragon) then
		return
	end

	-- 이미 덱에 있다면 탈출
	for doid, v in pairs(self.m_readySceneDeck.m_tDeckMap) do
		if (doid == gift_dragon['id']) then
			return
		end
	end
	
	-- 선물 드래곤 본 시간 : 24시간 이내라면 탈출
	if not SensitivityHelper:isPassedBattleGiftSeenOnce() then
		return
	end

	-- UI에 감성 쪼르기 
	if (gift_dragon) then
		local did = gift_dragon['did']
		local animator = AnimatorHelper:makeDragonAnimator_usingDid(did, gift_dragon['evolution'])
		self.vars['giftNode']:addChild(animator.m_node)
		self.vars['giftNode']:setCascadeOpacityEnabled(true)
		self.vars['giftNode']:setScale(0.7)
		animator:setScale(0.4)
		animator:setFlip(true)
		cca.pickMePickMe(animator)
		SensitivityHelper:doRepeatBubbleText(self.vars['giftNode'], did, nil, 'party_in_induce')

		-- 현재 본 시간을 저장
		g_localData:applyLocalData(Timer:getServerTime(), 'battle_gift_dragon_seen_at')
	end
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene:checkBattleGift(cb_func)
    -- 대상 드래곤
	local gift_dragon = g_dragonsData:getBattleGiftDragon()
	
	-- 없다면 콜백 호출하고 탈출
	if (not gift_dragon) then
		if (cb_func) then
			cb_func()
		end
		return
	end
	
	-- 이미 덱에 있다면 선물을 요청한다~~
	local has_gift = false
	for doid, v in pairs(self.m_readySceneDeck.m_tDeckMap) do
		if (doid == gift_dragon['id']) then
			has_gift = true
			break
		end
	end

	-- 게임 스타트
	if (has_gift) then
		g_dragonsData:request_battleGift(gift_dragon['did'], cb_func)
	else
		if (cb_func) then
			cb_func()
		end
	end
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_ReadyScene:click_backBtn()
	self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_ReadyScene:click_exitBtn()
    local function next_func()
        self:close()

		-- 들어온 경로에 따라 sound가 다름
		local game_mode = g_stageData:getGameMode(self.m_stageID)
		if (game_mode == GAME_MODE_ADVENTURE) then
			SoundMgr:playBGM('bgm_dungeon_ready')
		else
			SoundMgr:playBGM('bgm_lobby')
		end
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadyScene:click_dragonCard(t_dragon_data, skip_sort, idx)
    self.m_readySceneDeck:click_dragonCard(t_dragon_data, skip_sort, idx)
end

-------------------------------------
-- function click_manageBtn
-- @breif 드래곤 관리
-------------------------------------
function UI_ReadyScene:click_manageBtn()
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
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_autoBtn()
    local stage_id = self.m_stageID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list = g_dragonsData:getDragonsList()

    local helper = DragonAutoSetHelper(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    l_auto_deck = UI_ReadyScene_Deck:convertSimpleDeck(l_auto_deck)

    -- 1. 덱을 비움
    local skip_sort = true
    self.m_readySceneDeck:clear_deck(skip_sort)

    -- 2. 덱을 채움
    for i,t_dragon_data in pairs(l_auto_deck) do
        self.m_readySceneDeck:setFocusDeckSlotEffect(i)
        local skip_sort = true
        self:click_dragonCard(t_dragon_data, skip_sort, i)
    end

    -- 정렬
    self:apply_dragonSort()
end

-------------------------------------
-- function click_removeBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_removeBtn()
    self.m_readySceneDeck:clear_deck()
end

-------------------------------------
-- function click_teamBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_teamBtn(deck_name)
    local function next_func()
        self:changeTeam(deck_name)
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function changeTeam
-- @breif
-------------------------------------
function UI_ReadyScene:changeTeam(deck_name)
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
function UI_ReadyScene:click_startBtn()
    local stage_id = self.m_stageID

    -- 개발 스테이지
    if (stage_id == DEV_STAGE_ID) then
        local scene = SceneGame(nil, stage_id, 'stage_dev', true)
        scene:runScene()
        return
    end
	
	-- 콜로세움은 따로 빼서 처리
	if (stage_id == COLOSSEUM_STAGE_ID) then
		self:startColosseum()
		return
	end

    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed('최소 1명 이상은 출전시켜야 합니다.')

    elseif (not g_stageData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, '{@BLACK}' .. Str('이전 스테이지를 클리어하세요.'))

    -- 날개 소모
    elseif (not g_staminasData:checkStageStamina(stage_id)) then
        g_staminasData:staminaCharge(stage_id)
                    
    else
        local check_deck
        local check_dragon_inven
        local check_item_inven
		local check_battle_gift
        local start_game

        -- 덱 변경 유무 확인 후 저장
        check_deck = function()
            self:checkChangeDeck(check_dragon_inven)
        end

        -- 드래곤 인벤토리 확인(최대 갯수 초과 시 획득 못함)
        check_dragon_inven = function()
            local function manage_func()
                self:click_manageBtn()
            end
            g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
        end

        -- 아이템 인벤토리 확인(최대 갯수 초과 시 획득 못함)
        check_item_inven = function()
            local function manage_func()
                UI_Inventory()
            end
            g_inventoryData:checkMaximumItems(check_battle_gift, manage_func)
        end

		-- 아이템 인벤토리 확인(최대 갯수 초과 시 획득 못함)
        check_battle_gift = function()
            self:checkBattleGift(start_game)
        end

        -- 게임 시작
        start_game = function()
            self:networkGameStart()
        end
        
        check_deck()
    end
end

-------------------------------------
-- function startColosseum
-- @breif 콜로세움 전용
-------------------------------------
function UI_ReadyScene:startColosseum()
    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed('최소 1명 이상은 출전시켜야 합니다.')
        return
    end

    -- 날개 소모
    if (not g_staminasData:checkStageStamina(COLOSSEUM_STAGE_ID)) then
        self:askCashPlay()
        return
    end
        
    local function next_func()
        local is_cash = false

        local function cb(ret)
			local scene = SceneGameColosseum()
			scene:runScene()
		end

		g_colosseumData:request_colosseumStart(is_cash, cb)
    end

    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function askCashPlay
-- @breif 콜로세움 전용
-------------------------------------
function UI_ReadyScene:askCashPlay()
    local function ok_btn_cb()
        local function next_func()
            local is_cash = true
            self:networkGameStart(is_cash)
        end

        self:checkChangeDeck(next_func)
    end

    local msg = Str('입장권이 부족합니다.\n{@impossible}다이아몬드 1개{@default}를 사용해 진행하시겠습니까?')
    UI_ConfirmPopup('cash', 1, msg, ok_btn_cb)
end

-------------------------------------
-- function click_autoStartOnBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_autoStartOnBtn()
    local ui = UI_AutoPlaySettingPopup()
    ui:setCloseCB(function() self.vars['autoStartOnBtn']:setChecked(g_autoPlaySetting:isAutoPlay()) end)
end

-------------------------------------
-- function click_friendBtn
-- @breif 임시 삭제되었음
-------------------------------------
function UI_ReadyScene:click_friendBtn()
    local ui = UI_FriendSelectPopup()
    ui:setCloseCB(function()
        local check = (g_friendData.m_selectedShareFriendData ~= nil)
        self.vars['friendBtn']:setChecked(check)
    end)
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_fomationBtn()
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationPopup(curr_formation_type)
	
	-- 종료하면서 선택된 formation을 m_readySceneDeck으로 전달
	local function close_cb(formation_type)
		self.m_readySceneDeck:setFormation(formation_type)
		self:refresh_buffInfo()
	end
	ui:setCloseCB(close_cb)
end

-------------------------------------
-- function click_tamerBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_tamerBtn()
    local ui = UI_TamerManagePopup()
	ui:setCloseCB(function() 
		self:refresh_tamer()
		self:refresh_buffInfo()
	end)
end

-------------------------------------
-- function click_leaderBtn
-- @breif
-------------------------------------
function UI_ReadyScene:click_leaderBtn()
	local l_pos_list = self.m_readySceneDeck:getRotatedPosList()
	local l_doid = self.m_readySceneDeck.m_lDeckList
	local leader_idx = self.m_readySceneDeck.m_currLeader

	if (table.count(l_doid) == 0) then
		UIManager:toastNotificationRed('리더로 설정할 드래곤이 없습니다.')
		return
	end

	local ui = UI_ReadyScene_LeaderPopup(l_pos_list, l_doid, leader_idx)
	ui:setCloseCB(function() 
		self.m_readySceneDeck.m_currLeader = ui.m_newLeader
		self:refresh_buffInfo()
	end)
end

-------------------------------------
-- function replaceGameScene
-- @breif
-------------------------------------
function UI_ReadyScene:replaceGameScene(game_key)
    local stage_id = self.m_stageID

    local stage_name = 'stage_' .. stage_id
    local scene = SceneGame(game_key, stage_id, stage_name, false)
    scene:runScene()
end

-------------------------------------
-- function networkGameStart
-- @breif
-------------------------------------
function UI_ReadyScene:networkGameStart()
    local function finish_cb(game_key)
        self:replaceGameScene(game_key)
    end

    local deck_name = g_deckData:getSelectedDeckName()
    local combat_power = self.m_readySceneDeck:getDeckCombatPower()
    g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_ReadyScene:refresh_dragonCard(doid)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid)
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadyScene:checkChangeDeck(next_func)
    return self.m_readySceneDeck:checkChangeDeck(next_func)
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ReadyScene:getDragonCount()
    return self.m_readySceneDeck:getDragonCount()
end
--[[
-------------------------------------
-- function init_monsterListView
-------------------------------------
function UI_ReadyScene:init_monsterListView()
    local node = self.vars['monsterListView']
    node:removeAllChildren()

    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id로 몬스터 아이콘 리스트
    local stage_id = self.m_stageID
    local l_item_list = g_stageData:getMonsterIDList(stage_id)

    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(UI_MonsterCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end

-------------------------------------
-- function init_rewardListView
-- @brief 획득 가능 보상
-------------------------------------
function UI_ReadyScene:init_rewardListView()
    local node = self.vars['rewardListView']
    node:removeAllChildren()


    -- 생성 콜백
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id로 드랍정보를 얻어옴
    local stage_id = self.m_stageID
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()


    -- 테이블 뷰 인스턴스 생성
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(UI_ItemCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- 리스트 내 개수 부족 시 가운데 정렬
end
]]
-------------------------------------
-- function getStageStaminaInfo
-- @brief stage_id에 해당하는 필요 스태미너 타입, 갯수 리턴
-------------------------------------
function UI_ReadyScene:getStageStaminaInfo()
    local stage_id = self.m_stageID
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    -- 'stamina' 추후에 타입별 stamina 사용 예정
    local cost_type, cost_value
	if (stage_id == COLOSSEUM_STAGE_ID) then
		cost_type = 'pvp'
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
function UI_ReadyScene:close()
    UI.close(self)
end

--@CHECK
UI:checkCompileError(UI_ReadyScene)
