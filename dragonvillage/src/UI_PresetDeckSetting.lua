local PARENT = class(UI, ITopUserInfo_EventListener:getCloneTable()) 
-------------------------------------
-- class UI_PresetDeckSetting
-------------------------------------
UI_PresetDeckSetting = class(PARENT,{
        m_gameMode = 'number', 
        m_presetDeck = 'StructPresetDeck',
        -- UI_ReadyScene_Select 관련 변수
        m_readySceneSelect = 'UI_ReadySceneNew_Select',
        -- UI_ReadyScene_Deck 관련 변수
        m_readySceneDeck = 'UI_ReadySceneNew_Deck',

        m_bArena = 'boolean',
        -- 정렬 도우미
        m_sortManagerDragon = '',
        m_uicSortList = 'UIC_SortList',

        m_successCb = '',


    })

-------------------------------------
-- function init
-------------------------------------
function UI_PresetDeckSetting:init(struct_preset_deck, success_cb)
    self.m_uiName = 'UI_PresetDeckSetting'
    self.m_gameMode = 0
    self.m_bArena = false
    self.m_presetDeck = struct_preset_deck
    self.m_successCb = success_cb
    self:load('preset_deck_set.ui')
    UIManager:open(self, UIManager.SCENE)

    -- 씬 전환 효과
    self:sceneFadeInAction()

    -- backkey 지정
    g_currScene:pushBackKeyListener(self, function() self:click_backBtn() end, 'UI_PresetDeckSetting')

    -- @UI_ACTION
    --self:addAction(vars['rootNode'], UI_ACTION_TYPE_LEFT, 0, 0.2)
    self:doActionReset()
    self:doAction(nil, false)

    self:initUI()
    self:initButton()
    self:refresh()

    self:init_sortMgr()
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_PresetDeckSetting:initParentVariable()
    self.m_titleStr = Str('덱 프리셋')
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckSetting:initUI()
    local vars = self.vars

    self.m_readySceneSelect = UI_PresetDeckSetting_Select(self)
    self.m_readySceneDeck = UI_PresetDeckSetting_Deck(self)
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckSetting:initButton()
    local vars = self.vars
    -- 드래곤 관리
    vars['manageBtn']:registerScriptTapHandler(function() self:click_manageBtn() end)
	-- 추천 배치, 모두 해제
    vars['autoBtn']:registerScriptTapHandler(function() self:click_autoBtn() end)
    vars['removeBtn']:registerScriptTapHandler(function() self:click_removeBtn() end)
    -- 룬 보기
    vars['runeBtn']:registerScriptTapHandler(function() self:click_runeBtn() end)
    -- 테이머 변경
    vars['tamerBtn']:registerScriptTapHandler(function() self:click_tamerBtn() end)
    vars['tamerBtn']:setActionType(UIC_Button.ACTION_TYPE_WITHOUT_SCAILING)
    -- 리더 변경
    vars['leaderBtn']:registerScriptTapHandler(function() self:click_leaderBtn() end)
    -- 진형 관리
    vars['fomationBtn']:registerScriptTapHandler(function() self:click_fomationBtn() end)
    -- 속성 도움말
    vars['attrInfoBtn']:registerScriptTapHandler(function() self:click_attrInfoBtn() end)
    -- 적용
    vars['startBtn']:registerScriptTapHandler(function() self:click_startBtn() end)

    
end

