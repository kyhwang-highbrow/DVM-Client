-------------------------------------
-- function makeTamerNew
-------------------------------------
function GameWorld:makeTamerNew(t_tamer_data, bRightFormation)
    local t_tamer_data = t_tamer_data
    local bLeftFormation = not bRightFormation

    local tamer_id = t_tamer_data['tid']

    -- 테이블의 테이머 정보
    local t_tamer = TableTamer():get(tamer_id)

    -- tamer 생성 시작
    local tamer = Tamer(t_tamer['res_sd'], {0, 0, 0})
    tamer.m_tamerID = t_tamer['tid']
    
    tamer:initWorld(self)
    tamer:init_tamer(t_tamer_data, bLeftFormation)
    tamer:initFormation()
    tamer:initState()
        
    -- 피격 처리
    tamer:addDefCallback(function(attacker, defender, i_x, i_y)
    end)

    self:addToUnitList(tamer)
    self.m_worldNode:addChild(tamer.m_rootNode, WORLD_Z_ORDER.TAMER)
    self.m_physWorld:addObject(PHYS.TAMER, tamer)
    
    tamer:setAnimatorScale(0.5)
    tamer:changeState('idle')

    if (bLeftFormation) then
        tamer:setOrgHomePos(70, -250)
        tamer:setPosition(70, -250)
    else
        tamer:setOrgHomePos(CRITERIA_RESOLUTION_X - 70, -250)
        tamer:setPosition(CRITERIA_RESOLUTION_X - 70, -250)
    end

    return tamer
end

