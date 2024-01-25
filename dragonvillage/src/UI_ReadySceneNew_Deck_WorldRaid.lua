local PARENT = UI_ReadySceneNew_Deck
-------------------------------------
-- class UI_ReadySceneNew_Deck_WorldRaid
-------------------------------------
UI_ReadySceneNew_Deck_WorldRaid = class(PARENT, {
    })

local TAB_ATTACK_1 = '1' -- 1 공격대 (상단)
local TAB_ATTACK_2 = '2' -- 2 공격대 (하단)
local TAB_ATTACK_3 = '3' -- 2 공격대 (하단)
-------------------------------------
-- function initTab
-------------------------------------
function UI_ReadySceneNew_Deck_WorldRaid:initTab()
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