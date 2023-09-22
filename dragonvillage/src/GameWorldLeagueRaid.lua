local PARENT = GameWorld

-------------------------------------
-- class GameWorldArenaNew
-------------------------------------
GameWorldLeagueRaid = class(PARENT, {
        m_myDragons_1 = 'table',
        m_myDragons_2 = 'table',
        m_myDragons_3 = 'table',
    })



-------------------------------------
-- function initTamer
-------------------------------------
function GameWorldLeagueRaid:initTamer()
    local l_deck, formation, deck_name, leader, tamer_id = g_deckData:getDeck()
    local t_tamer_data = clone(g_tamerData:getTamerServerInfo(tamer_id))
    local t_costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
    
    -- 테이머 생성
    self.m_tamer = self:makeTamerNew(t_tamer_data, t_costume_data)

    -- 테이머 UI 생성
	self.m_inGameUI:initTamerUI(self.m_tamer)

    self:addListener('dragon_summon', self)
end



-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldLeagueRaid:makeHeroDeck()
    local deck_name = 'league_raid_' .. tostring(g_leagueRaidData.m_curDeckIndex)
    self:makeHeroDeck_internal(g_leagueRaidData.m_curDeckIndex)
end


-------------------------------------
-- function appearDragonsByIndex
-------------------------------------
function GameWorldLeagueRaid:appearDragonsByIndex(index)
    local is_first = index == 1
    local is_second = index == 2
    local is_third = index == 3

    for _, dragon_1 in pairs(self.m_myDragons_1) do
        if (dragon_1) then dragon_1.m_rootNode:setVisible(is_first) end
    end

    for _, dragon_2 in pairs(self.m_myDragons_2) do
        if (dragon_2) then dragon_2.m_rootNode:setVisible(is_second) end
    end

    for _, dragon_3 in pairs(self.m_myDragons_3) do
        if (dragon_3) then dragon_3.m_rootNode:setVisible(is_third) end
    end

    if (is_first) then self.m_myDragons = self.m_myDragons_1 end
    if (is_second) then self.m_myDragons = self.m_myDragons_2 end
    if (is_third) then self.m_myDragons = self.m_myDragons_3 end
end

-------------------------------------
-- function makeHeroDeck_internal
-------------------------------------
function GameWorldLeagueRaid:makeHeroDeck_internal(index)
    -- 서버에 저장된 드래곤 덱 사용
    local l_deck, formation, deck_name, leader = g_deckData:getDeck()
    local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- 팀보너스를 가져옴
    local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

    for i, v in ipairs(self.m_leftParticipants) do
        if (v.m_specialStatusIcon) then
            v.m_specialStatusIcon:setVisible(false)
            v.m_specialStatusIcon:setOverlabLabel(0)
            v.m_specialStatusIcon = nil
        end
    end

    for i, v in ipairs(self.m_leftNonparticipants) do
        if (v.m_specialStatusIcon) then
            v.m_specialStatusIcon:setVisible(false)
            v.m_specialStatusIcon:setOverlabLabel(0)
            v.m_specialStatusIcon = nil
        end
    end

    -- 부활 스킬 사용 시 대상을 현재 파티에서 가져오지 않는 현상 수정
    self.m_mUnitGroup[PHYS.HERO].m_lSurvivor = {}
    self.m_mUnitGroup[PHYS.HERO].m_lDead = {}
    self.m_mUnitGroup[PHYS.HERO].m_formationMgr = FormationMgr(true)

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}
    self.m_leftParticipants = {}
    self.m_leftNonparticipants = {}

    -- 친구 드래곤 출전
    self:makeFriendHero(deck_name)

    for i, doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if (t_dragon_data) then
            local status_calc = MakeOwnDragonStatusCalculator(doid)
            local is_right = false
            local hero = self:makeDragonNew(t_dragon_data, is_right, status_calc)
            if (hero) then
                self.m_myDragons[i] = hero
                hero:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                self.m_physWorld:addObject(PHYS.HERO, hero)
                self:bindHero(hero)
                self:addHero(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- 스테이지 버프 적용
                hero.m_statusCalc:applyStageBonus(self.m_stageID)
               
                hero:setStatusCalc(hero.m_statusCalc)

                -- 팀보너스 적용
                for i, teambonus_data in ipairs(l_teambonus_data) do
                    TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, hero)
                end

				-- 리더 등록
				if (i == leader) then
                    self.m_mUnitGroup[PHYS.HERO]:setLeader(hero)
				end
            end
        end
    end
end