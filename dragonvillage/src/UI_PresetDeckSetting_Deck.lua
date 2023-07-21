-- @inherit UI_ReadySceneNew_Deck
-- local PARENT = UI_ReadySceneNew_Deck
-------------------------------------
-- class UI_PresetDeckSetting_Deck
-------------------------------------
UI_PresetDeckSetting_Deck = class({
    m_uiReadyScene = 'UI_ReadyScene',
    m_bDirtyDeck = 'boolean',
    m_lDeckList = '',
    m_cbOnDeckChange = '',


    m_focusDeckSlot = '',
    m_currLeader = 'number',
    m_currLeaderOID = 'number',
    m_currFormation = 'string',
    m_currFormationLv = 'string',
    m_focusDeckSlotEffect = '',
    m_lSettedDragonCard = 'list',
    m_bSelectedTouch = 'boolean',
    m_bRuneInfo = 'boolean',

    -- 드래그로 이동
    m_selectedDragonSlotIdx = 'number',
    m_selectedDragonCard = 'UI_DragonCard',
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

-------------------------------------
-- function init
-------------------------------------
function UI_PresetDeckSetting_Deck:init(ui_ready_scene)
    self.m_uiReadyScene = ui_ready_scene
    self.m_bDirtyDeck = true
    self.m_bRuneInfo = false
    self.m_lDeckList = {}
    
    self.m_currLeader = 0
    self.m_currFormation = 0
    self.m_currFormationLv = 1

	self:initUI()
    self:initButton()
    self:init_deck()

    self.m_uiReadyScene.root:scheduleUpdateWithPriorityLua(function(dt) self:update(dt) end, 0)
    self:makeTouchLayer_formation(self.m_uiReadyScene.vars['formationNode'])
end


-------------------------------------
-- function initUI
-------------------------------------
function UI_PresetDeckSetting_Deck:initUI()
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_PresetDeckSetting_Deck:initButton()
end

-------------------------------------
-- function init_deck
-------------------------------------
function UI_PresetDeckSetting_Deck:init_deck()
    if self.m_lSettedDragonCard then
        for _,ui in pairs(self.m_lSettedDragonCard) do
            ui.root:removeFromParent()
        end
    end

    self.m_lSettedDragonCard = {}
    local struct_preset_deck = self.m_uiReadyScene:getCurrPresetDeck()
    local l_deck = struct_preset_deck:getDeckMap()
    local formation = struct_preset_deck:getFormation()
    local leader = struct_preset_deck:getLeader()

	l_deck = self:convertSimpleDeck(l_deck)

	self.m_currLeader = leader
    self.m_lDeckList = clone(l_deck)

    for idx, doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:makeSettedDragonCard(t_dragon_data, idx)
    end

    -- focus deck
    self:refreshFocusDeckSlot()
	-- leader set
	self:refreshLeader()
    self:setFormation(formation)
    self:setFormationLv(1)
    self:setDirtyDeck()
end

-------------------------------------
-- function getSettedDragonDeckIdx
-------------------------------------
function UI_PresetDeckSetting_Deck:getSettedDragonDeckIdx(_doid)
    for idx, doid in pairs(self.m_lDeckList) do
        if doid == _doid then
            return idx
        end
    end
    return 0
end

-------------------------------------
-- function getDeckCombatPower
-- @brief
-------------------------------------
function UI_PresetDeckSetting_Deck:getDeckCombatPower()
    local combat_power = 0
    for _, doid in pairs(self.m_lDeckList) do
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
-- function convertSimpleDeck
-- @brief 기존 1~9번의 index를 쓰던 것에서 1~5만 사용하는 것으로 변경
-------------------------------------
function UI_PresetDeckSetting_Deck:convertSimpleDeck(l_deck)
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
-- function setFormation
-------------------------------------
function UI_PresetDeckSetting_Deck:setFormation(formation)
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
-- function updateFormation
-------------------------------------
function UI_PresetDeckSetting_Deck:updateFormation(formation, immediately)
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
function UI_PresetDeckSetting_Deck:actionForChangeDeck_Immediately(l_pos_list)
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
function UI_PresetDeckSetting_Deck:actionForChangeDeck_Sky(l_pos_list)
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
function UI_PresetDeckSetting_Deck:actionForChangeDeck_Smooth(l_pos_list)
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
function UI_PresetDeckSetting_Deck:getRotatedPosList(formation)
	local vars = self.m_uiReadyScene.vars
	local formation = formation or self.m_currFormation
    local interval = 110
    local b_arena = self.m_uiReadyScene.m_bArena

    cclog('b_arena', b_arena)
    local t_table = b_arena and TableFormationArena() or TableFormation()
    local l_pos_list = t_table:getFormationPositionListNew(formation, interval)

	local ret_list = {}

	for i, v in ipairs(l_pos_list) do
		vars['positionNode' .. i]:setPosition(v['x'], v['y'])
	end

	return ret_list
end

-------------------------------------
-- function setFormationLv
-------------------------------------
function UI_PresetDeckSetting_Deck:setFormationLv(formation_lv)
    if (not formation_lv) then
        return
    end

    if (self.m_currFormationLv == formation_lv) then
        return
    end

    self.m_currFormationLv = formation_lv
end

-------------------------------------
-- function checkSameDid
-- @brief 동종 동속성 드래곤 검사!
-------------------------------------
function UI_PresetDeckSetting_Deck:checkSameDid(idx, doid)
    if (not doid) then
        return false
    end

    for e_idx, e_doid in pairs(self.m_lDeckList) do
        -- 같은 did면서 idx가 다른 경우 (해제되는 드래곤과 새로 추가되는 드래곤은 같아도 됨)
        if (g_dragonsData:isSameDid(doid, e_doid)) and (idx ~= e_idx) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_PresetDeckSetting_Deck:checkChangeDeck(next_func)
end

-------------------------------------
-- function setSlot
-------------------------------------
function UI_PresetDeckSetting_Deck:setSlot(idx, doid, skip_sort)
    do -- 갯수 체크
        local count = table.count(self.m_lDeckList)
        if self.m_lDeckList[idx] then
            count = (count - 1)
        end
        if (count >= TOTAL_POS_CNT) then
            UIManager:toastNotificationRed(Str('5마리까지 출전할 수 있습니다.'))
            return false
        end
    end

    -- 동종 동속성의 드래곤 제외
    if (self:checkSameDid(idx, doid)) then
        UIManager:toastNotificationRed(Str('같은 드래곤은 동시에 출전할 수 없습니다.'))
        return false
    end

    -- 설정되어 있는 덱 해제
    if self.m_lDeckList[idx] then
        local prev_doid = self.m_lDeckList[idx]
        local prev_idx = self:getSettedDragonDeckIdx(prev_doid)

        self.m_lDeckList[prev_idx] = nil
        -- 설정된 드래곤의 카드 삭제
        if self.m_lSettedDragonCard[prev_idx] then
            self.m_lSettedDragonCard[prev_idx].root:removeFromParent()
            self.m_lSettedDragonCard[prev_idx] = nil
        end

        -- 드래곤 리스트 갱신
        self:refresh_dragonCard(prev_doid)
    end

    -- 새롭게 생성
    if doid then
        self.m_lDeckList[idx] = doid
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        self:makeSettedDragonCard(t_dragon_data, idx)
    end

    -- 즉시 정렬
    if (not skip_sort) then
        self.m_uiReadyScene:apply_dragonSort()
    end

    self:setDirtyDeck()
    return true
end

-------------------------------------
-- function setOnDeckChangeCB
-- @brief
-------------------------------------
function UI_PresetDeckSetting_Deck:setOnDeckChangeCB(func)
    self.m_cbOnDeckChange = func
end

-------------------------------------
-- function setDirtyDeck
-- @brief
-------------------------------------
function UI_PresetDeckSetting_Deck:setDirtyDeck()
    self.m_bDirtyDeck = true
end

-------------------------------------
-- function update
-- @brief
-------------------------------------
function UI_PresetDeckSetting_Deck:update(dt)
    if self.m_bDirtyDeck then
        if self.m_cbOnDeckChange then
            self.m_cbOnDeckChange()
        end
    end

    self.m_bDirtyDeck = false
end

-------------------------------------
-- function makeSettedDragonCard
-- @breif 접시위에 올라간 드래곤카드
-------------------------------------
function UI_PresetDeckSetting_Deck:makeSettedDragonCard(t_dragon_data, idx)
    local vars = self.m_uiReadyScene.vars

    local ui = UI_DragonCard(t_dragon_data)
	ui.root:setPosition(cc.p(0, DC_POS_Y))
    cca.uiReactionSlow(ui.root, DC_SCALE_ON_PLATE, DC_SCALE_ON_PLATE, DC_SCALE_PICK)
    
    -- 설정된 드래곤 표시 없애기
    ui:setReadySpriteVisible(false)
    vars['positionNode' .. idx]:addChild(ui.root, ZORDER.DRAGON_CARD)

    -- 착용 룬 보기
    ui:setRunesVisible(self.m_bRuneInfo)
    ui:setShadowSpriteVisible(self.m_bRuneInfo)

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

--[[     local dragon_attr = TableDragon():getValue(t_dragon_data['did'], 'attr')
    local stage_attr = self.m_uiReadyScene.m_stageAttr
    ui:setAttrSynastry(getCounterAttribute(dragon_attr, stage_attr)) ]]
end

-------------------------------------
-- function refresh
-------------------------------------
function UI_PresetDeckSetting_Deck:refresh()
end

-------------------------------------
-- function refreshFocusDeckSlot
-- @brief
-------------------------------------
function UI_PresetDeckSetting_Deck:refreshFocusDeckSlot()
    local count = table.count(self.m_lDeckList)
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
-- function refreshLeader
-- @brief 리더 처리에 관한 모든것!
-------------------------------------
function UI_PresetDeckSetting_Deck:refreshLeader()
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
function UI_PresetDeckSetting_Deck:refreshLeaderSprite(tar_idx)
	local vars = self.m_uiReadyScene.vars

	vars['leaderSprite']:setVisible(true)
	vars['leaderSprite']:retain()
	vars['leaderSprite']:removeFromParent()
	vars['positionNode' .. tar_idx]:addChild(vars['leaderSprite'], ZORDER.LEADER)
	vars['leaderSprite']:release()
end

-------------------------------------
-- function setFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 설정
-------------------------------------
function UI_PresetDeckSetting_Deck:setFocusDeckSlotEffect(idx)
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
-- function getFocusDeckSlotEffect
-- @brief 포커싱된 슬롯의 이펙트 생성
-------------------------------------
function UI_PresetDeckSetting_Deck:getFocusDeckSlotEffect()
    if (not self.m_focusDeckSlotEffect) then
        self.m_focusDeckSlotEffect = cc.Sprite:create('res/ui/frames/ready_fomation_select.png')
        self.m_focusDeckSlotEffect:setDockPoint(CENTER_POINT)
        self.m_focusDeckSlotEffect:setAnchorPoint(CENTER_POINT)
    end

    self.m_focusDeckSlotEffect:retain()
    return self.m_focusDeckSlotEffect
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 카드 갱신
-------------------------------------
function UI_PresetDeckSetting_Deck:refresh_dragonCard(doid, is_friend)

    local table_view = self.m_uiReadyScene.m_readySceneSelect:getTableView(is_friend)
    if (not table_view) then
        return
    end

    local item = table_view.m_itemMap[doid]
    local is_setted = self:getSettedDragonDeckIdx(doid) ~= 0

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
-- function setReadySpriteVisible
-------------------------------------
function UI_PresetDeckSetting_Deck:setReadySpriteVisible(ui, visible)
     ui:setReadySpriteVisible(visible)
end

-------------------------------------
-- function dragonPick
-------------------------------------
function UI_PresetDeckSetting_Deck:dragonPick(t_dragon_data, focus_deck_slot, delay_rate)
    local vars = self.m_uiReadyScene.vars
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
-- function click_dragonCard
-------------------------------------
function UI_PresetDeckSetting_Deck:click_dragonCard(t_dragon_data, skip_sort, idx)
    local doid = t_dragon_data['id']
    local setted_idx = self:getSettedDragonDeckIdx(doid)

    if setted_idx > 0 then
        self:setSlot(setted_idx, nil, skip_sort)
        self:setFocusDeckSlotEffect(setted_idx)
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
-- function clear_deck
-------------------------------------
function UI_PresetDeckSetting_Deck:clear_deck(skip_sort)
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
-- function setVisibleEquippedRunes
-------------------------------------
function UI_PresetDeckSetting_Deck:setVisibleEquippedRunes(is_visible)
    self.m_bRuneInfo = is_visible
    for _, dragon_card in pairs(self.m_lSettedDragonCard) do
        dragon_card:setShadowSpriteVisible(is_visible)
        dragon_card:setRunesVisible(is_visible)
    end
end
















-------------------------------------
-- function makeTouchLayer_formation
-- @brief 터치 레이어 생성
-------------------------------------
function UI_PresetDeckSetting_Deck:makeTouchLayer_formation(target_node)
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
function UI_PresetDeckSetting_Deck:onTouchBegan(touch, event)
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
function UI_PresetDeckSetting_Deck:onTouchMoved(touch, event)
    self:moveSelectDragonCard(touch, event)
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_PresetDeckSetting_Deck:onTouchEnded(touch, event)
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

        cclog('여기 들어온나??')
        
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
function UI_PresetDeckSetting_Deck:moveSelectDragonCard(touch, event)
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


