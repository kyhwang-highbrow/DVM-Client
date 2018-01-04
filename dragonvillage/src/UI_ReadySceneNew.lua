local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable()) --ITabUI:getCloneTable())

-------------------------------------
-- class UI_ReadySceneNew
-------------------------------------
UI_ReadySceneNew = class(PARENT,{
        m_stageID = 'number',
        m_subInfo = 'string',
        m_stageAttr = 'attr',

        -- UI_ReadyScene_Select ���� ����
        m_readySceneSelect = 'UI_ReadyScene_Select',

        -- UI_ReadyScene_Deck ���� ����
        m_readySceneDeck = 'UI_ReadyScene_Deck',

        -- ���� �����
		m_sortManagerDragon = '',
        m_sortManagerFriendDragon = '',
        m_uicSortList = 'UIC_SortList',

        m_bWithFriend = 'boolean'
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew:init(stage_id, with_friend, sub_info)
    -- spine ĳ�� ����
    SpineCacheManager:getInstance():purgeSpineCacheData()

    self.m_subInfo = sub_info
	if (not stage_id) then
		stage_id = COLOSSEUM_STAGE_ID
	end
    self:init_MemberVariable(stage_id)

    self.m_bWithFriend = with_friend or false

    local vars = self:load('battle_ready_new.ui')
    UIManager:open(self, UIManager.SCENE)

    -- ����� ���Խ� ���õ� ģ������ �ʱ�ȭ
    g_friendData:delSettedFriendDragon()

    -- �� ��ȯ ȿ��
    self:sceneFadeInAction()

    -- backkey ����
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
	end)

    self:refresh()

	self:init_sortMgr()

    -- �ڵ� ���� off
    if (stage_id == COLOSSEUM_STAGE_ID) then
        g_autoPlaySetting:setMode(AUTO_COLOSSEUM)
    else
        g_autoPlaySetting:setMode(AUTO_NORMAL)
    end
    g_autoPlaySetting:setAutoPlay(false)

    -- ���ϸ��� ���̾� Ǯ�˾�
    local game_mode = g_stageData:getGameMode(self.m_stageID)
    if (game_mode == GAME_MODE_ADVENTURE) then
        g_fullPopupManager:show(FULL_POPUP_TYPE.AUTO_PICK)
    end
end

-------------------------------------
-- function initParentVariable
-- @brief �ڽ� Ŭ�������� �ݵ�� ������ ��
-------------------------------------
function UI_ReadySceneNew:initParentVariable()
    -- ITopUserInfo_EventListener�� �ɹ� ������ ����
    self.m_uiName = 'UI_ReadySceneNew'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh���� ���������� ����
    self.m_bUseExitBtn = true

    -- ����� Ÿ�� ����
    self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)

    
	-- ���� ��ο� ���� sound�� �ٸ�
	local game_mode = g_stageData:getGameMode(self.m_stageID)
	if (game_mode == GAME_MODE_ADVENTURE) then
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

    local game_mode = g_stageData:getGameMode(self.m_stageID)
	if (game_mode == GAME_MODE_SECRET_DUNGEON) then
        -- �ο� ������ ����� �ش� �巡���� �Ӽ��� �������� �Ӽ����� ����
        local t_dungeon_info = g_secretDungeonData:getSelectedSecretDungeonInfo()
        if (t_dungeon_info) then
            local did = t_dungeon_info['dragon']
            
            self.m_stageAttr = TableDragon():getValue(did, 'attr')
        end
    else
	    self.m_stageAttr = TableDrop():getValue(stage_id, 'attr')
    end
end

