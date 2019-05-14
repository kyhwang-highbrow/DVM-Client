local PARENT = UI_ReadySceneNew_Deck


local TOTAL_POS_CNT = 5
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
    local l_deck, formation, deckname, leader, tamer_id = g_deckData:getDeck()
    local b_arena = self.m_uiReadyScene.m_bArena

    local formation_lv = b_arena and 1 or g_formationData:getFormationInfo(formation)['formation_lv']
    -- �ּ� 1�� ���� Ȯ�� (�ϴ� �ݷμ���)   
    local setted_number = table.count(self.m_lDeckList)
    if (setted_number <= 0) then
        local msg = Str('�ּ� 1�� �̻��� �������Ѿ� �մϴ�.')
        MakeSimplePopup(POPUP_TYPE.OK, msg)
        return
    end


    local b_change = false

    for i=1, TOTAL_POS_CNT do
        -- ���� �巡���� ������ ���
        if (l_deck[i] and (not self.m_lDeckList[i])) then
            b_change = true
            break
        end

        -- ���� �巡���� ����� ���
        if l_deck[i] and (l_deck[i] ~= self.m_lDeckList[i]) then
            b_change = true
            break
        end

        -- ���ο� �巡���� ������ ���
        if (not l_deck[i] and (self.m_lDeckList[i])) then
            b_change = true
            break
        end
    end

    -- ������ ����Ǿ��� ���
    if (self.m_currFormation ~= formation) then
        b_change = true
    end
    -- ���� ������ ����Ǿ��� ���
    if (self.m_currFormationLv ~= formation_lv and not b_arena) then
        self.m_currFormationLv = formation_lv
        b_change = true
    end
	-- ������ ����Ǿ��� ���
	if (self.m_currLeader ~= leader) then
		b_change = true
	end

    -- pvp�� ���̸ӱ��� ó��
    if (deckname == 'arena') or (deckname == 'pvp_atk') or (deckname == 'pvp_def') or (deckname == 'fpvp_atk') or (deckname == DECK_CHALLENGE_MODE) or g_deckData:isUsedDeckPvpDB(deckname) then
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
                local deckname = ret_deck['deckname']

                g_deckData:setDeck(deckname, ret_deck)
            end
            next_func()
        end

        local ui_network = UI_Network()
        ui_network:setUrl('/users/set_deck')
        ui_network:setRevocable(true)
        ui_network:setParam('uid', uid)
        ui_network:setParam('deckname', deckname)
        ui_network:setParam('formation', self.m_currFormation)
	    ui_network:setParam('leader', self.m_currLeader)
        ui_network:setParam('tamer', tamer_id)

        -- ģ�� �巡�� üũ (ģ�� �巡���� ��� �������� ����)
        local set_param 
        set_param = function(doid)
            if doid and g_friendData:checkFriendDragonFromDoid(doid) then 
                return nil 
            end

            return doid or nil          
        end 
        
        -- ���Ƿ� �߰��� �巡���� �������� �������� ����
        for i = 1,5 do
            local doid = self.m_lDeckList[i]
            if (doid) then
                if (string.match(doid, 'illusionDragon')) then
                    doid = nil
                end
            end
            ui_network:setParam('edoid'..i, doid)
            g_illusionDungeonData:setDragonDeck(self.m_lDeckList)
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

    -- ������ �����ϴ� ������ ������� üũ
    local bounding_box = vars['formationNode']:getBoundingBox()
    local local_location = vars['formationNode']:getParent():convertToNodeSpace(location)
    local is_contain = cc.rectContainsPoint(bounding_box, local_location)
    if (not is_contain) then
        
        -- ���� ����
        local doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        
        self:click_dragonCard(t_dragon_data)

        return false
    end

    -- ���� ����� ��ư ã��
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

    -- ���� �ڸ��� ���
    if (near_idx == self.m_selectedDragonSlotIdx) then
        local node = self.m_selectedDragonCard.root
        node:setScale(DC_SCALE_ON_PLATE)
        node:setPosition(0, DC_POS_Y)

        -- root�� �ű�
        node:retain()
        node:removeFromParent()
        vars['positionNode' .. near_idx]:addChild(node)
        node:release()

        self:setFocusDeckSlotEffect(self.m_selectedDragonSlotIdx)

		-- ���� ��ǳ�� ����
		SensitivityHelper:deleteBubbleText(node)
    else
        local near_idx_doid = self.m_lDeckList[self.m_selectedDragonSlotIdx]
        local selected_idx_doid = self.m_lDeckList[near_idx]

        -- �� �� ����
        self:setSlot(near_idx, nil)
        self:setSlot(self.m_selectedDragonSlotIdx, nil)

        -- �ٽ� �Է�
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
    -- ����
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
function UI_ReadySceneNew_Deck:setSlot(idx, doid, skip_sort)
    do -- ���� üũ
        local count = table.count(self.m_tDeckMap)
        if self.m_lDeckList[idx] then
            count = (count - 1)
        end
        if (count >= TOTAL_POS_CNT) then
            UIManager:toastNotificationRed(Str('5�������� ������ �� �ֽ��ϴ�.'))
            return false
        end
    end

    -- ģ�� �巡�� ���� �˻� (���� ���Ӽ� ���� ���� �˻�)
    if (not g_friendData:checkSetSlotCondition(doid)) then
        return false
    end

    -- ���� ���Ӽ��� �巡�� ����
    if (self:checkSameDid(idx, doid)) then
        UIManager:toastNotificationRed(Str('���� �巡���� ���ÿ� ������ �� �����ϴ�.'))
        return false
    end

    -- ��Ƽ �� - �ٸ� ��ġ �� ���� ���Ӽ��� �巡�� ����
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local deck_pos = self.m_selTab
    if (multi_deck_mgr) and (multi_deck_mgr:checkSameDidAnoterDeck(deck_pos, doid)) then
        return false
    end

    -- �����Ǿ� �ִ� �� ����
    if self.m_lDeckList[idx] then
        local prev_doid = self.m_lDeckList[idx]
        local prev_idx = self.m_tDeckMap[prev_doid]

        self.m_lDeckList[prev_idx] = nil
        self.m_tDeckMap[prev_doid] = nil

        -- ������ �巡���� ī�� ����
        if self.m_lSettedDragonCard[prev_idx] then
            self.m_lSettedDragonCard[prev_idx].root:removeFromParent()
            self.m_lSettedDragonCard[prev_idx] = nil
        end

        -- �巡�� ����Ʈ ����
        self:refresh_dragonCard(prev_doid)

        -- ģ�� �巡�� ����
        g_friendData:delSettedFriendDragonCard(prev_doid)

        -- ��Ƽ �� ����
        if (multi_deck_mgr) then
            multi_deck_mgr:deleteDragon(self.m_selTab, prev_doid)
        end
    end

    -- ���Ӱ� ����
    if doid then
        self.m_lDeckList[idx] = doid
        self.m_tDeckMap[doid] = idx
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if (not t_dragon_data) then
            t_dragon_data = g_illusionDungeonData:getDragonDataFromUid(doid)
        end
        self:makeSettedDragonCard(t_dragon_data, idx)

        -- ģ�� �巡�� ���� üũ
        g_friendData:makeSettedFriendDragonCard(doid, idx)

        -- ��Ƽ �� �߰�
        if (multi_deck_mgr) then
            multi_deck_mgr:addDragon(self.m_selTab, doid)
        end
    end

    -- ��� ����
    if (not skip_sort) then
        self.m_uiReadyScene:apply_dragonSort()
    end

    self:setDirtyDeck()
    return true
end
