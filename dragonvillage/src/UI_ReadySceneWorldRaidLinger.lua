local PARENT = UI_ReadySceneWorldRaid
-------------------------------------
--- @class UI_ReadySceneWorldRaidLinger
-------------------------------------
UI_ReadySceneWorldRaidLinger = class(PARENT,{
})

-------------------------------------
-- function initDeck
-------------------------------------
function UI_ReadySceneWorldRaidLinger:initDeck()
    local vars = self.vars
	self.m_readySceneDeck = UI_ReadySceneNew_Deck_WorldRaid(self, 3)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
        self:refresh_slotLight()
        self:refresh_tamer()
        self:refresh_dragon_cards()
	end)
    
    self:refresh_dragon_cards()
end

-------------------------------------
-- function initMultiDeckMode
-- @brief 멀티 덱 모드
-------------------------------------
function UI_ReadySceneWorldRaidLinger:initMultiDeckMode()
    local make_deck = true
    self.m_multiDeckMgr = MultiDeckMgr_WorldRaid(MULTI_DECK_MODE.WORLD_RAID_LINGER, make_deck)
end

-------------------------------------
-- function refresh_slotLight
-------------------------------------
function UI_ReadySceneWorldRaidLinger:refresh_slotLight()
    local vars = self.vars
    local multi_deck_mgr = self.m_multiDeckMgr

    if (multi_deck_mgr) then
        local deck_count = multi_deck_mgr:getDeckCount()
        for i = 1, deck_count do
            local down_deck_cnt = multi_deck_mgr:getDeckDragonCnt(i)          
            local start_idx = (i - 1) * 5
            for idx = 1, 5 do
                local slot_light = vars['slotSprite'..(idx + start_idx)]
                local is_active = idx <= down_deck_cnt

                slot_light:setColor(COLOR['white'])
                slot_light:setVisible(is_active)
            end
        end
    end
end

-------------------------------------
-- function refresh_dragon_cards
-------------------------------------
function UI_ReadySceneWorldRaidLinger:refresh_dragon_cards()
    local table_view = self.m_readySceneSelect:getTableView(nil)
    if (not table_view) then
        return
    end
    
    for doid, t_data in pairs(table_view.m_itemMap) do
        self.m_readySceneDeck:refresh_dragonCard(doid)
    end
end


-------------------------------------
--- @function networkGameStart
--- @breif
-------------------------------------
function UI_ReadySceneWorldRaidLinger:networkGameStart()
    local function finish_cb(game_key)
        g_deckData:setSelectedDeck('world_raid_1')
        self:replaceGameScene(game_key)
    end

    local world_raid_id = self.m_subInfo['world_raid_id']
    --local deck_name = g_deckData:getSelectedDeckName()
    g_worldRaidData:request_WorldRaidStart(world_raid_id, self.m_stageID, finish_cb)
end

-------------------------------------
-- function click_autoBtn
-- @breif
-------------------------------------
function UI_ReadySceneWorldRaidLinger:click_autoBtn()
    local stage_id = self.m_stageID
    local formation = self.m_readySceneDeck.m_currFormation
    local l_dragon_list

    local game_mode = self.m_gameMode
    local multi_deck_mgr = self.m_multiDeckMgr

    -- 멀티덱 사용시 다른 위치 덱은 제외하고 추천    
    local mode = self.m_readySceneDeck.m_selTab
    local exist_dragons = multi_deck_mgr:getUsingDidTable()
    l_dragon_list = g_dragonsData:getDragonsListExceptTargetDoids(exist_dragons)
    
    local helper = DragonAutoSetHelperNew(stage_id, formation, l_dragon_list)
    local l_auto_deck = helper:getAutoDeck()
    
    self:applyDeck(l_auto_deck)
end