-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_PresetDeckSetting:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon()

    do
        local function cond(a, b) return self:condition_deck_idx(a, b) end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
    end

    -- 정렬 UI 생성
    local vars = self.vars
    local uic_sort_list = MakeUICSortList_dragonManage(vars['sortBtn'], vars['sortLabel'], UIC_SORT_LIST_TOP_TO_BOT)
    self.m_uicSortList = uic_sort_list
    
	-- 버튼을 통해 정렬이 변경되었을 경우
    local function sort_change_cb(sort_type)
        self.m_sortManagerDragon:pushSortOrder(sort_type)
        self:apply_dragonSort()
        self:save_dragonSortInfo()
    end
    uic_sort_list:setSortChangeCB(sort_change_cb)

    -- 오름차순/내림차순 버튼
    vars['sortOrderBtn']:registerScriptTapHandler(function()
        local ascending = (not self.m_sortManagerDragon.m_defaultSortAscending)
        self.m_sortManagerDragon:setAllAscending(ascending)
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
-- function condition_deck_idx
-- @breif 덱에 설정된 드래곤을 정렬 우선순위로 사용
-------------------------------------
function UI_PresetDeckSetting:condition_deck_idx(a, b)
    local a_deck_idx = self.m_readySceneDeck:getSettedDragonDeckIdx(a['data']['id'])
    local b_deck_idx = self.m_readySceneDeck:getSettedDragonDeckIdx(b['data']['id'])
    return a_deck_idx > b_deck_idx
end

-------------------------------------
-- function apply_dragonSort
-- @brief 테이블 뷰에 정렬 적용
-------------------------------------
function UI_PresetDeckSetting:apply_dragonSort()
    local sort_func 
    sort_func = function(table_view, friend)
        if (table_view == nil) then return end
        local target_sort_mgr = self.m_sortManagerDragon
        target_sort_mgr:sortExecution(table_view.m_itemList)
        table_view:setDirtyItemList()
    end
    
    sort_func(self.m_readySceneSelect.m_tableViewExtMine)
end

-------------------------------------
-- function apply_dragonSort_saveData
-- @brief 세이브데이터에 있는 정렬 순서 적용
-------------------------------------
function UI_PresetDeckSetting:apply_dragonSort_saveData()
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
-- function save_dragonSortInfo
-- @brief 새로운 정렬 설정을 세이브 데이터에 적용
-------------------------------------
function UI_PresetDeckSetting:save_dragonSortInfo()
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
-- function getCurrPresetDeck
-------------------------------------
function UI_PresetDeckSetting:getCurrPresetDeck()
    return self.m_presetDeck
end

-------------------------------------
-- function getLeaderBuffDesc
-------------------------------------
function UI_PresetDeckSetting:getLeaderBuffDesc()
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
-- function refresh
-------------------------------------
function UI_PresetDeckSetting:refresh()
    self:refresh_tamer()
	self:refresh_buffInfo()
    self:refresh_combatPower()
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_PresetDeckSetting:refresh_dragonCard(doid, is_friend)
    if (not self.m_readySceneDeck) then
        return
    end

    self.m_readySceneDeck:refresh_dragonCard(doid, is_friend)
end

-------------------------------------
-- function refresh_combatPower
-------------------------------------
function UI_PresetDeckSetting:refresh_combatPower()
    local vars = self.vars
    --vars['cp_Label']:setString('')
    local deck = self.m_readySceneDeck:getDeckCombatPower()
    vars['cp_Label1']:setString(comma_value( math.floor(deck + 0.5) ))
end

-------------------------------------
-- function getCurrTamerID
-------------------------------------
function UI_PresetDeckSetting:getCurrTamerID()
    local tamer_id = g_tamerData:getCurrTamerID()
    return tamer_id
end

-------------------------------------
-- function refresh_tamer
-------------------------------------
function UI_PresetDeckSetting:refresh_tamer()
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
-- function refresh_buffInfo_TamerBuff
-------------------------------------
function UI_PresetDeckSetting:refresh_buffInfo_TamerBuff()
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
-- function refresh_buffInfo
-------------------------------------
function UI_PresetDeckSetting:refresh_buffInfo()
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
-- function click_okBtn
-------------------------------------
function UI_PresetDeckSetting:click_okBtn()
    self:close()
end


-------------------------------------
-- function click_manageBtn
-- @breif 드래곤 관리
-------------------------------------
function UI_PresetDeckSetting:click_manageBtn()
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
function UI_PresetDeckSetting:click_autoBtn()
    local stage_id = self.m_stageID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list = g_dragonsData:getDragonsList()

    local helper = DragonAutoSetHelperNew(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    
    self:applyDeck(l_auto_deck)
end

-------------------------------------
-- function click_removeBtn
-- @breif
-------------------------------------
function UI_PresetDeckSetting:click_removeBtn()
    self.m_readySceneDeck:clear_deck()
end

-------------------------------------
-- function click_runeBtn
-------------------------------------
function UI_PresetDeckSetting:click_runeBtn()
    local vars = self.vars

    local is_visible = (not vars['runeSprite']:isVisible())
    vars['runeSprite']:setVisible(is_visible)
    self.m_readySceneDeck:setVisibleEquippedRunes(is_visible)
end

-------------------------------------
-- function click_leaderBtn
-- @breif
-------------------------------------
function UI_PresetDeckSetting:click_leaderBtn()
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
-- function click_tamerBtn
-------------------------------------
function UI_PresetDeckSetting:click_tamerBtn()
    local function refresh_cb()
		self:refresh_tamer()
        self:refresh_combatPower()
		self:refresh_buffInfo()
	end
	UINavigator:goTo('tamer', nil, refresh_cb)
end

-------------------------------------
-- function click_fomationBtn
-- @breif
-------------------------------------
function UI_PresetDeckSetting:click_fomationBtn()
	-- m_readySceneDeck에서 현재 formation 받아와 전달
	local curr_formation_type = self.m_readySceneDeck.m_currFormation
    local ui = UI_FormationPopup(curr_formation_type)

    -- 삼뉴체크
--[[ 	if (self.m_bArena) then
        ui = UI_FormationArenaPopup(curr_formation_type)
    else
        ui = UI_FormationPopup(curr_formation_type)
    end ]]

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
-- function click_attrInfoBtn
-------------------------------------
function UI_PresetDeckSetting:click_attrInfoBtn()
    UI_HelpDragonGuidePopup('attr')
end

-------------------------------------
-- function click_startBtn
-------------------------------------
function UI_PresetDeckSetting:click_startBtn()
    local formation = self.m_readySceneDeck.m_currFormation
    local l_deck = self.m_readySceneDeck.m_lDeckList
    local leader = self.m_readySceneDeck.m_currLeader

    local struct_preset_deck = StructPresetDeck()
    struct_preset_deck:setDeckMap(l_deck)
    struct_preset_deck:setLeader(leader)
    struct_preset_deck:setFormation(formation)

    if self.m_successCb ~= nil then
        self.m_successCb(struct_preset_deck)
    end

    self:close()
end

-------------------------------------
-- function click_backBtn
-------------------------------------
function UI_PresetDeckSetting:click_backBtn()
	self:click_exitBtn()
end

-------------------------------------
-- function click_exitBtn
-------------------------------------
function UI_PresetDeckSetting:click_exitBtn()
    self:close()
    --if (self.m_dontSaveOnExit) then next_func() return end
    --self:checkChangeDeck(next_func)
end

-------------------------------------
-- function open
-------------------------------------
function UI_PresetDeckSetting.open(struct_prset_deck, success_cb)
    --local struct_prset_deck = StructPresetDeck()
    local ui = UI_PresetDeckSetting(struct_prset_deck, success_cb)
    return ui
end

--@CHECK
UI:checkCompileError(UI_ItemInfoPopup)
