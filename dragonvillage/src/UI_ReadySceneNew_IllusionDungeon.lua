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
-- function initUI
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:initUI()
    local vars = self.vars
    vars['scoreNode']:setVisible(true)
    vars['rewardNode']:setVisible(true)

    
    do -- 스테이지에 해당하는 스테미나 아이콘 생성
        local vars = self.vars
        local type = TableDrop:getStageStaminaType(self.m_stageID)
        local icon = IconHelper:getStaminaInboxIcon(type)
        vars['staminaNode']:addChild(icon)
    end

    -- 환상 드래곤 아이템 카드로 표기
    local illusion_data = g_illusionDungeonData:getIllusionDragonList()[1]
    local ui_dragon_card = UI_DragonCard(illusion_data)
    ui_dragon_card:setReadySpriteVisible(false)
    ui_dragon_card: setLockSpriteVisible(false)
    vars['eventDragonNode']:addChild(ui_dragon_card.root)

    vars['edDscMenu']:setVisible(true)
end

-------------------------------------
-- function initParentVariable
-- @brief 자식 클래스에서 반드시 구현할 것
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:initParentVariable()
    -- ITopUserInfo_EventListener의 맴버 변수들 설정
    self.m_uiName = 'UI_ReadySceneNew_IllusionDungeon'
    self.m_bVisible = true
    --self.m_titleStr = nil -- refresh에서 스테이지명 설정
    self.m_bUseExitBtn = true

    -- 입장권 타입 설정
    self.m_staminaType = TableDrop:getStageStaminaType(self.m_stageID)

    if (self:isClanRaidTrainingMode(self.m_stageID)) then
        self.m_staminaType = 'cldg_tr'
    end

	-- 들어온 경로에 따라 sound가 다름
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_uiBgm = 'bgm_dungeon_ready'
	else
		self.m_uiBgm = 'bgm_lobby'
	end
    self.m_subCurrency = 'event_illusion'
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:refresh()
    local stage_id = self.m_stageID
    local vars = self.vars

    -- 스테이지 이름
    local str = g_stageData:getStageName(stage_id) or ''
    local difficulty = g_illusionDungeonData:parseStageID(stage_id)
   
    if (difficulty == 1) then str = string.format('%s {@diff_normal}(%s)', str, Str('보통'))
    elseif (difficulty == 2) then str = string.format('%s {@diff_hard}(%s)', str, Str('어려움'))
    elseif (difficulty == 3) then str = string.format('%s {@diff_hell}(%s)', str, Str('지옥'))
    elseif (difficulty == 4) then str = string.format('%s {@diff_hellfire}(%s)', str, Str('불지옥'))
    end

    self.m_titleStr = '' 
    g_topUserInfo:setTitleRichString(str)

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

    -- 점수, 토큰 보너스 아이콘 표시
    self:refresh_bonusInfo()

    self:refresh_tamer()
	self:refresh_buffInfo()
    self:refresh_combatPower()
end

-------------------------------------
-- function initDeck
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:initDeck()
    self.m_readySceneDeck = UI_ReadySceneNew_Deck_Illusion(self)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
        self:refresh_bonusInfo()
		self:refresh_buffInfo()
        self:refresh_slotLight()
	end)
    
    -- 드래곤 선택하는 창에, 특정 드래곤 추가
	self:addIllusionDragon()  
end

