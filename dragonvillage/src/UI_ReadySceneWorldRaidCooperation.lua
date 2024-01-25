local PARENT = UI_ReadySceneWorldRaid
-------------------------------------
--- @class UI_ReadySceneWorldRaidCooperation
-------------------------------------
UI_ReadySceneWorldRaidCooperation = class(PARENT,{
})

-------------------------------------
-- function initDeck
-------------------------------------
function UI_ReadySceneWorldRaidCooperation:initDeck()
    local vars = self.vars
	self.m_readySceneDeck = UI_ReadySceneNew_Deck_WorldRaid(self)
    self.m_readySceneDeck:setOnDeckChangeCB(function() 
		self:refresh_combatPower()
		self:refresh_buffInfo()
        self:refresh_slotLight()
	end)
end

-------------------------------------
-- function initMultiDeckMode
-- @brief 멀티 덱 모드
-------------------------------------
function UI_ReadySceneWorldRaidCooperation:initMultiDeckMode()
    local make_deck = true
    self.m_multiDeckMgr = MultiDeckMgr_WorldRaid(MULTI_DECK_MODE.WORLD_RAID_COOPERATION, make_deck)
end

-------------------------------------
-- function refresh_slotLight
-------------------------------------
function UI_ReadySceneWorldRaidCooperation:refresh_slotLight()
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
