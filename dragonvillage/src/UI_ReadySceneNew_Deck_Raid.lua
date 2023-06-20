local PARENT = UI_ReadySceneNew_Deck
-------------------------------------
-- class UI_ReadySceneNew_Deck_Raid
-------------------------------------
UI_ReadySceneNew_Deck_Raid = class(PARENT, {
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

local TAB_ATTACK_1 = '1' -- 1 공격대 (상단)
local TAB_ATTACK_2 = '2' -- 2 공격대 (하단)
local TAB_ATTACK_3 = '3' -- 2 공격대 (하단)

-------------------------------------
-- function init
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:init()
end

-------------------------------------
-- function initUI
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:initUI()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리
    if (multi_deck_mgr) then
        vars['formationNode']:setPositionX(-225)
        vars['clanRaidMenu']:setVisible(true)
        vars['upRadioBtn']:setVisible(false)
        vars['downRadioBtn']:setVisible(false)
        vars['teamTabBtn3']:setVisible(true)

        vars['clanRaidMenu']:setPositionY(65)
        vars['cpNode2']:setPosition(cc.p(255, -20))
    end
end

-------------------------------------
-- function initTab
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:initTab()
    local vars = self.m_uiReadyScene.vars
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr

    -- 멀티 덱 처리 (제 1공격대, 2공격대 선택)
    if (multi_deck_mgr) then
        self.m_uiReadyScene:addTabWithLabel(TAB_ATTACK_1, vars['teamTabBtn1'], vars['teamTabLabel1'])
        self.m_uiReadyScene:addTabWithLabel(TAB_ATTACK_2, vars['teamTabBtn2'], vars['teamTabLabel2'])
        self.m_uiReadyScene:addTabWithLabel(TAB_ATTACK_3, vars['teamTabBtn3'], vars['teamTabLabel3'])
        
        do -- 디폴트 탭
            local deck_no = pl.stringx.replace(self.m_uiReadyScene.m_subInfo, 'league_raid_', '')
            self.m_selTab = deck_no
            self.m_uiReadyScene:setTab(deck_no)
        end

        self.m_uiReadyScene:setChangeTabCB(function(tab, first) self:onChangeTab(tab, first) end)
    end
end

-------------------------------------
-- function onChangeTab
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:onChangeTab(tab, first)
    if (self.m_selTab == tab) then return end
    
    self.m_selTab = tab
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    local deck_name = multi_deck_mgr:getDeckName(tab)

    do -- 타이틀 변경
        local deck_no = pl.stringx.replace(deck_name, 'league_raid_', '')
        local str = Str('레이드').. ' ' .. Str(tostring(deck_no) .. ' 공격대')
        self.m_uiReadyScene.m_titleStr = str
        g_topUserInfo:setTitleString(str)
    end

    local next_func = function()
        self.m_uiReadyScene.m_currTamerID = nil
        g_deckData:setSelectedDeck(deck_name)
        self:init_deck()
        self.m_uiReadyScene:apply_dragonSort()
    end

    if (deck_name) then
        self:checkChangeDeck(next_func)
    end
end

-------------------------------------
-- function onChangeOption
-- @brief
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:onChangeOption()
    local vars = self.m_uiReadyScene.vars
end
-------------------------------------
-- function click_dragonCard
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:click_dragonCard(t_dragon_data, skip_sort, idx)
    local doid = t_dragon_data['id']

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
-- function setSlot
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:setSlot(idx, doid, skip_sort)
    local cur_deck = self.m_selTab

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
        if ((multi_deck_mgr:checkSameDidAnoterDeck_Raid(doid))) then
            return false
        end
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
        g_friendData:delSettedFriendDragonCard(prev_doid)

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
        g_friendData:makeSettedFriendDragonCard(doid, idx)

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
-- function clear_deck
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:clear_deck(skip_sort)
     -- UI 정리
    if self.m_lSettedDragonCard then
        for _,ui in pairs(self.m_lSettedDragonCard) do
            ui.root:removeFromParent()
        end
    end
    self.m_lSettedDragonCard = {}
    

    local l_refresh_dragon_doid = clone(self.m_lDeckList)

    self.m_lDeckList = {}
    self.m_tDeckMap = {}

    -- 멀티 덱 해제
    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    if (multi_deck_mgr) then
        multi_deck_mgr:clearDeckMap(tonumber(self.m_selTab))
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
-- function setReadySpriteVisible
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:setReadySpriteVisible(ui, visible)
end

-------------------------------------
-- function refresh_dragonCard
-- @brief 장착여부에 따른 테이블뷰에 있는 카드 갱신
-------------------------------------
function UI_ReadySceneNew_Deck_Raid:refresh_dragonCard(doid, is_friend)
    local table_view = self.m_uiReadyScene.m_readySceneSelect:getTableView(is_friend)
    if (not table_view) then
        return
    end

    local item = table_view.m_itemMap[doid]
    local pos = nil

    local multi_deck_mgr = self.m_uiReadyScene.m_multiDeckMgr
    if (multi_deck_mgr) then
        pos = multi_deck_mgr:isSetDragon(doid)
    end

    --cclog('pos ~= nil, pos', pos ~= nil, pos, item['ui'] ~= nil)
    if (not item) then
        return
    end

    local ui = item['ui']
    if (not ui) then
        return
    end

    if pos ~= nil then
        ui:setTeamReadySpriteVisible(true, pos)
    else
        ui:setReadySpriteVisible(false)
    end

    --cca.uiReactionSlow(ui.root, DC_SCALE, DC_SCALE, DC_SCALE_PICK)
end