-------------------------------------
-- function initDeck
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:refresh_bonusInfo()
    local vars = self.vars
    local m_deck = self.m_readySceneDeck.m_tDeckMap or {}
    local ui_bonus_reward = UI_IllusionBonusItem()
    local ui_bonus_score = UI_IllusionBonusItem()
    local is_active = false
    local is_my_dragon = false

    -- 환상 드래곤
    if (g_illusionDungeonData:getParticiPantInfo(m_deck) < 0) then
        ui_bonus_reward:setRewardBonus(false) -- param : (is_active, is_my_dragon)
        ui_bonus_score:setScoreBonus(true, false)
    -- 나의 환상 드래곤
    elseif (g_illusionDungeonData:getParticiPantInfo(m_deck) > 0) then
        ui_bonus_reward:setRewardBonus(true, true) -- param : (is_active, is_my_dragon)
        ui_bonus_score:setScoreBonus(true, true)    
    -- 환상 드래곤 없을 경우
    else
        ui_bonus_reward:setRewardBonus(false) -- param : (is_active, is_my_dragon)
        ui_bonus_score:setScoreBonus(false)
    end

    vars['scoreNode']:removeAllChildren()
    vars['rewardNode']:removeAllChildren()

    vars['scoreNode']:addChild(ui_bonus_reward.root)
    vars['rewardNode']:addChild(ui_bonus_score.root)
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

    local l_illusion_dragon = g_illusionDungeonData:getIllusionDragonList()
	for i, dragon_data in ipairs(l_illusion_dragon) do
		l_dragon_list[dragon_data['id']] = dragon_data
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
    
    -- 둘 다 환상 드래곤이면 정렬 바꾸지 않는다
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
-- function sort_myIllusion
-- @brief 내 드래곤이 환상 드래곤인지 여부
-------------------------------------
function UI_ReadySceneNew_IllusionDungeon:sort_myIllusion(a, b)

    local a_data = a['data']['did'] or nil
    local b_data = b['data']['did'] or nil

    if (not a_data or not b_data) then
        return nil
    end

    -- 둘 다 환상 드래곤 타입이라면 정렬하지 않음
    if g_illusionDungeonData:isIllusionDragonIDById(a_data) and g_illusionDungeonData:isIllusionDragonIDById(b_data) then
        return nil
    end

    if g_illusionDungeonData:isIllusionDragonIDById(a_data) then
        return true
    end

    if g_illusionDungeonData:isIllusionDragonIDById(b_data) then
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
        local function cond(a, b)
			return self:condition_deck_idx(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('deck_idx', false, cond)
        self.m_sortManagerFriendDragon:addPreSortType('deck_idx', false, cond)
    end

    do
        local function illusion(a, b)
			return self:sort_illusion(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('sort_illusion', false, illusion)
        self.m_sortManagerFriendDragon:addPreSortType('sort_illusion', false, illusion)
    end

    do
        local function my_illusion(a, b)
			return self:sort_myIllusion(a, b)
		end
		self.m_sortManagerDragon:addPreSortType('sort_my_illusion', false, my_illusion)
        self.m_sortManagerFriendDragon:addPreSortType('sort_my_illusion', false, my_illusion)
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
    local function finish_cb(game_key)
        self:replaceGameScene(game_key)
    end

    local deck_name = 'illusion'
    g_illusionDungeonData:request_illusionStart(self.m_stageID, deck_name, finish_cb)
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













local PARENT = UI

-------------------------------------
-- class UI_IllusionBonusItem
-------------------------------------
UI_IllusionBonusItem = class(PARENT,{
        
    })

-------------------------------------
-- function init
-------------------------------------
function UI_IllusionBonusItem:init()
    local vars = self:load('event_illusion_bonus_item.ui')
    
    vars['bonusLabel']:setVisible(false)
    vars['bonusVisual']:setVisible(false)

    -- 터치시 툴팁
    vars['tokenBtn']:registerScriptTapHandler(function()
        local desc = Str('자신이 소유한 어둠 앙그라가 출전 하면 더 많은 환상 토큰을 얻을 수 있습니다.')
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioningDirection(vars['tokenBtn'], false)
        tool_tip:autoRelease(1)
    end)

     vars['scoreBtn']:registerScriptTapHandler(function()
        local desc = Str('어둠 앙그라가 준 피해에 따라 추가 점수를 얻을 수 있습니다.')
        local tool_tip = UI_Tooltip_Skill(70, -145, desc)
        tool_tip:autoPositioningDirection(vars['scoreBtn'], false)
        tool_tip:autoRelease(1)
    end)
end

-------------------------------------
-- function setRewardBonus
-------------------------------------
function UI_IllusionBonusItem:setRewardBonus(is_active, is_my_dragon)
    local vars = self.vars
    vars['tokenBtn']:setVisible(true)
    vars['scoreBtn']:setVisible(false)
    vars['bonusLabel']:setVisible(true)
    vars['bonusLabel']:setString(Str('보상 보너스'))

    if (not is_active) then
        local inactive_nomal_sprite = cc.Sprite:create('res/ui/buttons/event_illusion_bonus_btn_0102.png')
        vars['tokenBtn']:setNormalImage(inactive_nomal_sprite)      
        vars['bonusVisual']:setVisible(false)
        return
    end

    if (is_my_dragon) then
        vars['bonusVisual']:setVisible(true)
        vars['bonusVisual']:changeAni('idle_bonus')
    else
        vars['bonusVisual']:setVisible(true)
        vars['bonusVisual']:changeAni('idle')       
    end
end

-------------------------------------
-- function setScoreBonus
-------------------------------------
function UI_IllusionBonusItem:setScoreBonus(is_active, is_my_dragon)
    local vars = self.vars
    vars['scoreBtn']:setVisible(true)
    vars['tokenBtn']:setVisible(false)
    vars['bonusLabel']:setVisible(true)
    vars['bonusLabel']:setString(Str('점수 보너스'))

    if (not is_active) then
        local inactive_nomal_sprite = cc.Sprite:create('res/ui/buttons/event_illusion_bonus_btn_0202.png')
        vars['scoreBtn']:setNormalImage(inactive_nomal_sprite)
        vars['bonusVisual']:setVisible(false)
        return
    end

    if (is_my_dragon) then
        vars['bonusVisual']:setVisible(true)
        vars['bonusVisual']:changeAni('idle_bonus')
    else
        vars['bonusVisual']:setVisible(true)
        vars['bonusVisual']:changeAni('idle')       
    end
end
