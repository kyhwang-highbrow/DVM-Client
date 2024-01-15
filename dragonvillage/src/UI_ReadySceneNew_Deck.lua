-------------------------------------
-- class UI_ReadySceneNew_Deck
-------------------------------------
UI_ReadySceneNew_Deck = class({
        m_uiReadyScene = 'UI_ReadyScene',
        m_focusDeckSlotEffect = 'cc.Sprite',
        m_focusDeckSlot = 'number', -- 다음에 설정할 덱

        -- slot idx, dragon object id
        m_lDeckList = 'table',
        m_tDeckMap = 'table',

        -- deck info
        m_lSettedDragonCard = 'list',
        m_currFormation = 'string',
        m_currFormationLv = 'number',
		m_currLeader = 'number',
        m_currLeaderOID = 'string',

        -- 드래그로 이동
        m_selectedDragonSlotIdx = 'number',
        m_selectedDragonCard = 'UI_DragonCard',

        m_bDirtyDeck = 'boolean',

        m_cbOnDeckChange = 'function',

        m_selRadioButton = 'UIC_RadioButton',
        m_selTab = 'string',

        m_gameMode = 'number',

        m_bSelectedTouch = 'boolean',

        -- 착용 룬 보기
        m_bRuneInfo = 'boolean',
    })

local TOTAL_POS_CNT = 5

-- positionNode에 붙어있는 노드들의 z-order
local ZORDER = 
{
	BACK_PLATE = 1,
	FOCUS_EFFECT = 2,
	DRAGON_CARD = 3,
	LEADER = 4,
}

local DC_POS_Y = 0
local DC_SCALE_ON_PLATE = 0.7
local DC_SCALE = 0.61
local DC_SCALE_PICK = (DC_SCALE * 0.8)

local TAB_ATTACK_1 = 'up' -- 1 공격대 (상단)
local TAB_ATTACK_2 = 'down' -- 2 공격대 (하단)

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_Deck:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene
    self.m_bDirtyDeck = true
    self.m_gameMode = self.m_uiReadyScene.m_gameMode

    self.m_bRuneInfo = false

	self:initUI()
    self:initButton()
    self:initTab()
    self:init_deck()

    self:makeTouchLayer_formation(self.m_uiReadyScene.vars['formationNode'])
    self.m_uiReadyScene.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew_Deck:initUI()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리
    if (multi_deck_mgr and self.m_gameMode ~= GAME_MODE_LEAGUE_RAID) then
        vars['formationNode']:setPositionX(-225)
        vars['clanRaidMenu']:setVisible(true)

        if (multi_deck_mgr.m_bUseManualSelection == false) then
            vars['upRadioBtn']:setVisible(false)
            vars['downRadioBtn']:setVisible(false)
        end
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadySceneNew_Deck:initButton()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리 (수동, 자동 선택)
    if (multi_deck_mgr and multi_deck_mgr.m_bUseManualSelection) then
        local radio_button = UIC_RadioButton()
        radio_button:addButtonAuto('up', vars)
        radio_button:addButtonAuto('down', vars)
        radio_button:setChangeCB(function() self:onChangeOption() end)
        self.m_selRadioButton = radio_button

        local sel_deck = multi_deck_mgr:getMainDeck()
        self.m_selRadioButton:setSelectedButton(sel_deck)
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ReadySceneNew_Deck:initTab()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리 (제 1공격대, 2공격대 선택)
    if (multi_deck_mgr) then
        self.m_uiReadyScene:addTabWithLabel(TAB_ATTACK_1, vars['teamTabBtn1'], vars['teamTabLabel1'])
        self.m_uiReadyScene:addTabWithLabel(TAB_ATTACK_2, vars['teamTabBtn2'], vars['teamTabLabel2'])
        
        -- 최초는 1공격대 보여줌
        self.m_selTab = TAB_ATTACK_1
        self.m_uiReadyScene:setTab(TAB_ATTACK_1)

        self.m_uiReadyScene:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
    end
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:onChangeOption()
    local vars = self.m_uiReadyScene.vars
    local mode = self.m_selRadioButton.m_selectedButton
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 선택한 모드 메인덱으로 저장 (수동 전투)
    do 
        local label = vars[mode .. 'RadioLabel']
        label:setTextColor(cc.c4b(255, 177, 1, 255))
        label:setString(Str('수동 전투'))

        local sprite = vars[mode .. 'RadioSprite']
        sprite:setVisible(true)

        if (self.m_gameMode ~= GAME_MODE_LEAGUE_RAID) then

            local team_name = multi_deck_mgr:getTeamName(mode)
            local msg = Str('{1}가 수동전투 가능상태로 설정되었습니다.', team_name)
            UIManager:toastNotificationGreen(msg)

            multi_deck_mgr:setMainDeck(mode)
        end
    end

    -- 다른 모드는 자동 전투
    do 
        local anoter_mode = multi_deck_mgr:getAnotherPos(mode)
        local label = vars[anoter_mode .. 'RadioLabel']
        label:setString(Str('자동 전투'))
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ReadySceneNew_Deck:onChangeTab(tab, first)
    if (self.m_selTab == tab) then return end
    
    self.m_selTab = tab
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local deck_name = multi_deck_mgr:getDeckName(tab)
    local next_func = function()
        g_deckData:setSelectedDeck(deck_name)
        self:init_deck()
        self.m_uiReadyScene:apply_dragonSort()
    end

    if (deck_name) then
        self:checkChangeDeck(next_func)
    end
end

