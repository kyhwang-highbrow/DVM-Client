local PARENT = UI_ReadySceneNew_Deck


local TOTAL_POS_CNT = 5

local DC_POS_Y = 0
local DC_SCALE_ON_PLATE = 0.7
local DC_SCALE = 0.61
local DC_SCALE_PICK = (DC_SCALE * 0.8)

-------------------------------------
-- class UI_ReadySceneNew_Deck_Illusion
-------------------------------------
UI_ReadySceneNew_Deck_Illusion = class(PARENT,{
    })

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:init()
end

-------------------------------------
-- function checkChangeDeck
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:checkChangeDeck(next_func)
    local l_deck, formation, deck_name, leader, tamer_id = g_deckData:getDeck()
    local b_arena = self.m_uiReadyScene.m_bArena

    local formation_lv = b_arena and 1 or g_formationData:getFormationInfo(formation)['formation_lv']
    -- 최소 1명 출전 확인 (일단 콜로세움만)   
    local setted_number = table.count(self.m_lDeckList)
    if (setted_number <= 0) then
        local msg = Str('최소 1명 이상은 출전시켜야 합니다.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
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

    -- pvp는 테이머까지 처리
    if (deck_name == 'arena') or (deck_name == 'pvp_atk') or (deck_name == 'pvp_def') or (deck_name == 'fpvp_atk') or (deck_name == DECK_CHALLENGE_MODE) or g_deckData:isUsedDeckPvpDB(deck_name) then
        if (self.m_uiReadyScene:getCurrTamerID() ~= tamer_id) then
            b_change = true
        end
    end

    if (b_change) then
        
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

        g_settingDeckData:saveLocalDeck('illusion', self.m_lDeckList, self.m_currFormation, self.m_currLeader, tamer_id) -- param : (deck_name, l_deck, formation, leader, tamer_id, score) 

        -- 친구 드래곤 체크 (친구 드래곤일 경우 저장하지 않음)
        local set_param 
        set_param = function(doid)
            if doid and g_friendData:checkFriendDragonFromDoid(doid) then 
                return nil 
            end

            return doid or nil          
        end 
        
        -- 임의로 추가한 드래곤은 서버덱에 저장하지 않음
        for i = 1,5 do
            local doid = self.m_lDeckList[i]
            if (doid) then
                if (string.match(doid, 'illusion')) then
                    doid = nil
                end
            end
            ui_network:setParam('edoid'..i, doid)
        end

        ui_network:setSuccessCB(success_cb)
        ui_network:request()
    else
        next_func()
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:onTouchEnded(touch, event)
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
        local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        
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
-- function getDeckCombatPower
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:getDeckCombatPower()
    local combat_power = 0

    for doid,_ in pairs(self.m_tDeckMap) do
        local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        
        
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
-- function setSlot
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:setSlot(idx, doid, skip_sort)
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
    if (multi_deck_mgr) and (multi_deck_mgr:checkSameDidAnoterDeck(deck_pos, doid)) then
        return false
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
            multi_deck_mgr:deleteDragon(self.m_selTab, prev_doid)
        end
    end

    -- 새롭게 생성
    if doid then
        self.m_lDeckList[idx] = doid
        self.m_tDeckMap[doid] = idx
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if (not t_dragon_data) then
            t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        end
        self:makeSettedDragonCard(t_dragon_data, idx)

        -- 친구 드래곤 선택 체크
        g_friendData:makeSettedFriendDragonCard(doid, idx)

        -- 멀티 덱 추가
        if (multi_deck_mgr) then
            multi_deck_mgr:addDragon(self.m_selTab, doid)
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
function UI_ReadySceneNew_Deck_Illusion:checkSameDid(idx, doid)
    if (not doid) then
        return false
    end

    for e_idx, e_doid in pairs(self.m_lDeckList) do
        -- 같은 did면서 idx가 다른 경우 (해제되는 드래곤과 새로 추가되는 드래곤은 같아도 됨)
        if (g_illusionDungeonData:isSameDid(doid, e_doid)) and (idx ~= e_idx) then
            return true
        end
    end

    return false
end

-------------------------------------
-- function refreshLeader
-- @brief 리더 처리에 관한 모든것!
-------------------------------------
function UI_ReadySceneNew_Deck_Illusion:refreshLeader()
	local vars = self.m_uiReadyScene.vars
	local leader_idx = self.m_currLeader
    local pre_leader_doid = self.m_currLeaderOID
	local new_leader_doid = self.m_lDeckList[leader_idx]

	local idx

	-- 위치가 바뀌었는지 찾아본다
    for i, doid in pairs(self.m_lDeckList) do
        if (doid == pre_leader_doid) then
            idx = i
        end
    end
        
    -- 없다면 앞에서 부터 새로이 찾는다.
    if (idx == nil) then
		for i, doid in pairs(self.m_lDeckList) do
			-- 리더 스킬 있다면 저장
			if (g_illusionDungeonData:haveLeaderSkill(doid)) then
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