-------------------------------------
-- function checkDeckProper
-- @brief �ش� ��忡 �´� ������ üũ�ϰ� �ƴ϶�� �ٲ��ش�.
-------------------------------------
function UI_ReadySceneNew:checkDeckProper()

    -- �ݷμ��� ���� ó��
    if (self.m_stageID == COLOSSEUM_STAGE_ID) then
        if (self.m_subInfo == 'atk') then
            g_deckData:setSelectedDeck('pvp_atk')
        elseif (self.m_subInfo == 'def') then
            g_deckData:setSelectedDeck('pvp_def')
        end
        return
    end

    -- ģ������ ���� ó��
    if (self.m_stageID == FRIEND_MATCH_STAGE_ID) then
        if (self.m_subInfo == 'fatk') then
            g_deckData:setSelectedDeck('fpvp_atk')
        end
        return
    end

	local curr_mode = TableDrop():getValue(self.m_stageID, 'mode')

    -- Ŭ�� ���� ���� ó�� 
    if (curr_mode == 'clan') then
        local deck_name = g_clanRaidData:getDeckName()
        if (deck_name) then
            g_deckData:setSelectedDeck(deck_name)
            return
        end
    end

    -- ������ ž�� ��� ����� ž�� STAGE ID ���� ���̹Ƿ� ������ �ٽ� �޾ƿ�
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
-- @breif ���� ������ �巡���� ���� �켱������ ���
-------------------------------------
function UI_ReadySceneNew:condition_deck_idx(a, b)
    local a_deck_idx = self.m_readySceneDeck.m_tDeckMap[a['data']['id']] or nil
    local b_deck_idx = self.m_readySceneDeck.m_tDeckMap[b['data']['id']] or nil
	 
    -- �� �� ���� ������ ��� �쿭�� ������ ����
    if (a_deck_idx and b_deck_idx) then
        return nil

    -- A�巡�︸ ���� ������ ���
    elseif a_deck_idx then
        return true

    -- B�巡�︸ ���� ������ ���
    elseif b_deck_idx then
        return false

    -- �� �� ���� �������� ���� ���
    else
        return nil
    end
end

-------------------------------------
-- function condition_cool_time
-------------------------------------
function UI_ReadySceneNew:condition_cool_time(a,b)
    -- �Ѵ� ��밡���� �巡���̶�� ���� ���ķ� (�����ð��� ��� ����Ǳ� ������ �ð������� ���ϸ� �ȵ�)
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

	-- ���� �Ŵ��� ����
    self.m_sortManagerDragon = SortManager_Dragon()
    self.m_sortManagerFriendDragon = SortManager_Dragon()
    
	-- ���߿� ����
	do
		local function cond(a, b)
			return self:condition_deck_idx(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
        self.m_sortManagerFriendDragon:addPreSortType('deck_idx', false, cond)
	end

    -- ģ�� �巡���� ��� ��Ÿ�� ���� �߰�
    local function cond(a, b)
		return self:condition_cool_time(a, b)
	end
    self.m_sortManagerFriendDragon:addPreSortType('used_time', false, cond)

    -- ���� UI ����
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    

	-- ��ư�� ���� ������ ����Ǿ��� ���
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self.m_sortManagerFriendDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- ��������/�������� ��ư
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

    -- ���̺굥���Ϳ� �ִ� ���� ���� ����
    self:apply_dragonSort_saveData()
end

-------------------------------------
-- function apply_dragonSort
-- @brief ���̺� �信 ���� ����
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
-- @brief ���ο� ���� ������ ���̺� �����Ϳ� ����
-------------------------------------
function UI_ReadySceneNew:save_dragonSortInfo()
    g_localData:lockSaveData()

    -- ���� ���� ����
    local sort_order = self.m_sortManagerDragon.m_lSortOrder
    g_localData:applyLocalData(sort_order, 'dragon_sort_fight', 'order')

    -- ��������, �������� ����
    local ascending = self.m_sortManagerDragon.m_defaultSortAscending
    g_localData:applyLocalData(ascending, 'dragon_sort_fight', 'ascending')

    g_localData:unlockSaveData()
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief ���̺굥���Ϳ� �ִ� ���� ���� ����
-------------------------------------
function UI_ReadySceneNew:apply_dragonSort_saveData()
    local l_order = g_localData:get('dragon_sort_fight', 'order')
    local ascending = g_localData:get('dragon_sort_fight', 'ascending')

    local sort_type
    for i=#l_order, 1, -1 do
        sort_type = l_order[i]
        self.m_sortManagerDragon:pushSortOrder(sort_type)
    end
    self.m_sortManagerDragon:setAllAscending(ascending)

    self.m_uicSortList:setSelectSortType(sort_type)

    do -- ��������, �������� ������
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

    do -- ���������� �ش��ϴ� ���׹̳� ������ ����
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end

    -- ���
    local attr = TableStageData:getStageAttr(self.m_stageID)
    if self:checkVarsKey('bgNode', attr) then
        vars['bgNode']:removeAllChildren()
        local animator = ResHelper:getUIDragonBG(attr, 'idle')
        vars['bgNode']:addChild(animator.m_node)
    end

	-- �ݷμ��� ����ó��
	if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID) then
		vars['friendToggleBtn']:setVisible(false)
		vars['autoStartOnBtn']:setVisible(false)

		-- ��� �ƹ��ų� �־��ش�
		vars['bgNode']:removeAllChildren()
		local animator = ResHelper:getUIDragonBG('fire', 'idle')
        vars['bgNode']:addChild(animator.m_node)
	end

    -- Ŭ������
    local game_mode = g_stageData:getGameMode(self.m_stageID)
    if (game_mode == GAME_MODE_CLAN_RAID) then
        vars['friendToggleBtn']:setVisible(false)
		vars['autoStartOnBtn']:setVisible(false)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadySceneNew:initButton()
    local vars = self.vars
	
	-- �巡�� ����
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)

	-- ��õ ��ġ, ��� ����
    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)

	-- ���� ����
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)
	vars['startBtn']:setClickSoundName('ui_game_start')

	-- ���� ����
    vars['autoStartOnBtn'] = UIC_CheckBox(vars['autoStartOnBtn'].m_node, vars['autoStartOnSprite'], false)
    vars['autoStartOnBtn']:setManualMode(true)
    vars['autoStartOnBtn']:registerScriptTapHandler(function() self:click_autoStartOnBtn() end)

	-- ���̸� ����
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['tamerBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)

	-- ���� ����
	vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)

	-- ���� ����
    vars['fomationBtn']:registerScriptTapHandler(function() self:click_fomationBtn() end)


    -- �ݷμ����� ���
    if (self.m_stageID == COLOSSEUM_STAGE_ID or self.m_stageID == FRIEND_MATCH_STAGE_ID) then
        vars['actingPowerNode']:setVisible(false)
        vars['startBtn']:registerScriptTapHandler(function() self:click_backBtn() end)
        vars['startBtnLabel']:setPositionX(0)
        vars['startBtnLabel']:setString(Str('���� �Ϸ�'))
    end
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadySceneNew:refresh()
    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)
    local vars = self.vars

    do -- �������� �̸�
        local str = g_stageData:getStageName(stage_id)
        if (stage_id == COLOSSEUM_STAGE_ID) then
            if (self.m_subInfo == 'atk') then
                str = Str('�ݷμ��� ����')
            elseif (self.m_subInfo == 'def') then
                str = Str('�ݷμ��� ���')
            else
                str = Str('�ݷμ��� �غ�')
            end

	    elseif (stage_id == FRIEND_MATCH_STAGE_ID) then
            str = Str('ģ������ ����')
        end
        self.m_titleStr = str
        g_topUserInfo:setTitleString(str)
    end

    do -- �ʿ� Ȱ���� ǥ��
        if (stage_id == DEV_STAGE_ID) then
            self.vars['actingPowerLabel']:setString('0')
        else
            local stamina_type, stamina_value = self:getStageStaminaInfo()
            vars['actingPowerLabel']:setString(stamina_value)
        end
    end

    -- ���� �Һ� Ȱ���� ��Ÿ�� ����
    if (game_mode == GAME_MODE_ADVENTURE) then
        local active, key, str = g_hotTimeData:getActiveHotTimeInfo_stamina()
        if active then
            local stamina_type, stamina_value = self:getStageStaminaInfo()
            local cost_value = math_floor(stamina_value / 2)
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
    end


    self:refresh_tamer()
	self:refresh_buffInfo()