-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadySceneNew_Deck:click_dragonCard(t_dragon_data, skip_sort, idx)
    local doid = t_dragon_data['id']
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리 - 1, 2 공격대 드래곤 체크
    if (multi_deck_mgr) then
        if (self.m_gameMode ~= GAME_MODE_LEAGUE_RAID) then
            local mode = self.m_selTab
            local map_deck = multi_deck_mgr:getAnotherDeckMap(mode)

            if (map_deck[doid]) then
                local another_mode = multi_deck_mgr:getAnotherPos(mode)
                local team_name = multi_deck_mgr:getTeamName(another_mode)

                local msg = Str('{1}에 출전중인 드래곤입니다.', team_name)
                UIManager:toastNotificationRed(msg)
                return 
            end
        end
    end

    if self.m_tDeckMap[doid] then
        local idx = self.m_tDeckMap[doid]
        self:setSlot(idx, nil, skip_sort)
        self:setFocusDeckSlotEffect(idx)
    else
        local ret = self:setSlot(self.m_focusDeckSlot, doid, skip_sort)

        -- 드래곤이 선택되었을 경우
        if (ret == true) then
            local delay_rate = idx
            self:dragonPick(t_dragon_data, self.m_focusDeckSlot, delay_rate)
        end
    end

    self:refreshFocusDeckSlot()
end

-------------------------------------
-- function dragonPick
-------------------------------------
function UI_ReadySceneNew_Deck:dragonPick(t_dragon_data, focus_deck_slot, delay_rate)
    local vars = self.m_uiReadyScene.vars
    -- 드래곤이 선택되면 new뱃지를 삭제
    local doid = t_dragon_data['id']
    g_highlightData:removeNewDoid(doid)

	-- 감성 말풍선
    local ui = self.m_lSettedDragonCard[focus_deck_slot]
    if ui then
	    local duration = delay_rate and (0.5 * delay_rate) or 0.05
        local did = t_dragon_data['did']
	    local delay_action = cc.DelayTime:create(duration)
	    local cb_action = cc.CallFunc:create(function()
                local ui_bubble = SensitivityHelper:doActionBubbleText(ui.root, did, nil, 'party_in')
                doAllChildren(ui_bubble, function(child) child:setGlobalZOrder(100) end)
		    end)
	    local action = cc.Sequence:create(delay_action, cb_action)
	    ui.root:runAction(action)
    end
end

-------------------------------------
-- function getFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 생성
-------------------------------------
function UI_ReadySceneNew_Deck:getFocusDeckSlotEffect()
    if (not self.m_focusDeckSlotEffect) then
        self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frames/ready_fomation_select.png')
        self.m_focusDeckSlotEffect:setDockPoint(CENTER_POINT)
        self.m_focusDeckSlotEffect:setAnchorPoint(CENTER_POINT)
    end

    self.m_focusDeckSlotEffect:retain()
    return self.m_focusDeckSlotEffect
end

-------------------------------------
-- function refreshFocusDeckSlot
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:refreshFocusDeckSlot()
    local count = table.count(self.m_tDeckMap)
    if (count >= TOTAL_POS_CNT) then
        return
    end

    -- 가장 빠른 slot으로 설정
    local idx = 1
    for i=1, TOTAL_POS_CNT do
        if (not self.m_lDeckList[i]) then
            idx = i
            break
        end
    end

    if (self.m_focusDeckSlot == idx) then
        return
    end

    self:setFocusDeckSlotEffect(idx)
end

-------------------------------------
-- function setFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 설정
-------------------------------------
function UI_ReadySceneNew_Deck:setFocusDeckSlotEffect(idx)
    local vars = self.m_uiReadyScene.vars

    local effect = self:getFocusDeckSlotEffect()
    effect:removeFromParent()

    local node_name = 'positionNode' .. idx
    vars[node_name]:addChild(effect, ZORDER.FOCUS_EFFECT)
    effect:release()

    effect:stopAllActions()
    effect:setOpacity(255)
    effect:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 0), cc.FadeTo:create(0.5, 255))))

    self.m_focusDeckSlot = idx
end

-------------------------------------
-- function refreshLeader
-- @brief 리더 처리에 관한 모든것!
-------------------------------------
function UI_ReadySceneNew_Deck:refreshLeader()
	local vars = self.m_uiReadyScene.vars
	local leader_idx = self.m_currLeader
    local pre_leader_doid = self.m_currLeaderOID
	local new_leader_doid = self.m_lDeckList[leader_idx]

	local idx

	-- 위치가 바뀌었는지 찾아본다
    for i, doid in pairs(self.m_lDeckList) do
        if (doid == pre_leader_doid) and (g_dragonsData:haveLeaderSkill(doid)) then
            idx = i
        end
    end
        
    -- 없다면 앞에서 부터 새로이 찾는다.
    if (idx == nil) then
		for i, doid in pairs(self.m_lDeckList) do
			-- 리더 스킬 있다면 저장
			if (g_dragonsData:haveLeaderSkill(doid)) then
				idx = i
                pre_leader_doid = doid
				break
			end
		end
    end

    -- 리더 체크
	if (idx) then
		self.m_currLeader = idx
        self.m_currLeaderOID = pre_leader_doid
		self:refreshLeaderSprite(idx)

	else
		-- 덱에 드래곤이 없으므로 leader표시를 없앤다.
		vars['leaderSprite']:setVisible(false)
        self.m_currLeader = nil
        self.m_currLeaderOID = nil
	end
end

