local PARENT = UI_ReadySceneNew_Deck
-------------------------------------
-- class UI_ReadySceneNew_Deck_WorldRaid
-------------------------------------
UI_ReadySceneNew_Deck_WorldRaid = class(PARENT, {
    })

local TAB_ATTACK_1 = '1' -- 1 공격대 (상단)
local TOTAL_POS_CNT = 5

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:initUI()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    vars['formationNode']:setPositionX(-225)
    vars['clanRaidMenu']:setVisible(true)

    if (multi_deck_mgr.m_bUseManualSelection == false) then
        vars['upRadioBtn']:setVisible(false)
        vars['downRadioBtn']:setVisible(false)
        vars['clanRaidMenu']:setPositionY(65)
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:initTab()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리 (제 1공격대, 2공격대 선택)
    if (multi_deck_mgr) then
        for i =1, self.m_deckCount do
            self.m_uiReadyScene:addTabWithLabel(tostring(i), vars['teamTabBtn' .. i], vars['teamTabLabel' .. i])            
            vars['teamTabBtn' .. i]:setVisible(true)
        end
        
        -- 최초는 1공격대 보여줌
        self.m_selTab = TAB_ATTACK_1
        self.m_uiReadyScene:setTab(TAB_ATTACK_1)

        self.m_uiReadyScene:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
    end
end

-------------------------------------
-- function initButton
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:initButton()
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
-- function onChangeOption
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:onChangeOption()
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

        local team_name = multi_deck_mgr:getTeamName(mode)
        local msg = Str('{1}가 수동전투 가능상태로 설정되었습니다.', team_name)
        UIManager:toastNotificationGreen(msg)
        multi_deck_mgr:setMainDeck(mode)
    end

    -- 다른 모드는 자동 전투
    do 
        local anoter_mode = multi_deck_mgr:getAnotherPos(mode)
        local label = vars[anoter_mode .. 'RadioLabel']
        label:setString(Str('자동 전투'))
    end
end

-------------------------------------
-- function setSlot
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:setSlot(idx, doid, skip_sort)
    local cur_deck = self.m_selTab
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local deck_name = multi_deck_mgr:getDeckName(cur_deck)

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
    if (not g_friendData:checkSetSlotCondition(doid, deck_name)) then
        return false
    end

    -- 동종 동속성의 드래곤 제외
    if (self:checkSameDid(idx, doid)) then
        UIManager:toastNotificationRed(Str('같은 드래곤은 동시에 출전할 수 없습니다.'))
        return false
    end

    -- 멀티 덱 - 다른 위치 덱 동종 동속성의 드래곤 제외           
    if ((multi_deck_mgr:checkSameDidAnoterDeck_Raid(doid))) then
        return false
    end
    

    -- 설정되어 있는 덱 해제
    local prev_doid
    if self.m_lDeckList[idx] then
        prev_doid = self.m_lDeckList[idx]
        local prev_idx = self.m_tDeckMap[prev_doid]

        self.m_lDeckList[prev_idx] = nil
        self.m_tDeckMap[prev_doid] = nil

        -- 설정된 드래곤의 카드 삭제
        if self.m_lSettedDragonCard[prev_idx] then
            self.m_lSettedDragonCard[prev_idx].root:removeFromParent()
            self.m_lSettedDragonCard[prev_idx] = nil
        end

        -- 친구 드래곤 해제
        g_friendData:delSettedFriendDragonCard(prev_doid, deck_name)

        -- 멀티 덱 해제
        if (multi_deck_mgr) then
            multi_deck_mgr:deleteRaidDragon(prev_doid)
        end
    end

    -- 새롭게 생성
    if doid then
        self.m_lDeckList[idx] = doid
        self.m_tDeckMap[doid] = idx
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)

        self:makeSettedDragonCard(t_dragon_data, idx)

        -- 친구 드래곤 선택 체크
        g_friendData:makeSettedFriendDragonCard(doid, idx, deck_name)

        -- 멀티 덱 추가
        if (multi_deck_mgr) then
            multi_deck_mgr:deleteRaidDragon(doid)
            multi_deck_mgr:addRaidDragon(cur_deck, doid)
        end
    end

    if doid ~= nil then
        self:refresh_dragonCard(doid)
    end

    if prev_doid ~= nil then
        self:refresh_dragonCard(prev_doid)
    end

    -- 즉시 정렬
    if (not skip_sort) then
        self.m_uiReadyScene:apply_dragonSort()
    end

    self:setDirtyDeck()
    return true
end


-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 테이블뷰에 있는 카드 갱신
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:refresh_dragonCard(doid, is_friend)
    local table_view = self.m_uiReadyScene.m_readySceneSelect:getTableView(is_friend)
    if (not table_view) then
        return
    end

    local item = table_view.m_itemMap[doid]
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local is_set, pos = multi_deck_mgr:isSettedDragon(doid)    
    if (not item) then
        return
    end

    local ui = item['ui']
    if (not ui) then
        return
    end

    if is_set == true then
        ui:setTeamReadySpriteVisible(true, pos)
    else
        ui:setReadySpriteVisible(false)
    end
end

-------------------------------------
-- function setReadySpriteVisible
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:setReadySpriteVisible(ui, visible)
    -- 멀티 덱 1, 2 공격대 표시
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    if (multi_deck_mgr) then
        local num
        local deck_name = g_deckData:getSelectedDeckName()
        local deck_no = pl.stringx.replace(deck_name, 'world_raid_', '')
        if (visible) then
            num = tonumber(deck_no)
        else
            local doid = tostring(ui.m_dragonData['id'])
            local _, deck_num = multi_deck_mgr:isSettedDragon(doid)

            if (deck_num ~= tonumber(deck_no) and deck_num > 0 and deck_num <= 3) then
                num = deck_num
                visible = true
            else
                visible = false
                num = 99
            end
        end
        ui:setTeamReadySpriteVisible(visible, num)
        
    else
        ui:setReadySpriteVisible(visible)
    end
end