end

-------------------------------------
-- function refresh_combatPower
-------------------------------------
function UI_ReadySceneNew:refresh_combatPower()
    local vars = self.vars

    local stage_id = self.m_stageID
    local game_mode = g_stageData:getGameMode(stage_id)

	if (stage_id == COLOSSEUM_STAGE_ID or stage_id == FRIEND_MATCH_STAGE_ID or game_mode == GAME_MODE_CLAN_RAID) then
		vars['cp_Label2']:setString('')

        local deck = self.m_readySceneDeck:getDeckCombatPower()
		vars['cp_Label']:setString(comma_value( math.floor(deck + 0.5) ))

	else
		local recommend = TableStageData():getRecommendedCombatPower(stage_id, game_mode)
        vars['cp_Label2']:setString(comma_value( math.floor(recommend + 0.5) ))

		local deck = self.m_readySceneDeck:getDeckCombatPower()

        -- ���̸�
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

		vars['cp_Label']:setString(comma_value( math.floor(deck + 0.5) ))

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

    -- �ڽ�Ƭ ����
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

    -- ���̸� ����
    self:refresh_buffInfo_TamerBuff()

	-- ���� ����
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
				leader_buff = Str('���� ���� ����')
			end
		else
			leader_buff = Str('���� ���� ����')
		end
		vars['leaderBuffLabel']:setString(leader_buff)
	end

	-- ���� ����
	do
		local l_formation = g_formationData:getFormationInfoList()
		local curr_formation = self.m_readySceneDeck.m_currFormation
		local formation_data = l_formation[curr_formation]
		local formation_buff = TableFormation():getFormatioDesc(formation_data['formation'])

		vars['formationBuffLabel']:setString(formation_buff)
	end