-------------------------------------
-- function refreshLeaderSprite
-- @brief 리더 위치에 다시 붙여준다.
-------------------------------------
function UI_ReadySceneNew_Deck:refreshLeaderSprite(tar_idx)
	local vars = self.m_uiReadyScene.vars

	vars['leaderSprite']:setVisible(true)
	vars['leaderSprite']:retain()
	vars['leaderSprite']:removeFromParent()
	vars['positionNode' .. tar_idx]:addChild(vars['leaderSprite'], ZORDER.LEADER)
	vars['leaderSprite']:release()
end

-------------------------------------
-- function clear_deck
-------------------------------------
function UI_ReadySceneNew_Deck:clear_deck(skip_sort)
    do -- UI 정리
        if self.m_lSettedDragonCard then
            for _,ui in pairs(self.m_lSettedDragonCard) do
                ui.root:removeFromParent()
            end
        end
        self.m_lSettedDragonCard = {}
    end

    local l_refresh_dragon_doid = clone(self.m_lDeckList)

    self.m_lDeckList = {} 
    self.m_tDeckMap = {}

    -- 멀티 덱 해제
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    if (multi_deck_mgr) then
        multi_deck_mgr:clearDeckMap(self.m_selTab)
    end

    -- 드래곤 인벤의 카드 갱신을 위해 호출
    for _,doid in  pairs(l_refresh_dragon_doid) do
        self:refresh_dragonCard(doid)
    end

    self:setFocusDeckSlotEffect(1)

    -- 즉시 정렬
    if (not skip_sort) then
        self.m_uiReadyScene:apply_dragonSort()
    end

    self:setDirtyDeck()
end

-------------------------------------
-- function init_deck
-------------------------------------
function UI_ReadySceneNew_Deck:init_deck()
    do -- UI 정리
        if self.m_lSettedDragonCard then
            for _,ui in pairs(self.m_lSettedDragonCard) do
                ui.root:removeFromParent()
            end
        end
        self.m_lSettedDragonCard = {}
    end

    local l_deck, formation, deck_name, leader, tamer_id, formation_lv = g_deckData:getDeck()
	l_deck = self:convertSimpleDeck(l_deck)
    

	self.m_currLeader = leader
    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    self:init_deck_friend()

    for idx,doid in pairs(l_deck) do
        local skip_sort = true

        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

        if (t_dragon_data) then
            self:setSlot(idx, doid, skip_sort)
        end
        
        if (idx == leader) then
            self.m_currLeaderOID = doid
        end
    end

    -- focus deck
    self:refreshFocusDeckSlot()

	-- leader set
	self:refreshLeader()
    self:setFormation(formation)
    self:setFormationLv(formation_lv)
    self:setDirtyDeck()
end

-------------------------------------
-- function init_deck_friend
-------------------------------------
function UI_ReadySceneNew_Deck:init_deck_friend()
    local friendDragonIndex = g_friendData:getFriendDragonSlotIdx()
    local friendDragonId = g_friendData:getSettedFriendDragonID()

    if friendDragonIndex and friendDragonId then
        self:setSlot(friendDragonIndex, friendDragonId, true)
    else
        g_friendData:delSettedFriendDragon()
    end
end

-------------------------------------
-- function setDeck
-------------------------------------
function UI_ReadySceneNew_Deck:setDeck(l_deck, formation, deck_name, leader, tamer_id, formation_lv)
    do -- UI 정리
        if self.m_lSettedDragonCard then
            for _,ui in pairs(self.m_lSettedDragonCard) do
                ui.root:removeFromParent()
            end
        end
        self.m_lSettedDragonCard = {}
    end

	l_deck = self:convertSimpleDeck(l_deck)

	self.m_currLeader = leader
    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    for idx,doid in pairs(l_deck) do
        local skip_sort = true
        self:setSlot(idx, doid, skip_sort)
        
        if (idx == leader) then
            self.m_currLeaderOID = doid
        end
    end

    -- focus deck
    self:refreshFocusDeckSlot()

	-- leader set
	self:refreshLeader()
    self:setFormation(formation)
    self:setFormationLv(formation_lv)
    self:setDirtyDeck()
end

-------------------------------------
-- function isDragonForAttrTower
-------------------------------------
function UI_ReadySceneNew_Deck.isDragonForAttrTower(doid)    
    if (not g_attrTowerData) then
        return true
    end

    if (not g_attrTowerData.m_selectAttr) then
        return true
    end

    local selected_attr = g_attrTowerData.m_selectAttr
    if (team_dragon_attr ~= selected_attr) then
        return false
    end

    return true
end

-------------------------------------
-- function convertSimpleDeck
-- @brief 기존 1~9번의 index를 쓰던 것에서 1~5만 사용하는 것으로 변경
-------------------------------------
function UI_ReadySceneNew_Deck:convertSimpleDeck(l_deck)
    -- 변경이 필요한지 체크
    local need_convert = false
    for idx, doid in pairs(l_deck) do
        if (tonumber(idx) > TOTAL_POS_CNT) then
            need_convert = true
            break
        end
    end

    -- 변경이 필요 없으면 기존 덱 리턴
    if (not need_convert) then
        return l_deck
    end

    -- 정렬을 위한 임시 테이블 셋팅
    local l_deck_for_sort = {}
    for idx, doid in pairs(l_deck) do
        table.insert(l_deck_for_sort, {idx=idx, doid=doid})
    end

    -- idx가 낮은 순으로 정렬
    local function sort_func(a, b)
        return a['idx'] < b['idx']
    end
    table.sort(l_deck_for_sort, sort_func)

    -- 리턴할 덱 생성
    local l_deck = {}
    for i,v in ipairs(l_deck_for_sort) do
        l_deck[i] = v['doid']
    end

    return l_deck
