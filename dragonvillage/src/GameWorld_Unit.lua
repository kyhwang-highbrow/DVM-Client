-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld:makeDragonNew(t_dragon_data, bRightFormation, status_calc)
    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = t_dragon_data
    local bLeftFormation = true
    if bRightFormation then bLeftFormation = false end

    local dragon_id = t_dragon_data['did']

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local doid = t_dragon_data['id']
    local lv = t_dragon_data['lv'] or 1
    local grade = t_dragon_data['grade'] or 1
    local evolution = t_dragon_data['evolution'] or 1
	local attr = t_dragon['attr']

    local dragon = Dragon(nil, {0, 0, 20})
    dragon.m_bLeftFormation = bLeftFormation

    dragon:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
    dragon:initDragonSkillManager('dragon', dragon_id, evolution)
    dragon:initActiveSkillCoolTime() -- 액티브 스킬 쿨타임 지정
    dragon.m_tDragonInfo = t_dragon_data
    dragon:initAnimatorDragon(t_dragon['res'], evolution, attr)
    dragon.m_animator:setScale(0.5 * t_dragon['scale'])
    dragon:initState()
    dragon:setStatusCalc(status_calc)
    dragon:initStatus(t_dragon, lv, grade, evolution, doid)

    -- 기본 정보 저장
    dragon.m_dragonID = dragon_id
    dragon.m_charTable = t_dragon

    if bLeftFormation then
        dragon:changeState('idle')
    else
        dragon:changeState('move')
        dragon.m_animator:setFlip(true)
    end
    
    -- 피격 처리
    dragon:addDefCallback(function(attacker, defender, i_x, i_y)
        dragon:undergoAttack(attacker, defender, i_x, i_y)
    end)

    self:addToUnitList(dragon)
    dragon:makeHPGauge({0, -80})
	dragon:makeCastingNode()

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

    local body = {0, 0, 50}

    -- 사이즈 타입별 피격박스 반지름 변경
    local size_type = t_monster['size_type']
    if (size_type == 's') then
        body[3] = 30
    elseif (size_type == 'm') then
        body[3] = 40
    elseif (size_type == 'l') then
        body[3] = 60
    elseif (size_type == 'xl') then
        body[3] = 100
	elseif (size_type == 'xxl') then
        body[3] = 200
    end

    -- 난이도별 레벨 설정
    local t_drop = TABLE:get('drop')[self.m_stageID]
    local level = level + t_drop['level']
    
    local scale = 1
    local offset_y = (body[3] * 1.5)
    local hp_ui_offset = {0, -offset_y}
    local animator_scale = t_monster['scale'] or 1

    -- Monster 생성
    local monster = self:tryPatternMonster(t_monster, body)
    if (not monster) then
        monster = Monster(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
    end

    monster:initDragonSkillManager('monster', monster_id, 6) -- monster는 skill_1~skill_6을 모두 사용
    monster:initState()
    monster:initStatus(t_monster, level)
    monster:changeState('move')
    
    monster.m_animator.m_node:setScale(animator_scale)
    monster.m_animator:setFlip(true)

    -- 피격 처리
    monster:addDefCallback(function(attacker, defender, i_x, i_y)
        monster:undergoAttack(attacker, defender, i_x, i_y, 0)
    end)

    self:addToUnitList(monster)
    monster:makeHPGauge(hp_ui_offset)
    monster:makeCastingNode()
    
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
    elseif (type == 'treant') then
        monster = Monster_Tree(t_monster['res'], body)
	elseif (type == 'world_order_machine') then
		monster = Monster_WorldOrderMachine(t_monster['res'], body)
    elseif (type == 'darknix') then
		monster = Monster_DarkNix(t_monster['res'], body)
    else
        monster = MonsterLua_Boss(t_monster['res'], body)
    end

    monster:initAnimatorMonster(t_monster['res'], t_monster['attr'])
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

            for i = 1, PARTICIPATE_DRAGON_CNT do
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
    for _, list in ipairs({self:getDragonList(), self:getEnemyList()}) do
        for _, unit in pairs(list) do
            unit:doSkill_passive()
        end
    end

    -- 친구 버프

end