-------------------------------------
-- function makeTamerNew
-------------------------------------
function GameWorld:makeTamerNew(t_tamer_data, bRightFormation)
    self.m_tamer = Tamer('res/character/tamer/dede/dede.spine', {0, 0, 0})
    self.m_tamer.m_bLeftFormation = true

    self.m_tamer:initWorld(self)
    self.m_tamer.m_animator:setScale(0.5)
    self.m_tamer:initState()
    
    -- 기본 정보 저장
    --tamer.m_tamerID = dragon_id
    --tamer.m_charTable = t_dragon

    -- 피격 처리
    self.m_tamer:addDefCallback(function(attacker, defender, i_x, i_y)
    end)

    self:addToUnitList(self.m_tamer)
    self.m_worldNode:addChild(self.m_tamer.m_rootNode, WORLD_Z_ORDER.HERO)
    self.m_physWorld:addObject(PHYS.HERO, self.m_tamer)
    
    self.m_tamer:setOrgHomePos(70, -250)
    self.m_tamer:setPosition(70, -250)
    self.m_tamer:changeState('idle')
end

-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld:makeDragonNew(t_dragon_data, bRightFormation, status_calc)
    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = t_dragon_data
    local bLeftFormation = not bRightFormation

    local dragon_id = t_dragon_data['did']

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

	-- dragon 생성 시작
    local dragon = Dragon(nil, {0, 0, 20})
    self:addToUnitList(dragon)

    dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation)
	dragon:initState()
	dragon:initFormation()

    return dragon
end

-------------------------------------
-- function makeMonsterNew
-------------------------------------
function GameWorld:makeMonsterNew(monster_id, level)

    local t_monster = TableMonster():get(monster_id)

    if (not t_monster) then
        error(tostring('다음 ID는 존재하지 않습니다 : ' .. monster_id))
    end

    -- Monster 생성
	local body_size = Monster:getBodySize(t_monster['size_type'])
    local monster = self:tryPatternMonster(t_monster, body)
    if (not monster) then
        monster = Monster(t_monster['res'], body)
    end
    self:addToUnitList(monster)

	monster:init_monster(t_monster, monster_id, level, self.m_stageID)
    monster:initState()
	monster:initFormation(body_size)

	return monster
end

-------------------------------------
-- function tryPatternMonster
-- @brief 패턴을 가진 적군
-- ex) 'pattern_' + rarity + type
--     'pattern_boss_queenssnake'
-------------------------------------
function GameWorld:tryPatternMonster(t_monster, body)
    local rarity = t_monster['rarity']
    local type = t_monster['type']
    local script_name = 'pattern_' .. rarity .. '_' .. type    
    local is_boss = (rarity == 'boss')

    -- 테이블이 없을 경우 return
    local script = TABLE:loadJsonTable(script_name)
	local is_pattern_ignore = (t_monster['pattern'] == 'ignore')
	
    if (not script) or is_pattern_ignore then
        return nil
    end

    local monster
	
    if (type == 'giantdragon') then
        monster = Monster_GiantDragon(t_monster['res'], body)
    elseif (type == 'golddragon') then
        monster = Monster_GoldDragon(t_monster['res'], body)
    elseif (type == 'treant') then
        monster = Monster_Tree(t_monster['res'], body)
	elseif (type == 'world_order_machine') then
		monster = Monster_WorldOrderMachine(t_monster['res'], body)
    elseif (type == 'darknix') then
		monster = Monster_DarkNix(t_monster['res'], body)
    else
        monster = MonsterLua_Boss(t_monster['res'], body)
    end

    --monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
    monster:initScript(script_name, is_boss)
    
    return monster
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorld:makeHeroDeck()
    -- 서버에 저장된 드래곤 덱 사용
    local l_deck, formation = g_deckData:getDeck()
    self.m_deckFormation = formation

    for i, doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if (t_dragon_data) then
            local status_calc = MakeOwnDragonStatusCalculator(doid)
            local is_right = false
            local hero = self:makeDragonNew(t_dragon_data, is_right, status_calc)
            if (hero) then
                hero:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                self.m_physWorld:addObject(PHYS.HERO, hero)
                self:addHero(hero, tonumber(i))

                self:participationHero(hero)

                self.m_leftFormationMgr:setChangePosCallback(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, i)
                --ccdump(hero.m_statusCalc.m_lPassive)

                -- 친구 버프 적용
                if (g_friendBuff) then
                    local t_friend_buff = g_friendBuff:getBuffData()

                    hero.m_statusCalc:applyFriendBuff(t_friend_buff)
                end
            end
        end
    end
    
    -- 아군 드래곤들은 게이지를 조정
    do
        local t_percentage = { 60, 80 }
        local t_temp = { 20, 40 }

        for i = 1, 3 do
            table.insert(t_percentage, t_temp[math_random(1, 2)])
        end

        t_percentage = randomShuffle(t_percentage)

        for i, dragon in ipairs(self:getDragonList()) do
            dragon:initActiveSkillCool(t_percentage[i])
        end
    end
    
    -- 친구 접속 버프 적용
    local friend_online_buff = g_gameScene.m_totalOnlineBuffList -- g_gameScene말고 변수를 전달받아 처리할 것
    if friend_online_buff then
        for _,hero in pairs(self.m_mHeroList) do
            local status_calc = hero.m_statusCalc
            status_calc.m_lPassive['atk'] = (status_calc.m_lPassive['atk'] + (friend_online_buff['atk'] or 0))
            status_calc.m_lPassive['def'] = (status_calc.m_lPassive['def'] + (friend_online_buff['def'] or 0))
        end
    end