end

-------------------------------------
-- function makeSettedDragonCard
-- @breif 접시위에 올라간 드래곤카드
-------------------------------------
function UI_ReadySceneNew_Deck:makeSettedDragonCard(t_dragon_data, idx)
    local vars = self.m_uiReadyScene.vars

    local ui = UI_DragonCard(t_dragon_data)
	ui.root:setPosition(cc.p(0, DC_POS_Y))
    cca.uiReactionSlow(ui.root, DC_SCALE_ON_PLATE, DC_SCALE_ON_PLATE, DC_SCALE_PICK)
    
    -- 설정된 드래곤 표시 없애기
    ui:setReadySpriteVisible(false)

    -- 착용 룬 보기
    ui:setRunesVisible(self.m_bRuneInfo)
    ui:setShadowSpriteVisible(self.m_bRuneInfo)

    vars['positionNode' .. idx]:addChild(ui.root, ZORDER.DRAGON_CARD)

    -- 선택된 드래곤 포지션 노드 zorder 높게 변경 (2D 덱으로 바뀌면서 드래곤 대사가 겹침)
    for i = 1, 5 do
        local node = vars['positionNode' .. i]
        if (node) then
            local zorder = (i == idx) and 1 or 0
            node:setLocalZOrder(zorder)
        end
    end

    self.m_lSettedDragonCard[idx] = ui

    ui.vars['clickBtn']:setEnabled(false) -- 드래그로 개편

    -- 장착된 드래곤
    self:refresh_dragonCard(t_dragon_data['id'])

    local dragon_attr = TableDragon():getValue(t_dragon_data['did'], 'attr')
    local stage_attr = self.m_uiReadyScene.m_stageAttr

    -- 상성
    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local raid_info = g_clanRaidData:getClanRaidStruct()
        local _, bonus_info = raid_info:getBonusSynastryInfo()
        local _, penalty_info = raid_info:getPenaltySynastryInfo()
        ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))
		ui:setClanAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info), dragon_attr)

    elseif (self.m_gameMode == GAME_MODE_EVENT_DEALKING) then
        local _, bonus_info = TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_uiReadyScene.m_stageID, stage_attr, true)
        local _, penalty_info = TableDealkingBuff:getInstance():getDealkingBonusInfo(self.m_uiReadyScene.m_stageID, stage_attr, false)
        ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))

    elseif (self.m_gameMode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
		ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
		
        -- 환상 드래곤이라면 Visual로 표시
        if (g_illusionDungeonData:isIllusionDragon(t_dragon_data)) then
			ui:setEventIllusionVisibleForDeck(true)
            ui:setEventIllusionFrameVisible(true)
		elseif (g_illusionDungeonData:isIllusionDragonID(t_dragon_data)) then
            ui:setEventIllusionVisibleForDeck(true, true)
            ui:setEventIllusionFrameVisible(true)
        end

    elseif (self.m_gameMode == GAME_MODE_WORLD_RAID) then
        local _, bonus_info = g_worldRaidData:getWorldRaidBuff()
        local _, penalty_info = g_worldRaidData:getWorldRaidDebuff()
        ui:setAttrSynastry(getCounterAttribute_ClanRaid(dragon_attr, bonus_info, penalty_info))

	else
        ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr))
    end
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 테이블뷰에 있는 카드 갱신
-------------------------------------
function UI_ReadySceneNew_Deck:refresh_dragonCard(doid, is_friend)
    local table_view = self.m_uiReadyScene.m_readySceneSelect:getTableView(is_friend)
    if (not table_view) then
        return
    end

    local item = table_view.m_itemMap[doid]
    local is_setted = self.m_tDeckMap[doid]

    if (not item) then
        return
    end

    local ui = item['ui']

    if (not ui) then
        return
    end

    cca.uiReactionSlow(ui.root, DC_SCALE, DC_SCALE, DC_SCALE_PICK)
    if is_setted then
        self:setReadySpriteVisible(ui, true)
    else
        self:setReadySpriteVisible(ui, false)
    end
end

