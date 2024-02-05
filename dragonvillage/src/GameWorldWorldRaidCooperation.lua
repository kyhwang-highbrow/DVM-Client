local PARENT = GameWorldForDoubleTeam

-------------------------------------
-- class GameWorldWorldRaidCooperation
-------------------------------------
GameWorldWorldRaidCooperation = class(PARENT, {
    })

-------------------------------------
--- @function makeHeroDeck
--- @brief 덱 만들고 버프 부여하기
-------------------------------------
function GameWorldWorldRaidCooperation:makeHeroDeck()
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

                    -- 월드 레이드 버프 적용
                    self:applyWorldRaidBonus(hero)

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

                    -- 월드 레이드 버프 적용
                    self:applyWorldRaidBonus(hero)

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
--- @function applyWorldRaidBonus
--- @brief 스테이지 보너스 등록
-------------------------------------
function GameWorldWorldRaidCooperation:applyWorldRaidBonus(dragon)
    local world_raid_id = g_worldRaidData:getWorldRaidId()
    local l_buff = TableWorldRaidInfo:getInstance():getWorldRaidBuffAll(world_raid_id)

    for i, v in ipairs(l_buff) do
        local condition_type = v['condition_type']
        local condition_value = v['condition_value']

        if (condition_type == 'did' or condition_type == 'mid') then
            condition_value = tonumber(condition_value)
        end
        local t_char = dragon:getCharTable()
        if (v['condition_type'] == 'all' or condition_value == t_char[condition_type]) then
            local buff_type = v['buff_type']
            local buff_value = v['buff_value']
            local t_option = TableOption():get(buff_type)

            if (t_option) then
                local status_type = t_option['status']
                if (status_type) then
                    if (t_option['action'] == 'multi') then
                        dragon.m_statusCalc:addStageMulti(status_type, buff_value)
                        cclog(t_char['did'], '>>> status_type', status_type, buff_value)
                    elseif (t_option['action'] == 'add') then
                        dragon.m_statusCalc:addStageAdd(status_type, buff_value)
                        cclog(t_char['did'], '>>> status_type', status_type, buff_value)
                    end
                end
            end
        end
    end
end