-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld:makeDragonNew(t_dragon_data, bRightFormation, status_calc)
    local t_dragon_data = t_dragon_data
    local bLeftFormation = not bRightFormation
    local bPossibleRevive = true

    local dragon_id = t_dragon_data['did']

    do -- 구현된 드래곤 인지 확인, 구현되지 않은 드래곤일 경우 치환
        dragon_id = TableDragon:getImplementedDid(dragon_id)
        t_dragon_data['did'] = dragon_id
    end

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

	-- dragon 생성 시작
	local size = g_constant:get('INGAME', 'DRAGON_BODY_SIZE') or 20
    local dragon = Dragon(nil, {0, 0, size})
    self:addToUnitList(dragon)

    if (bRightFormation) then
        self:bindEnemy(dragon)
    else
        self:bindHero(dragon)
    end

    dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation, bPossibleRevive)

    if (status_calc) then
        dragon:setStatusCalc(status_calc)
    end

	dragon:initState()
	dragon:initFormation()

    self:dispatch('make_dragon', {['dragon']=dragon, ['is_right']=bRightFormation})

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
    local monster = self:tryPatternMonster(t_monster, body_size)
    if (not monster) then
        monster = Monster(t_monster['res'], body_size)
    end
    self:addToUnitList(monster)
    self:bindEnemy(monster)

    monster:init_monster(t_monster, monster_id, level)
    monster:initState()
	monster:initFormation(body_size)

    local body_list = TableMonsterHitPos():getBodyList(monster_id)
    if (body_list) then
        monster:initPhys(body_list)
    end

    -- 스테이지 버프 적용
    monster.m_statusCalc:applyStageBonus(self.m_stageID, true)
    
    -- 고대의 탑일 경우 도전횟수에 따른 디버프 적용
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        local value = g_ancientTowerData:getEnemyDeBuffValue()
        if (value < 0) then
            monster.m_statusCalc:addBuffMulti('atk', value)
            monster.m_statusCalc:addBuffMulti('def', value)
            monster.m_statusCalc:addBuffMulti('hp', value)
        end
    end

    -- 스테이지별 hp_ratio 적용.
    local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
    monster.m_statusCalc:appendHpRatio(hp_ratio)
    
    monster:setStatusCalc(monster.m_statusCalc)
    self:dispatch('make_monster', {['monster']=monster})
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
    local script = TABLE:loadPatternScript(script_name)
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

    monster:initAnimatorMonster(t_monster['res'], t_monster['attr'], nil, t_monster['size_type'])
    monster:initScript(script_name, t_monster['mid'], is_boss)
    
    return monster
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorld:makeHeroDeck()
    -- 서버에 저장된 드래곤 덱 사용
    local l_deck, formation, deck_name, leader = g_deckData:getDeck()
    local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}

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
                self:addHero(hero)

                self.m_leftFormationMgr:setChangePosCallback(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- 스테이지 버프 적용
                hero.m_statusCalc:applyStageBonus(self.m_stageID)
                hero:setStatusCalc(hero.m_statusCalc)

				-- 리더 등록
				if (i == leader) then
					self.m_leaderDragon = hero
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

    self.m_friendDragon = self:makeDragonNew(t_dragon_data, is_right, status_calc)

    if (self.m_friendDragon) then
        self.m_friendDragon:setActive(false)

        self.m_worldNode:addChild(self.m_friendDragon.m_rootNode, WORLD_Z_ORDER.HERO)
        
        local idx = g_friendData:getFriendDragonSlotIdx()
        if (idx) then
            self:joinFriendHero(idx)
            self.m_bUsedFriend = true
        end
    end
end

-------------------------------------
-- function joinFriendHero
-------------------------------------
function GameWorld:joinFriendHero(posIdx)
    if (not self.m_friendDragon) then return end

    self.m_friendDragon:setPosIdx(posIdx)

    self.m_physWorld:addObject(PHYS.HERO, self.m_friendDragon)
    self:addHero(self.m_friendDragon)
    
    self.m_leftFormationMgr:setChangePosCallback(self.m_friendDragon)

    -- 진형 버프 적용
    self.m_friendDragon.m_statusCalc:applyFormationBonus(self.m_deckFormation, self.m_deckFormationLv, posIdx)

    -- 스테이지 버프 적용
    self.m_friendDragon.m_statusCalc:applyStageBonus(self.m_stageID)
    self.m_friendDragon:setStatusCalc(self.m_friendDragon.m_statusCalc)

    -- 친구 드래곤 전투 통계 추가
    self.m_myDragons[posIdx] = self.m_friendDragon
end

-------------------------------------
-- function removeHeroDebuffs
-------------------------------------
function GameWorld:removeHeroDebuffs()
    for i, hero in ipairs(self:getDragonList()) do
        StatusEffectHelper:releaseStatusEffectDebuff(hero)
    end
end

-------------------------------------
-- function removeEnemyDebuffs
-------------------------------------
function GameWorld:removeEnemyDebuffs()
    for i, enemy in ipairs(self:getEnemyList()) do
        StatusEffectHelper:releaseStatusEffectDebuff(enemy)
    end
end

-------------------------------------
-- function passiveActivate_Left
-- @brief 시작 시 패시브 발동
-------------------------------------
function GameWorld:passiveActivate_Left()
    -- 테이머 버프
    if (self.m_tamer) then
        self.m_tamer:doSkillPassive()
    end

    -- 아군 버프
    for _, dragon in ipairs(self:getDragonList()) do
		dragon:doSkill_passive()
    end
    
	-- 아군 리더 버프
	if (self.m_leaderDragon) then
		self.m_leaderDragon:doSkill_leader()
	end
end

-------------------------------------
-- function passiveActivate_Right
-- @brief 패시브 발동
-------------------------------------
function GameWorld:passiveActivate_Right()
    -- 적 버프
    for _, monster in ipairs(self:getEnemyList()) do
		monster:doSkill_passive()
    end
end

-------------------------------------
-- function bindHero
-------------------------------------
function GameWorld:bindHero(hero)
    hero:addListener('dragon_active_skill', self.m_gameDragonSkill)
    hero:addListener('dragon_active_skill', self.m_heroMana)
    hero:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    hero:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- 자동 AI를 위한 이벤트
    hero:addListener('hero_active_skill', self.m_gameAutoHero)
    --hero:addListener('get_debuff', self.m_gameAutoHero)
    --hero:addListener('release_debuff', self.m_gameAutoHero)
    
    -- 월드에서 중계되는 이벤트
    hero:addListener('character_recovery', self)
    hero:addListener('character_set_hp', self)
    hero:addListener('character_dead', self)
    hero:addListener('get_status_effect', self)
    hero:addListener('dragon_active_skill', self)
end

-------------------------------------
-- function addHero
-------------------------------------
function GameWorld:addHero(hero)
    local idx = table.find(self.m_leftParticipants, hero)
    if (not idx) then
        table.insert(self.m_leftParticipants, hero)
    end

    idx = table.find(self.m_leftNonparticipants, hero)
    if (idx) then
        table.remove(self.m_leftNonparticipants, idx)
    end

    hero:setActive(true)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorld:removeHero(hero)
    hero:setActive(false)

    local idx = table.find(self.m_leftParticipants, hero)
    if (idx) then
        table.remove(self.m_leftParticipants, idx)
    end

    idx = table.find(self.m_leftNonparticipants, hero)
    if (not idx) then
        table.insert(self.m_leftNonparticipants, hero)
    end

    -- 게임 종료 체크(모든 영웅이 죽었을 경우)
    local hero_count = #self:getDragonList()
    if (hero_count <= 0) then
        self.m_gameState:changeState(GAME_STATE_FAILURE)
    end
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorld:bindEnemy(enemy)
    if self.m_dropItemMgr then
        enemy:addListener('character_dead', self.m_dropItemMgr)
    end
    
    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_gameState)

    if (enemy.m_charType == 'dragon') then
        enemy:addListener('dragon_active_skill', self.m_gameDragonSkill)
        enemy:addListener('dragon_active_skill', self.m_enemyMana)
        
        if (self.m_gameAutoEnemy) then
            -- 자동 AI를 위한 이벤트
            enemy:addListener('enemy_active_skill', self.m_gameAutoEnemy)
            --enemy:addListener('get_debuff', self.m_gameAutoEnemy)
            --enemy:addListener('release_debuff', self.m_gameAutoEnemy)
        end
    end

    -- 월드에서 중계되는 이벤트
    enemy:addListener('character_recovery', self)
    enemy:addListener('character_dead', self)
    enemy:addListener('character_set_hp', self)
    enemy:addListener('get_status_effect', self)