-------------------------------------
-- function setSlot
-------------------------------------
function UI_ReadySceneNew_Deck:setSlot(idx, doid, skip_sort)
    do -- 갯수 체크
        local count = table.count(self.m_tDeckMap)
        if self.m_lDeckList[idx] then
            count = (count - 1)
        end
        if (count >= TOTAL_POS_CNT) then
            UIManager:toastNotificationRed(Str('5마리까지 출전할 수 있습니다.'))
            return false
        end
    end

    -- 친구 드래곤 슬롯 검사 (동종 동속성 보다 먼저 검사)
    if (not g_friendData:checkSetSlotCondition(doid)) then
        return false
    end

    -- 동종 동속성의 드래곤 제외
    if (self:checkSameDid(idx, doid)) then
        UIManager:toastNotificationRed(Str('같은 드래곤은 동시에 출전할 수 없습니다.'))
        return false
    end

    -- 멀티 덱 - 다른 위치 덱 동종 동속성의 드래곤 제외
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local deck_pos = self.m_selTab
    
    if (multi_deck_mgr) then
        if (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            if ((multi_deck_mgr:checkSameDidAnoterDeck_Raid(doid))) then
                return false
            end
        elseif (multi_deck_mgr:checkSameDidAnoterDeck(deck_pos, doid)) then
            return false
        end
    end

    -- 설정되어 있는 덱 해제
    if self.m_lDeckList[idx] then
        local prev_doid = self.m_lDeckList[idx]
        local prev_idx = self.m_tDeckMap[prev_doid]

        self.m_lDeckList[prev_idx] = nil
        self.m_tDeckMap[prev_doid] = nil

        -- 설정된 드래곤의 카드 삭제
        if self.m_lSettedDragonCard[prev_idx] then
            self.m_lSettedDragonCard[prev_idx].root:removeFromParent()
            self.m_lSettedDragonCard[prev_idx] = nil
        end

        -- 드래곤 리스트 갱신
        self:refresh_dragonCard(prev_doid)

        -- 친구 드래곤 해제
        g_friendData:delSettedFriendDragonCard(prev_doid)

        -- 멀티 덱 해제
        if (multi_deck_mgr) then
            if (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
                multi_deck_mgr:deleteRaidDragon(prev_doid)
            else
                multi_deck_mgr:deleteDragon(self.m_selTab, prev_doid)
            end
        end
    end

    -- 새롭게 생성
    if doid then
        self.m_lDeckList[idx] = doid
        self.m_tDeckMap[doid] = idx

        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:makeSettedDragonCard(t_dragon_data, idx)

        -- 친구 드래곤 선택 체크
        g_friendData:makeSettedFriendDragonCard(doid, idx)

        -- 멀티 덱 추가
        if (multi_deck_mgr) then
            if (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
                multi_deck_mgr:addRaidDragon(doid)
            else
                multi_deck_mgr:addDragon(self.m_selTab, doid)
            end
        end
    end

    -- 즉시 정렬
    if (not skip_sort) then
        self.m_uiReadyScene:apply_dragonSort()
    end



    self:setDirtyDeck()
    return true
end

-------------------------------------
-- function checkSameDid
-- @brief 동종 동속성 드래곤 검사!
-------------------------------------
function UI_ReadySceneNew_Deck:checkSameDid(idx, doid)
    if (not doid) then
        return false
    end

    for e_idx, e_doid in pairs(self.m_lDeckList) do
        -- 같은 did면서 idx가 다른 경우 (해제되는 드래곤과 새로 추가되는 드래곤은 같아도 됨)
        if (g_dragonsData:isSameDid(doid, e_doid)) and (idx ~= e_idx) then
            return true
        end
    end

    -- 데려가는 친구 드래곤 중에 같은 did가 있는지 검사
    if g_friendData:checkSameDidInFriends(idx, doid) == true then
        return true
    end

    return false
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadySceneNew_Deck:checkChangeDeck(next_func)
    local l_deck, formation, deck_name, leader, tamer_id = g_deckData:getDeck()
    local b_arena = self.m_uiReadyScene.m_bArena

    local formation_lv = b_arena and 1 or g_formationData:getFormationInfo(formation)['formation_lv']
    -- 최소 1명 출전 확인 (일단 콜로세움만)
    if (deck_name == 'arena_new') or (deck_name == 'arena_new_a') or (deck_name == 'arena_new_d') or (deck_name == 'arena') or (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') or (deck_name == 'fpvp_atk') or (deck_name == DECK_CHALLENGE_MODE) or (deck_name == 'clanwar') then
        local setted_number = table.count(self.m_lDeckList)
        if (setted_number <= 0) then
            local msg = Str('최소 1명 이상은 출전시켜야 합니다.')
            MakeSimplePopup(POPUP_TYPE.OK, msg)
            return
        end
    end

    local b_change = false

    for i=1, TOTAL_POS_CNT do
        -- 기존 드래곤이 해제된 경우
        if (l_deck[i] and (not self.m_lDeckList[i])) then
            b_change = true
            break
        end

        -- 기존 드래곤이 변경된 경우
        if l_deck[i] and (l_deck[i] ~= self.m_lDeckList[i]) then
            b_change = true
            break
        end

        -- 새로운 드래곤이 설정된 경우
        if (not l_deck[i] and (self.m_lDeckList[i])) then
            b_change = true
            break
        end
    end

    -- 진형이 변경되었을 경우
    if (self.m_currFormation ~= formation) then
        b_change = true
    end
    -- 진형 레벨이 변경되었을 경우
    if (self.m_currFormationLv ~= formation_lv and not b_arena) then
        self.m_currFormationLv = formation_lv
        b_change = true
    end
	-- 리더가 변경되었을 경우
	if (self.m_currLeader ~= leader) then
		b_change = true
	end

    if (deck_name == 'arena_new') then
		b_change = true
    end

    -- pvp는 테이머까지 처리
    if (deck_name == 'arena_new') or (deck_name == 'arena_new_d') or (deck_name == 'arena_new_a') or (deck_name == 'arena') or (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') or (deck_name == 'fpvp_atk') or (deck_name == DECK_CHALLENGE_MODE) or g_deckData:isUsedDeckPvpDB(deck_name) then
        if (self.m_uiReadyScene:getCurrTamerID() ~= tamer_id) then
            b_change = true
        end
    end

    if (b_change) then
        -- deckpvp collection을 사용하는 덱일 경우
        if (g_deckData:isUsedDeckPvpDB(deck_name)) then
            local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_deckData:request_setDeckPvpCollection(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb)


        -- 콜로세움 (신규) 전용 덱 처리
        elseif (deck_name == 'arena') then
            local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_arenaData:request_setDeck(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb)

        -- 콜로세움 (신규) 전용 덱 처리
        elseif (deck_name == 'arena_new_a' or deck_name == 'arena_new_d' or  deck_name == 'arena_new') then
            local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_arenaNewData:request_setDeck(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb, self:getDeckCombatPower())

        -- 콜로세움 전용 덱 처리
        elseif (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') then
            local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_colosseumData:request_setDeck(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb)
        
        -- 친선전 전용 덱 처리
        elseif (deck_name == 'fpvp_atk') then
            local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_friendMatchData:request_setDeck(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb)
        
        -- 클랜전 전용 덱 처리
        elseif (deck_name == 'clanwar') then
             local l_edoid = {}
            l_edoid[1] = self.m_lDeckList[1]
            l_edoid[2] = self.m_lDeckList[2]
            l_edoid[3] = self.m_lDeckList[3]
            l_edoid[4] = self.m_lDeckList[4]
            l_edoid[5] = self.m_lDeckList[5]
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()
            local fail_cb = nil
            g_clanWarData:request_setDeck(deck_name, self.m_currFormation, self.m_currLeader, l_edoid, tamer_id, next_func, fail_cb)           
        else
            local uid = g_userData:get('uid')
            local tamer_id = self.m_uiReadyScene:getCurrTamerID()

            local function success_cb(ret)
                if ret['deck'] then
                    local ret_deck = ret['deck']
                    local t_deck = ret_deck['deck']
                    local deck_name = ret_deck['deckName']

                    g_deckData:setDeck(deck_name, ret_deck)
                end
                next_func()
            end

            local ui_network = UI_Network()
            ui_network:setUrl('/users/set_deck')
            ui_network:setRevocable(true)
            ui_network:setParam('uid', uid)
            ui_network:setParam('deck_name', deck_name)
            ui_network:setParam('formation', self.m_currFormation)
		    ui_network:setParam('leader', self.m_currLeader)
            ui_network:setParam('tamer', tamer_id)

            -- 친구 드래곤 체크 (친구 드래곤일 경우 저장하지 않음)
            local set_param 
            set_param = function(doid)
                if doid and g_friendData:checkFriendDragonFromDoid(doid) then 
                    return nil 
                end

                return doid or nil          
            end
            
        
            ui_network:setParam('edoid1', set_param(self.m_lDeckList[1]))
            ui_network:setParam('edoid2', set_param(self.m_lDeckList[2]))
            ui_network:setParam('edoid3', set_param(self.m_lDeckList[3]))
            ui_network:setParam('edoid4', set_param(self.m_lDeckList[4]))
            ui_network:setParam('edoid5', set_param(self.m_lDeckList[5]))
            ui_network:setParam('edoid6', set_param(self.m_lDeckList[6]))
            ui_network:setParam('edoid7', set_param(self.m_lDeckList[7]))
            ui_network:setParam('edoid8', set_param(self.m_lDeckList[8]))
            ui_network:setParam('edoid9', set_param(self.m_lDeckList[9]))
            ui_network:setSuccessCB(success_cb)
            ui_network:request()
        end
    else
        next_func()
    end
end

-------------------------------------
-- function getDragonCount
-------------------------------------
function UI_ReadySceneNew_Deck:getDragonCount()
    if (g_friendData:getDragonDataFromDoid(doid_a)) then
            return true
    end
    local count = table.count(self.m_lDeckList)
    return count
end

-------------------------------------
-- function isContainMyDragon
-------------------------------------
function UI_ReadySceneNew_Deck:isContainMyDragon()    
    for _,doid in ipairs(self.m_lDeckList) do
        if (not g_dragonsData:getDragonDataFromUidRef(doid)) then
                return false
        end
    end

    return true
end

-------------------------------------
-- function setFormation
-------------------------------------
function UI_ReadySceneNew_Deck:setFormation(formation)
    if (self.m_currFormation == formation) then
        return
    end

    local update_immediately = false
    if (not self.m_currFormation) then
        update_immediately = true
    end

    self.m_currFormation = formation
    self:updateFormation(formation, update_immediately)
end

-------------------------------------
-- function setFormationLv
-------------------------------------
function UI_ReadySceneNew_Deck:setFormationLv(formation_lv)
    if (not formation_lv) then
        return
    end

    if (self.m_currFormationLv == formation_lv) then
        return
    end

    self.m_currFormationLv = formation_lv
end

-------------------------------------
-- function updateFormation
-------------------------------------
function UI_ReadySceneNew_Deck:updateFormation(formation, immediately)
    local vars = self.m_uiReadyScene.vars

    local l_pos_list = self:getRotatedPosList(formation)

	-- 상태에 따라 즉시 이동 혹은 움직임 액션 추가
	if immediately then
		self:actionForChangeDeck_Sky(l_pos_list)
	else
		self:actionForChangeDeck_Smooth(l_pos_list)
	end
end

-------------------------------------
-- function actionForChangeDeck_Immediately
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 액션없이 즉시 이동
-------------------------------------
function UI_ReadySceneNew_Deck:actionForChangeDeck_Immediately(l_pos_list)
	local vars = self.vars
	for i, node_space in ipairs(l_pos_list) do
		-- 드래곤 카드
		vars['positionNode' .. i]:setPosition(node_space['x'], node_space['y'])
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])
	end
end

-------------------------------------
-- function actionForChangeDeck_Sky
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 하늘로 솟았다가 내려온다.
-------------------------------------
function UI_ReadySceneNew_Deck:actionForChangeDeck_Sky(l_pos_list)
	local vars = self.m_uiReadyScene.vars
	for i, node_space in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])

		-- 배치된 카드에 액션을 준다.
		local out_action = cca.makeBasicEaseMove(0.1, node_space['x'], 2000)
		local in_action = cca.makeBasicEaseMove(0.3 + (0.1 * i), node_space['x'], node_space['y'])
		local action = cc.Sequence:create(out_action, in_action)
		cca.runAction(vars['positionNode' .. i], action, 100)
	end
end

-------------------------------------
-- function actionForChangeDeck_Smooth
-- @brief 각 덱이 진형이 변경되었을 시 액션 : 부드럽게 바뀐 진형으로 이동
-------------------------------------
function UI_ReadySceneNew_Deck:actionForChangeDeck_Smooth(l_pos_list)
	local vars = self.m_uiReadyScene.vars
	for i, node_space in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setLocalZOrder(1000 - node_space['y'])
						
		-- 배치된 카드에 액션을 준다.
		local action = cca.makeBasicEaseMove(0.3, node_space['x'], node_space['y'])
		cca.runAction(vars['positionNode' .. i], action, 100)
	end
end

-------------------------------------
-- function getRotatedPosList
-- @brief 테이블을 통해 받은 좌표를 화면 축 회전에 의한 값으로 환산한다.
-- @param formation : 없으면 현재 포지션 이용
-------------------------------------
function UI_ReadySceneNew_Deck:getRotatedPosList(formation)
	local vars = self.m_uiReadyScene.vars
	local formation = formation or self.m_currFormation
    local interval = 110
    local b_arena = self.m_uiReadyScene.m_bArena
    local t_table = b_arena and TableFormationArena() or TableFormation()
    local l_pos_list = t_table:getFormationPositionListNew(formation, interval)

	local ret_list = {}

	for i, v in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setPosition(v['x'], v['y'])
	end

	return ret_list
end

-------------------------------------
-- function makeTouchLayer_formation
-- @brief 터치 레이어 생성
-------------------------------------
function UI_ReadySceneNew_Deck:makeTouchLayer_formation(target_node)
    self.m_bSelectedTouch = false
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function UI_ReadySceneNew_Deck:onTouchBegan(touch, event)
    local vars = self.m_uiReadyScene.vars
    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['formationNode']:getBoundingBox()
    local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)

    if (not is_contain) then
        return false
    end

    -- 버튼 체크
    local local_location = vars['formationNode']:convertToNodeSpace(location)
	
	-- @TODO 보정을 해줘야한다... 왜지!
	--local_location = { x = local_location['x'] - 350, y = local_location['y'] - 200}

    local select_idx = nil
    for i=1, TOTAL_POS_CNT do
        local btn_name = 'positionNode' .. string.format('%d', i)
        local btn_bounding_box = vars[btn_name]:getBoundingBox()

        -- 가로로 넓은 영역을 정사각형으로 변경
        btn_bounding_box['height'] = btn_bounding_box['width']
        local is_contain = cc.rectContainsPoint(btn_bounding_box, local_location)

        if (is_contain == true) then
            select_idx = i
            break
        end
    end

    if (not select_idx) then
        --cclog('선택된 슬롯 없음')
        return false
    end

    if (not self.m_lDeckList[select_idx]) then
        --cclog('비어있는 슬롯 ' .. select_idx)
        return false
    end

    -- 멀티 터치 블럭은 상단 코드에서 터치 관련 체크 끝난 후 맨 마지막에 처리!
    if (not self.m_bSelectedTouch) then
        self.m_bSelectedTouch = true
    else
        return false
    end

    do -- 드래곤 선택
        self.m_selectedDragonSlotIdx = select_idx
        self.m_selectedDragonCard = self.m_lSettedDragonCard[select_idx]

        local node = self.m_selectedDragonCard.root

        -- 카드를 터치 홀딩 중에 덱 해체를 하거나 할 경우를 대비해 체크
        if (not node) then
            return
        end

        node:setScale(DC_SCALE)

        local local_pos = convertToAnoterParentSpace(node, vars['formationNode'])
        node:setPosition(local_pos['x'], local_pos['y'])

        -- root로 옮김
        node:retain()
        node:removeFromParent()
        vars['formationNode']:addChild(node)
        node:release()
		
		-- 감성 말풍선 삭제
		SensitivityHelper:deleteBubbleText(node)
    end

    return true
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function UI_ReadySceneNew_Deck:onTouchMoved(touch, event)
    self:moveSelectDragonCard(touch, event)
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ReadySceneNew_Deck:onTouchEnded(touch, event)
    if (self.m_bSelectedTouch) then
        self.m_bSelectedTouch = false
    end
    
    self:moveSelectDragonCard(touch, event)

    local vars = self.m_uiReadyScene.vars
    local location = touch:getLocation()

    -- 진형을 설정하는 영역을 벗어났는지 체크
    local bounding_box = vars['formationNode']:getBoundingBox()
    local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)
    if (not is_contain) then
        
        -- 장착 해제
        local doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:click_dragonCard(t_dragon_data)

        return false
    end

    -- 가장 가까운 버튼 찾기
    local near_idx = nil
    local near_distance = nil
    local local_location = convertToNodeSpace(vars['formationNode'], location)
    for i=1, TOTAL_POS_CNT do
        local btn_name = 'positionNode' .. string.format('%d', i)
        local slot_pos_x, slot_pos_y = vars[btn_name]:getPosition()

        local distance = getDistance(slot_pos_x, slot_pos_y, local_location['x'], local_location['y'])

        if (near_distance == nil) or (distance < near_distance) then
            near_distance = distance
            near_idx = i
        end
    end

    -- 같은 자리일 경우
    if (near_idx == self.m_selectedDragonSlotIdx) then
        local node = self.m_selectedDragonCard.root

        -- 카드를 터치 홀딩 중에 덱 해체를 하거나 할 경우를 대비해 체크
        if (not node) then
            return
        end

        node:setScale(DC_SCALE_ON_PLATE)
        node:setPosition(0, DC_POS_Y)

        -- root로 옮김
        node:retain()
        node:removeFromParent()
        vars['positionNode' .. near_idx]:addChild(node)
        node:release()

        self:setFocusDeckSlotEffect(self.m_selectedDragonSlotIdx)

		-- 감성 말풍선 삭제
		SensitivityHelper:deleteBubbleText(node)
    else
        local near_idx_doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local selected_idx_doid = self.m_lDeckList[near_idx]

        -- 둘 다 해제
        self:setSlot(near_idx, nil)
        self:setSlot(self.m_selectedDragonSlotIdx, nil)

        -- 다시 입력
        self:setSlot(near_idx, near_idx_doid)
        self:setSlot(self.m_selectedDragonSlotIdx, selected_idx_doid)

        self:refreshFocusDeckSlot()
    end