end

-------------------------------------
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_ReadySceneNew:refresh_buffInfo_TamerBuff()
    local vars = self.vars

    -- ���̸� ����
    local tamer_id = self:getCurrTamerID()
	local t_tamer_data = g_tamerData:getTamerServerInfo(tamer_id)
	local skill_mgr = MakeTamerSkillManager(t_tamer_data)
	local skill_info = skill_mgr:getSkillIndivisualInfo_usingIdx(2)	-- 2���� �нú�
	local tamer_buff = skill_info:getSkillDesc()

	vars['tamerBuffLabel']:setString(tamer_buff)
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
-- @breif �巡�� ����
-------------------------------------
function UI_ReadySceneNew:click_manageBtn()
    local function next_func()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            local function func()
                self:refresh()
                self.m_readySceneSelect:init_dragonTableView()
                self.m_readySceneDeck:init_deck()

                do -- ���� �����
					self:apply_dragonSort()
                end
            end
            self:sceneFadeInAction(func)
        end
        ui:setCloseCB(close_cb)
    end
    
    -- �� ���� �� �̵�
    self:checkChangeDeck(next_func)
end

-------------------------------------
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_autoBtn()
    local stage_id = self.m_stageID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list

    local game_mode = g_stageData:getGameMode(self.m_stageID)
    if (game_mode == GAME_MODE_ANCIENT_TOWER) then
        local attr = g_attrTowerData:getSelAttr()
        -- ������ ž (���� �Ӽ� �巡�︸ �޾ƿ�)
        if (attr) then
            l_dragon_list = g_dragonsData:getDragonsListWithAttr(attr)

        -- ����� ž
        else
            l_dragon_list = g_dragonsData:getDragonsList()
        end
    else
        l_dragon_list = g_dragonsData:getDragonsList()
    end

    local helper = DragonAutoSetHelper(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    l_auto_deck = UI_ReadySceneNew_Deck:convertSimpleDeck(l_auto_deck)

    -- 1. ���� ���
    local skip_sort = true
    self.m_readySceneDeck:clear_deck(skip_sort)

    -- 2. ���� ä��
    for i,t_dragon_data in pairs(l_auto_deck) do
        self.m_readySceneDeck:setFocusDeckSlotEffect(i)
        local skip_sort = true
        self:click_dragonCard(t_dragon_data, skip_sort, i)
    end

    -- ģ�� �巡�� ����
    g_friendData:delSettedFriendDragon()

    -- ����
    self:apply_dragonSort()
end

-------------------------------------
-- function click_removeBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_removeBtn()
    -- ģ�� �巡�� ����
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
    -- ��ῡ�� "����" �� �̶�� ǥ�õ� �巡�� ����
    for i,v in pairs(self.m_readySceneDeck.m_lDeckList) do
        local doid = v
        local table_view = self.m_readySceneSelect:getTableView()
        local item = table_view:getItem(doid)
        if (item and item['ui']) then
            item['ui']:setReadySpriteVisible(false)
        end
    end

    -- ���õ� �� ����
    g_deckData:setSelectedDeck(deck_name)

    -- ����� ������ �ٽ� �ʱ�ȭ
    self.m_readySceneDeck:init_deck()

    -- ��� ����
    self:apply_dragonSort()
end

-------------------------------------
-- function click_startBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_startBtn()
    local stage_id = self.m_stageID

    -- ���� ��������
    if (stage_id == DEV_STAGE_ID) then
        self:checkChangeDeck(function()
            local scene = SceneGame(nil, stage_id, 'stage_dev', true)
            scene:runScene()
        end)
        return
    elseif (stage_id == CLAN_RAID_STAGE_ID) then
        self:checkChangeDeck(function()
            local scene = SceneGameClanRaid(nil, CLAN_RAID_STAGE_ID, 'stage_clanraid')
            scene:runScene()
        end)
        return
    end

    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed('�ּ� 1�� �̻��� �������Ѿ� �մϴ�.')

    elseif (not g_stageData:isOpenStage(stage_id)) then
        MakeSimplePopup(POPUP_TYPE.OK, Str('���� ���������� Ŭ�����ϼ���.'))

    -- ���� �Ҹ�
    elseif (not g_staminasData:checkStageStamina(stage_id)) then
        g_staminasData:staminaCharge(stage_id)
                    
    else
        local check_deck
        local check_dragon_inven
        local check_item_inven
        local check_attr_tower
        local start_game

        -- �� ���� ���� Ȯ�� �� ����
        check_deck = function()
            self:checkChangeDeck(check_dragon_inven)
        end

        -- �巡�� ���� Ȯ��(�ִ� ���� �ʰ� �� ȹ�� ����)
        check_dragon_inven = function()
            local function manage_func()
                self:click_manageBtn()
            end
            g_dragonsData:checkMaximumDragons(check_item_inven, manage_func)
        end

        -- ������ ���� Ȯ��(�ִ� ���� �ʰ� �� ȹ�� ����)
        check_item_inven = function()
            local function manage_func()
                UI_Inventory()
            end
            g_inventoryData:checkMaximumItems(check_attr_tower, manage_func)
        end

        -- ������ ž �Ӽ� �巡�� Ȯ��
        check_attr_tower = function()
            if (g_ancientTowerData:isAncientTowerStage(stage_id)) then
                local l_deck = self.m_readySceneDeck.m_lDeckList
                if (g_attrTowerData:checkDragonAttr(l_deck)) then
                    start_game()
                end
            else
                start_game()
            end
        end

        -- ���� ����
        start_game = function()
            self:networkGameStart()
        end
        
        check_deck()
    end
end

-------------------------------------
-- function askCashPlay
-- @breif �ݷμ��� ����
-------------------------------------
function UI_ReadySceneNew:askCashPlay()
    local function ok_btn_cb()
        local function next_func()
            local is_cash = true
            self:networkGameStart(is_cash)
        end

        self:checkChangeDeck(next_func)
    end

    local msg = Str('������� �����մϴ�.\n{@impossible}���̾Ƹ�� 1��{@default}�� ����� �����Ͻðڽ��ϱ�?')
    UI_ConfirmPopup('cash', 1, msg, ok_btn_cb)
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

    -- �ٷ� ����
    if (is_auto) then
        g_autoPlaySetting:setAutoPlay(false)
        refresh_btn()
    else
		local game_mode = g_stageData:getGameMode(self.m_stageID)
        local ui = UI_AutoPlaySettingPopup(game_mode)
        ui:setCloseCB(refresh_btn)
    end
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_ReadySceneNew:click_fomationBtn()
	-- m_readySceneDeck���� ���� formation �޾ƿ� ����
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationPopup(curr_formation_type)
	
	-- �����ϸ鼭 ���õ� formation�� m_readySceneDeck���� ����
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

	-- �������� �ִ� �巡�� üũ
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
    -- ������ �ι� ���� �ʵ��� �ϱ� ����
    UI_BlockPopup()

    local stage_id = self.m_stageID
    local stage_name = 'stage_' .. stage_id
    local game_mode = g_stageData:getGameMode(stage_id)
    local scene

    if (game_mode == GAME_MODE_CLAN_RAID) then
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
    g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)