end

-------------------------------------
-- function makeFriendHero
-------------------------------------
function GameWorld:makeFriendHero()
    local t_dragon_data, l_runes_data = g_friendData:getParticipationFriendDragon()
    if (not t_dragon_data) then return end

    local status_calc = g_friendData:makeFriendDragonStatusCalculator(t_dragon_data, l_runes_data)
    local is_right = false

    self.m_friendHero = self:makeDragonNew(t_dragon_data, is_right, status_calc)

    if (self.m_friendHero) then
        self.m_friendHero:setActive(false)

        self.m_worldNode:addChild(self.m_friendHero.m_rootNode, WORLD_Z_ORDER.HERO)
    
        -- 현재 덱에 빈자리가 있다면 즉시 추가
        if (not self:isParticipantMaxCount()) then
            local temp = {}

            for i = 1, g_constant:get('INGAME', 'PARTICIPATE_DRAGON_CNT') do
                table.insert(temp, i)
            end
        
            for i, _ in pairs(self.m_mHeroList) do
                local idx = table.find(temp, i)
                table.remove(temp, idx)
            end

            temp = randomShuffle(temp)

            self:joinFriendHero(temp[1])

            self.m_bUsedFriend = true
        end
    end
end

-------------------------------------
-- function joinFriendHero
-------------------------------------
function GameWorld:joinFriendHero(posIdx)
    if (not self.m_friendHero) then return end

    self.m_friendHero:setPosIdx(posIdx)

    self.m_physWorld:addObject(PHYS.HERO, self.m_friendHero)
    self:addHero(self.m_friendHero, posIdx)
    self:participationHero(self.m_friendHero)

    self.m_leftFormationMgr:setChangePosCallback(self.m_friendHero)

    -- 진형 버프 적용
    self.m_friendHero.m_statusCalc:applyFormationBonus(self.m_deckFormation, posIdx)

    -- 친구 버프 적용
    if (g_friendBuff) then
        local t_friend_buff = g_friendBuff:getBuffData()

        self.m_friendHero.m_statusCalc:applyFriendBuff(t_friend_buff)
    end
end

-------------------------------------
-- function removeHeroDebuffs
-------------------------------------
function GameWorld:removeHeroDebuffs()
    for i, hero in ipairs(self:getDragonList()) do
        if (not hero.m_bDead) then
            StatusEffectHelper:releaseStatusEffectDebuff(hero)
        end
    end
end

-------------------------------------
-- function removeEnemyDebuffs
-------------------------------------
function GameWorld:removeEnemyDebuffs()
    for i, enemy in ipairs(self:getEnemyList()) do
        if (not enemy.m_bDead) then
            StatusEffectHelper:releaseStatusEffectDebuff(enemy)
        end
    end
end

-------------------------------------
-- function buffActivateAtStartup
-- @brief 시작 시 버프 발동
-------------------------------------
function GameWorld:buffActivateAtStartup()
    -- 테이머 버프
    if (self.m_gameTamer) then
        self.m_gameTamer:doSkillPassive()
    end

    -- 아군 버프
    for _, list in ipairs({self:getDragonList(), self:getEnemyList()}) do
        for _, unit in pairs(list) do
            unit:doSkill_passive()
        end
    end
    
    -- 친구 버프
end