end

-------------------------------------
-- function moveSelectDragonCard
-------------------------------------
function UI_ReadySceneNew_Deck:moveSelectDragonCard(touch, event)
    local vars = self.m_uiReadyScene.vars
    
    local location = touch:getLocation()
    local local_location = convertToNodeSpace(vars['formationNode'], location)

    local node = self.m_selectedDragonCard.root

    -- 카드를 터치 홀딩 중에 덱 해체를 하거나 할 경우를 대비해 체크
    if (not node) then
        return
    end

    node:setPosition(local_location['x'], local_location['y'])
		
	-- 진형을 벗어나는지 체크하여 벗어났다면 감성 말풍선 띄운다.
	do
		local bounding_box = vars['formationNode']:getBoundingBox()
		local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
		local is_contain = cc.rectContainsPoint(bounding_box, local_location)
		if (not is_contain) then
			-- 감성 말풍선
			local pre_bubble = node:getChildByTag(TAG_BUBBLE)
			if (not pre_bubble) then
				local did = self.m_selectedDragonCard.m_dragonData['did']
				SensitivityHelper:doActionBubbleText(node, did, nil, 'party_out')
			end
		end
	end
end

-------------------------------------
-- function setDirtyDeck
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:setDirtyDeck()
    self.m_bDirtyDeck = true
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:update(dt)
    if self.m_bDirtyDeck then
        if self.m_cbOnDeckChange then
            self.m_cbOnDeckChange()
        end
    end

    self.m_bDirtyDeck = false