end

-------------------------------------
-- function addEnemy
-------------------------------------
function GameWorld:addEnemy(enemy)
    local idx = table.find(self.m_rightParticipants, enemy)
    if (not idx) then
        table.insert(self.m_rightParticipants, enemy)
    end

    idx = table.find(self.m_rightNonparticipants, enemy)
    if (idx) then
        table.remove(self.m_rightNonparticipants, idx)
    end

    enemy:setActive(true)
end

-------------------------------------
-- function removeEnemy
-------------------------------------
function GameWorld:removeEnemy(enemy)
    enemy:setActive(false)

    local idx = table.find(self.m_rightParticipants, enemy)
    if (idx) then
        table.remove(self.m_rightParticipants, idx)
    end

    idx = table.find(self.m_rightNonparticipants, enemy)
    if (not idx) then
        table.insert(self.m_rightNonparticipants, enemy)
    end
end

-------------------------------------
-- function removeAllHero
-- @brief
-------------------------------------
function GameWorld:removeAllHero()
    for i,v in pairs(self:getDragonList()) do
        if (not v:isDead()) then
            v:changeState('dying')

            local effect = self:addInstantEffect('res/effect/tamer_magic_1/tamer_magic_1.vrp', 'bomb', v.pos['x'], v.pos['y'])
            effect:setScale(0.8)
        end
    end
    for i, v in pairs(self.m_leftNonparticipants) do
        -- GameWorld:updateUnit에서 삭제하도록 하기 위함
        v.m_bPossibleRevive = false
    end
end

-------------------------------------
-- function removeAllEnemy
-- @brief
-------------------------------------
function GameWorld:removeAllEnemy()
    for i, v in pairs(self:getEnemyList()) do
		--cclog('REMOVE ALL ' .. v:getName())
        if (not v:isDead()) then
            v:changeState('dying')
        end
    end

    for i, v in pairs(self.m_rightNonparticipants) do
        -- GameWorld:updateUnit에서 삭제하도록 하기 위함
        v.m_bPossibleRevive = false
    end
	
    self.m_waveMgr:clearDynamicWave()
end