end

-------------------------------------
-- function refresh_dragonCard
-- @brief �������ο� ���� ī�� ����
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
--[[
-------------------------------------
-- function init_monsterListView
-------------------------------------
function UI_ReadySceneNew:init_monsterListView()
    local node = self.vars['monsterListView']
    node:removeAllChildren()

    -- ���� �ݹ�
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id�� ���� ������ ����Ʈ
    local stage_id = self.m_stageID
    local l_item_list = g_stageData:getMonsterIDList(stage_id)

    -- ���̺� �� �ν��Ͻ� ����
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(UI_MonsterCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- ����Ʈ �� ���� ���� �� ��� ����
end

-------------------------------------
-- function init_rewardListView
-- @brief ȹ�� ���� ����
-------------------------------------
function UI_ReadySceneNew:init_rewardListView()
    local node = self.vars['rewardListView']
    node:removeAllChildren()


    -- ���� �ݹ�
    local function create_func(ui, data)
        ui.root:setScale(0.6)
    end

    -- stage_id�� ��������� ����
    local stage_id = self.m_stageID
    local drop_helper = DropHelper(stage_id)
    local l_item_list = drop_helper:getDisplayItemList()


    -- ���̺� �� �ν��Ͻ� ����
    local table_view = UIC_TableView(node)
    table_view.m_defaultCellSize = cc.size(94, 98)
    table_view:setCellUIClass(UI_ItemCard, create_func)
    table_view:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    table_view:setItemList(l_item_list)
    table_view.m_bAlignCenterInInsufficient = true -- ����Ʈ �� ���� ���� �� ��� ����
end
]]
-------------------------------------
-- function getStageStaminaInfo
-- @brief stage_id�� �ش��ϴ� �ʿ� ���¹̳� Ÿ��, ���� ����
-------------------------------------
function UI_ReadySceneNew:getStageStaminaInfo()
    local stage_id = self.m_stageID
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    -- 'stamina' ���Ŀ� Ÿ�Ժ� stamina ��� ����
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
