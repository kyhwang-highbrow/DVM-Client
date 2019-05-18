local PARENT = UI_ReadySceneNew

-------------------------------------
-- class UI_ReadySceneNew_IllusionDungeon
-------------------------------------
UI_ReadySceneNew_IllusionDungeon = class(PARENT,{

    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:init(stage_id, sub_info)
  
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:refresh()
    local stage_id = self.m_stageID
    local vars = self.vars

    -- 스테이지 이름
    local str = g_stageData:getStageName(stage_id)
        

    -- 필요 활동력 표시
    local stamina_type, stamina_value = TableDrop:getStageStaminaType(stage_id)
    vars['actingPowerLabel']:setString(stamina_value)


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

    -- 황금 던전 (골드라고라 던전)
    elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
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
-- function init
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:initDeck()
    self.m_readySceneDeck = UI_ReadySceneNew_Deck_Illusion(self)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
        self:refresh_slotLight()
	end)
    
    -- 드래곤 선택하는 창에, 특정 드래곤 추가
	self:addIllusionDragon()  
end

-------------------------------------
-- function click_manageBtn
-- @breif 드래곤 관리
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:click_manageBtn()
    local function next_func()
        local ui = UI_DragonManageInfo()
        local function close_cb()
            local function func()
                self:refresh()
                self.m_readySceneSelect:init_dragonTableView()
				-- 드래곤 선택하는 창에, 특정 드래곤 추가
				self:addIllusionDragon()
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
-- function addIllusionDragon
-- @breif 드래곤 선택하는 창에, 특정 드래곤 추가
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:addIllusionDragon()

	if (not self.m_readySceneSelect) then
		return
	end

	local select_table_view = self.m_readySceneSelect.m_tableViewExtMine
	if (not select_table_view) then
		return
	end

	-- 기존 보유 드래곤
	local l_dragon_list = clone(g_dragonsData:getDragonsList())

    local l_illusion_dragon = g_illusionDungeonData.m_lillusionDragonInfo
	for i, dragon_data in ipairs(l_illusion_dragon) do
		l_dragon_list['illusionDragon'..i] = dragon_data
	end    

	select_table_view:setItemList(l_dragon_list)
end

-------------------------------------
-- function check_startCondition
-- @breif 시작 가능한 상태인지 체크하는 함수 분리 - 가능하면 true, 불가능하면 flase 반환
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:check_startCondition(stage_id)
    -- 모드 상관없이 공통으로 체크
    if (self:getDragonCount() <= 0) then
        UIManager:toastNotificationRed(Str('최소 1명 이상은 출전시켜야 합니다.'))
        return false
    --elseif (not is_advent) and (not g_stageData:isOpenStage(stage_id)) then
    --   MakeSimplePopup(POPUP_TYPE.OK, Str('이전 스테이지를 클리어하세요.'))
    --    return false
    -- 스태미너 소모 체크
    elseif (stamina_charge) and (not g_staminasData:checkStageStamina(stage_id)) then
        g_staminasData:staminaCharge(stage_id)
        return false
    end

    return true
end

-------------------------------------
-- function sort_illusion
-- @brief 환상 드래곤 여부 (환상 드래곤은 항상 맨 앞으로)
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:sort_illusion(a, b)

    local a_data = a['data']['id'] or nil
    local b_data = b['data']['id'] or nil

    if (not a_data or not b_data) then
        return nil
    end
    
    if (string.match(a_data, 'illusion') and string.match(b_data, 'illusion')) then
        return nil
    end

    if (string.match(a_data, 'illusion')) then
        return true
    end

    if (string.match(b_data, 'illusion')) then
        return false
    end

    return nil
end

-------------------------------------
-- function init_sortMgr
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:init_sortMgr(stage_id)

	-- 정렬 매니저 생성
    self.m_sortManagerDragon = SortManager_Dragon_Illusion()
    self.m_sortManagerFriendDragon = SortManager_Dragon()
    
    do
        local function illusion(a, b)
			return self:sort_illusion(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('sort_illusion', false, illusion)
        self.m_sortManagerFriendDragon:addPreSortType('sort_illusion', false, illusion)
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
-- function getLeaderBuffDesc
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:getLeaderBuffDesc()
    self.m_readySceneDeck:refreshLeader()
	
	local leader_buff		
	local leader_idx = self.m_readySceneDeck.m_currLeader
	local l_doid = self.m_readySceneDeck.m_lDeckList
	local leader_doid = l_doid[leader_idx]
    if (not leader_doid) then
        return nil
    end
    local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(leader_doid)
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
-- function networkGameStart
-- @breif
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:networkGameStart()
    --local function finish_cb(game_key)
        self:replaceGameScene('Illusion_Dungeon')
    --end

    --[[
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

    else
        g_stageData:requestGameStart(self.m_stageID, deck_name, combat_power, finish_cb)
    end
    --]]
end

-------------------------------------
-- function replaceGameScene
-- @breif
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:replaceGameScene(game_key)
    -- 시작이 두번 되지 않도록 하기 위함
    UI_BlockPopup()

    local stage_id = self.m_stageID
    local stage_name = 'stage_' .. stage_id
    local scene

   
    scene = SceneGameIllusion(game_key, stage_id, stage_name, false)


    scene:runScene()
end
