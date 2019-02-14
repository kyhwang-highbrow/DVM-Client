local PARENT = GameWorldForDoubleTeam

-------------------------------------
-- class GameWorldClanRaid
-------------------------------------
GameWorldClanRaid = class(PARENT, {})
    
-------------------------------------
-- function init
-------------------------------------
function GameWorldClanRaid:init()
end

-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorldClanRaid:makePassiveStartEffect(char, str_map)
    local root_node = PARENT.makePassiveStartEffect(self, char, str_map)

    -- 보스의 경우는 충돌영역 위치로 표시
    if (isInstanceOf(char, Monster_ClanRaidBoss)) then
        -- 실시간 위치 동기화
        root_node:scheduleUpdateWithPriorityLua(function(dt)
            local x, y = char:getCenterPos()
            root_node:setPosition(x, y)
        end, 0)
    end
end

-------------------------------------
-- function onExterminateGroup
-- @brief 아군이나 적군 그룹 중 하나가 전멸되었을때 호출되는 함수
-------------------------------------
function GameWorldClanRaid:onExterminateGroup(group_key)
    PARENT.onExterminateGroup(self, group_key)

    if (group_key == PHYS.HERO_TOP or group_key == PHYS.HERO_BOTTOM) then
        -- 한 팀이 전멸해서 공격 그룹이 변경된 경우 특정 패턴은 못하도록 막기 위한 하드코딩
        for i, enemy in ipairs(self:getEnemyList()) do
            enemy:onChangedAttackableGroup()
        end
    end
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorldClanRaid:bindEnemy(enemy)
    PARENT.bindEnemy(self, enemy)
    
    -- 막타 데미지
    enemy:addListener('clan_boss_final_damage', self.m_gameState)
end

-------------------------------------
-- function removeAllEnemy
-- @brief
-------------------------------------
function GameWorldClanRaid:removeAllEnemy()
    for i, v in pairs(self.m_rightParticipants) do
		--cclog('REMOVE ALL ' .. v:getName())
        if (not v:isDead()) then
            v:doDie()
        end
    end

    for i, v in pairs(self.m_rightNonparticipants) do
        -- GameWorld:updateUnit에서 삭제하도록 하기 위함
        v.m_bPossibleRevive = false
    end
	
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function makeHeroDeck
-- @brief
-------------------------------------
function GameWorldClanRaid:makeHeroDeck()
    local g_data


    local attr = g_clanData:getCurSeasonBossAttr()
    g_data = MultiDeckMgr(MULTI_DECK_MODE.CLAN_RAID, nil, attr)


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
                    self:applyClanRaidStageBonus(hero)
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
                    self:applyClanRaidStageBonus(hero)
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
-- function applyClanRaidStageBonus
-- @brief
-------------------------------------
function GameWorldClanRaid:applyClanRaidStageBonus(dragon)

    local struct_raid = g_clanRaidData:getClanRaidStruct()
    local l_buff = struct_raid:getClanAttrBuffList()

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
                        dragon.m_statusCalc:setStageMulti(status_type, buff_value)
                    elseif (t_option['action'] == 'add') then
                        dragon.m_statusCalc:setStageAdd(status_type, buff_value)
                    end
                end
            end
        end
    end
end