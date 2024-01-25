local PARENT = GameWorld

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldForDoubleTeam:makeHeroDeck()
    local g_data

    if (self.m_gameMode == GAME_MODE_CLAN_RAID) then
        local attr = TableStageData:getStageAttr(self.m_stageID) 
        g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)

    elseif (self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
        g_data = MultiDeckMgr(MULTI_DECK_MODE.ANCIENT_RUIN)

    elseif (self.m_gameMode == GAME_MODE_WORLD_RAID) then
        g_data = MultiDeckMgr_WorldRaid(MULTI_DECK_MODE.WORLD_RAID_COOPERATION)


    else
        error('invalid game mode : ' .. self.m_gameMode)
    end

    -- 조작할 그룹을 설정
    local sel_deck = g_data:getMainDeck()
    local str_main_deck_name
    local str_sub_deck_name

    if (sel_deck == 'up') then
        main_deck_name = g_data:getDeckName('up')
        sub_deck_name = g_data:getDeckName('down')

    elseif (sel_deck == 'down') then
        main_deck_name = g_data:getDeckName('down')
        sub_deck_name = g_data:getDeckName('up')

    else
        error('invalid sel_deck : ' .. sel_deck)
    end


    self.m_myDragons = {}

    -- 조작할 수 있는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(main_deck_name)
        local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
        self.m_deckFormation = formation
        self.m_deckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
        for i, doid in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            if (t_dragon_data) then
                local status_calc = MakeOwnDragonStatusCalculator(doid)
                local hero = self:makeDragonNew(t_dragon_data, false, status_calc)
                if (hero) then
                    self.m_myDragons[i] = hero
                    hero:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                    self.m_physWorld:addObject(self:getPCGroup(), hero)
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
					    self.m_mUnitGroup[self:getPCGroup()]:setLeader(hero)
				    end
                end
            end
        end
    end

    -- 조작할 수 없는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(sub_deck_name)
        local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
        self.m_subDeckFormation = formation
        self.m_subDeckFormationLv = formation_lv

        -- 팀보너스를 가져옴
        local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

        for i, doid in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            if (t_dragon_data) then
                local status_calc = MakeOwnDragonStatusCalculator(doid)
                local hero = self:makeDragonNew(t_dragon_data, false, status_calc)
                if (hero) then
                    self.m_myDragons[5 + i] = hero
                    hero:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                    self.m_physWorld:addObject(self:getNPCGroup(), hero)
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
					    self.m_mUnitGroup[self:getNPCGroup()]:setLeader(hero)
				    end
                end
            end
        end
    end
end

-------------------------------------
-- function passiveActivate_Left
-- @brief 시작 시 패시브 발동
-------------------------------------
function GameWorldForDoubleTeam:passiveActivate_Left()
    -- 테이머 버프
    if (self.m_tamer) then
        self.m_tamer:doSkill_passive()
    end

    -- 아군 버프
    for _, dragon in ipairs(self:getDragonList()) do
		dragon:doSkill_passive()
    end
    
	-- 아군 리더 버프
    self.m_mUnitGroup[self:getPCGroup()]:doSkill_leader()
    self.m_mUnitGroup[self:getNPCGroup()]:doSkill_leader()
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorldForDoubleTeam:removeHero(hero)
    local group_key = hero:getPhysGroup()
    local unit_group = self.m_mUnitGroup[group_key]
    
    PARENT.removeHero(self, hero)

    -- 팀 전멸 시 함수 호출
    if (unit_group and unit_group:getSurvivorCount() <= 0) then
        self:onExterminateGroup(group_key)
    end
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorldForDoubleTeam:bindEnemy(enemy)
    PARENT.bindEnemy(self, enemy)

    -- 보스 체력 공유 처리를 위함
    if (self.m_waveMgr:isFinalWave() and enemy:isBoss()) then
        enemy:addListener('character_set_hp', self.m_gameState)
    end
end

-------------------------------------
-- function removeEnemy
-------------------------------------
function GameWorldForDoubleTeam:removeEnemy(enemy)
    local group_key = enemy:getPhysGroup()
    
    PARENT.removeEnemy(self, enemy)

    -- 팀 전멸 시 함수 호출
    if (self.m_mUnitGroup[group_key]:getSurvivorCount() <= 0) then
        self:onExterminateGroup(group_key)
    end
end