end

-------------------------------------
-- function getDeckCombatPower
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:getDeckCombatPower()
    local combat_power = 0

    for doid,_ in pairs(self.m_tDeckMap) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if t_dragon_data then
            combat_power = combat_power + t_dragon_data:getCombatPower()
        end
    end

    local b_arena = self.m_uiReadyScene.m_bArena
    -- 진형
    if (not b_arena) then
        local l_formation = g_formationData:getFormationInfoList()
	    local curr_formation = self.m_currFormation
	    local formation_data = l_formation[curr_formation]

        combat_power = combat_power + (formation_data['formation_lv'] * g_constant:get('UI', 'FORMATION_LEVEL_COMBAT_POWER'))
    end

    return combat_power
end

-------------------------------------
-- function setOnDeckChangeCB
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck:setOnDeckChangeCB(func)
    self.m_cbOnDeckChange = func
end

-------------------------------------
-- function setReadySpriteVisible
-------------------------------------
function UI_ReadySceneNew_Deck:setReadySpriteVisible(ui, visible)
    -- 멀티 덱 1, 2 공격대 표시
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    if (multi_deck_mgr) then
        local num

        if (self.m_gameMode == GAME_MODE_LEAGUE_RAID)then
            local deck_name = g_deckData:getSelectedDeckName()
            local deck_no = pl.stringx.replace(deck_name, 'league_raid_', '')

            if (visible) then
                num = tonumber(deck_no)

            else
                local doid = tostring(ui.m_dragonData['id'])
                local deck_num = g_leagueRaidData:getDeckIndex(doid)

                if (deck_num ~= tonumber(deck_no) and deck_num > 0 and deck_num <= 3) then
                    num = deck_num
                    visible = true
                else
                    visible = false
                    num = 99
                end
            end

        else
            num = self.m_selTab == TAB_ATTACK_1 and 1 or 2
            
        end

        ui:setTeamReadySpriteVisible(visible, num)
        
    else
        ui:setReadySpriteVisible(visible)
    end
end

-------------------------------------
-- function getCurDeckInfo
-------------------------------------
function UI_ReadySceneNew_Deck:getCurDeckInfo()
    return self.m_lDeckList, self.m_currFormation, 'ancient', self.m_currLeader, self.m_uiReadyScene:getCurrTamerID()
end



-------------------------------------
-- function setVisibleEquippedRunes
-------------------------------------
function UI_ReadySceneNew_Deck:setVisibleEquippedRunes(is_visible)

    self.m_bRuneInfo = is_visible

    for _, dragon_card in pairs(self.m_lSettedDragonCard) do
        dragon_card:setShadowSpriteVisible(is_visible)
        dragon_card:setRunesVisible(is_visible)
    end
end




