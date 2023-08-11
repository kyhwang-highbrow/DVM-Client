-------------------------------------
-- function makeTamerNew
-------------------------------------
function GameWorld:makeTamerNew(t_tamer_data, t_costume_data, bRightFormation, bg_res_path)
    local t_tamer_data = t_tamer_data
    local bLeftFormation = not bRightFormation

    local tamer_id = t_tamer_data['tid']

    -- 테이블의 테이머 정보
    local t_tamer = TableTamer():get(tamer_id)
    local tamer_res = t_tamer['res_sd']

    -- 코스튬 적용
    if (t_costume_data) then
        tamer_res = t_costume_data:getResSD()
    end
    
    -- tamer 생성 시작
    local tamer = Tamer(tamer_res, {0, 0, 0})
    tamer.m_tamerID = t_tamer['tid']
    tamer.m_costumeData = t_costume_data
    tamer:initWorld(self)
    tamer:init_tamer(t_tamer_data, bLeftFormation)
    tamer:initFormation()
    tamer:initState()
        
    -- 피격 처리
    tamer:addDefCallback(function(attacker, defender, i_x, i_y)
    end)

    -- 배경 이펙트 추가
    if (isNullOrEmpty(bg_res_path) == false) then
        local bg_animator = MakeAnimator(bg_res_path)
        if bg_animator.m_node then
            tamer.m_rootNode:addChild(bg_animator.m_node, -1)
            bg_animator.m_node:setScale(1)
            bg_animator.m_node:setPositionX(25)
            bg_animator.m_node:setPositionY(0)
        end

        tamer.m_background = bg_animator
    end

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

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

	-- dragon 생성 시작
	local size = g_constant:get('INGAME', 'DRAGON_BODY_SIZE') or 20
    local dragon = Dragon(nil, {0, 0, size})

    self:addToUnitList(dragon)

    dragon:init_dragon(dragon_id, t_dragon_data, t_dragon, bLeftFormation, bPossibleRevive)

    if (status_calc) then
        dragon:setStatusCalc(status_calc)
    end

	dragon:initState()
	dragon:initFormation()

    local animator = dragon.m_animator
    if (animator) then
        animator.m_node:setMix('idle', 'idle', '0.5') 
    end

    if (self.m_gameMode ~= GAME_MODE_COLOSSEUM and
        self.m_gameMode ~= GAME_MODE_ARENA and
        self.m_gameMode ~= GAME_MODE_ARENA_NEW and
        self.m_gameMode ~= GAME_MODE_CHALLENGE_MODE and
        self.m_gameMode ~= GAME_MODE_EVENT_ARENA and
        bRightFormation) then

        -- 스테이지 버프 적용
        dragon.m_statusCalc:applyStageBonus(self.m_stageID, true)

        -- 광폭화 버프 적용
        self.m_gameState:applyAccumEnrage(dragon)

        -- 스테이지별 hp_ratio 적용.
        local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
        dragon.m_statusCalc:appendHpRatio(hp_ratio)
    
        dragon:setStatusCalc(dragon.m_statusCalc)
    end

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

    monster:init_monster(t_monster, monster_id, level)
    monster:initState()
	monster:initFormation(body_size)

    local body_list = TableMonsterHitPos():getBodyList(monster_id)
    if (body_list) then
        monster:initPhys(body_list)
    end

    -- 스테이지 버프 적용
    monster.m_statusCalc:applyStageBonus(self.m_stageID, true)

    -- 광폭화 버프 적용
    self.m_gameState:applyAccumEnrage(monster)

    -- 스테이지별 hp_ratio 적용(클랜 던전의 경우는 서버로부터 실제 체력값을 받음)
    if (self.m_gameMode ~= GAME_MODE_CLAN_RAID) then
        local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
        monster.m_statusCalc:appendHpRatio(hp_ratio)
    end
    
    monster:setStatusCalc(monster.m_statusCalc)
    self:dispatch('make_monster', {['monster']=monster})
	return monster
end


-------------------------------------
-- function createSummonObject
-------------------------------------
function GameWorld:createSummonObject(summonObj_id, level)

    local t_summonObj = TableSummonObject():get(summonObj_id)

    if (not t_summonObj) then
        error(tostring('소환체 ID가 존재하지 않습니다 : ' .. summonObj_id))
    end

    -- 소환체 생성
    -- 소환체 테이블의 size_type 받아서
    -- constant.json 에 있는 INGAME 필드에 담겨있는 값으로 설정
    local file_path = AnimatorHelper:getMonsterResName(t_summonObj['res'], t_summonObj['attr'])
	local body_size = SummonedCreature:getBodySize(t_summonObj['size_type'])
    summonedCreature = SummonedCreature(file_path, body_size)

    self:addToUnitList(summonedCreature)

    summonedCreature:init_creature(t_summonObj, summonObj_id, level)
    summonedCreature:initState()
	summonedCreature:initFormation(body_size)

    local body_list = TableMonsterHitPos():getBodyList(t_summonObj)
    if (body_list) then
        summonedCreature:initPhys(body_list)
    end

    -- 스테이지 버프 적용
    summonedCreature.m_statusCalc:applyStageBonus(self.m_stageID, true)

    -- 광폭화 버프 적용
    self.m_gameState:applyAccumEnrage(summonedCreature)

    -- 스테이지별 hp_ratio 적용(클랜 던전의 경우는 서버로부터 실제 체력값을 받음)
    if (self.m_gameMode ~= GAME_MODE_CLAN_RAID) then
        local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
        summonedCreature.m_statusCalc:appendHpRatio(hp_ratio)
    end
    
    summonedCreature:setStatusCalc(summonedCreature.m_statusCalc)
    self:dispatch('make_monster', {['monster']=summonedCreature})
	return summonedCreature
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
	local monster
	
    if (type == 'giantdragon') then
        monster = Monster_GiantDragon(t_monster['res'], body)
    elseif (type == 'jeweldragon') then
        monster = Monster_GoldDragon(t_monster['res'], body)
    elseif (type == 'treant') then
        monster = Monster_Tree(t_monster['res'], body)
	elseif (type == 'world_order_machine') then
		monster = Monster_WorldOrderMachine(t_monster['res'], body)
    elseif (type == 'darknix') then
		monster = Monster_DarkNix(t_monster['res'], body)
    elseif (string.find(type, 'clanraid_boss')) then
		monster = Monster_ClanRaidBoss(t_monster['res'], body)
    elseif (type == 'event_gmandragora') then
		monster = Monster_GiantMandragora(t_monster['res'], body)
    elseif (type == 'ancient_ruin_dragon') then
		monster = Monster_AncientRuinDragon(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'], nil, t_monster['size_type'])
        monster:initScript(script_name, t_monster['mid'], is_boss)
    elseif (type == 'runeguardian') then
        monster = MonsterLua_BossUseDeadMotion(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'], nil, t_monster['size_type'])
        monster:initScript(script_name, t_monster['mid'], is_boss)

    elseif (script and not is_pattern_ignore) then
        monster = MonsterLua_Boss(t_monster['res'], body)
        monster:initAnimatorMonster(t_monster['res'], t_monster['attr'], nil, t_monster['size_type'])
        monster:initScript(script_name, t_monster['mid'], is_boss)
    else
        return nil
    end
        
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

    -- 팀보너스를 가져옴
    local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

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
                self:bindHero(hero)
                self:addHero(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- 스테이지 버프 적용
                hero.m_statusCalc:applyStageBonus(self.m_stageID)

                -- 라테아 버프 적용
                hero.m_statusCalc:applyLateaBuffs(g_lateaData:getMyLateaBuffIdList())

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

-------------------------------------
-- function makeFriendHero
-------------------------------------
function GameWorld:makeFriendHero()
    -- 이미 출전 드래곤이 5마리이면 패스시킴
    if (self.m_leftParticipants and table.count(self.m_leftParticipants) >= 5) then
        return
    end

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
    self:bindHero(self.m_friendDragon)
    self:addHero(self.m_friendDragon)
    
    -- 진형 버프 적용
    self.m_friendDragon.m_statusCalc:applyFormationBonus(self.m_deckFormation, self.m_deckFormationLv, posIdx)

    -- 스테이지 버프 적용
    self.m_friendDragon.m_statusCalc:applyStageBonus(self.m_stageID)

    -- 친구 라테아 버프 적용(삼뉴체크)
    self.m_friendDragon.m_statusCalc:applyLateaBuffs()

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
        self.m_tamer:doSkill_passive()
    end

    -- 아군 버프
    for _, dragon in ipairs(self:getDragonList()) do
		dragon:doSkill_passive()
    end
    
	-- 아군 리더 버프
    self.m_mUnitGroup[PHYS.HERO]:doSkill_leader()
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
    local group_key = hero:getPhysGroup()
    self.m_mUnitGroup[group_key]:joinUnit(hero)

    -- 이벤트
    hero:addListener('set_global_cool_time_active', self.m_gameCoolTime)
    
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

    local group_key = hero:getPhysGroup()
    self.m_mUnitGroup[group_key]:addSurvivor(hero)

    hero:setActive(true)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorld:removeHero(hero)
    local idx = table.find(self.m_leftParticipants, hero)
    if (idx) then
        table.remove(self.m_leftParticipants, idx)
    end

    idx = table.find(self.m_leftNonparticipants, hero)
    if (hero.m_bPossibleRevive) then
        if (not idx) then
            table.insert(self.m_leftNonparticipants, hero)
        end
    else
        if (idx) then
            table.remove(self.m_leftNonparticipants, idx)
        end
    end

    local group_key = hero:getPhysGroup()
    local unit_group = self.m_mUnitGroup[group_key]
    if (unit_group) then
        unit_group:removeSurvivor(hero)
    end

    hero:setActive(false)
end

-------------------------------------
-- function bindEnemy
-------------------------------------
function GameWorld:bindEnemy(enemy)
    local group_key = enemy:getPhysGroup()
    self.m_mUnitGroup[group_key]:joinUnit(enemy)

    -- 이벤트
    enemy:addListener('enemy_appear_done', self.m_gameState)

    if (enemy.m_charType == 'dragon') then
        enemy:addListener('set_global_cool_time_active', self.m_gameCoolTime)
        enemy:addListener('dragon_active_skill', self)
    end

    -- 월드에서 중계되는 이벤트
    enemy:addListener('character_recovery', self)
    enemy:addListener('character_dead', self)
    enemy:addListener('character_set_hp', self)
    enemy:addListener('get_status_effect', self)

    -- 모드별 이벤트
    local game_mode = g_stageData:getGameMode(self.m_stageID) -- @jhakim 190604 환상던전이 황금던전 모드를 사용하는 중, 게임모드가 환상던전이라면 이 함수에서 사용하는 모드를 환상던전으로 변경
    if (game_mode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
        game_mode = GAME_MODE_EVENT_ILLUSION_DUNSEON
    else
        game_mode = self.m_gameMode
    end

    if (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
        -- 딜량에 따른 총 점수 계산을 위함
        enemy:addListener('character_set_damage', self.m_gameState)

        -- 전투 중에 드랍
        enemy:addListener('drop_gold', self.m_dropItemMgr)

        -- 전투 시간 종료 후 드랍
        enemy:addListener('drop_gold_final', self.m_dropItemMgr)

    elseif (self.m_dropItemMgr) then
        -- 완전히 죽었을 경우 드랍되도록 함
        enemy:addListener('character_dead', self.m_dropItemMgr)

    end
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

    local group_key = enemy:getPhysGroup()
    self.m_mUnitGroup[group_key]:addSurvivor(enemy)

    enemy:setActive(true)
end

-------------------------------------
-- function removeEnemy
-------------------------------------
function GameWorld:removeEnemy(enemy)
    local idx = table.find(self.m_rightParticipants, enemy)
    if (idx) then
        table.remove(self.m_rightParticipants, idx)
    end

    idx = table.find(self.m_rightNonparticipants, enemy)
    if (enemy.m_bPossibleRevive) then
        if (not idx) then
            table.insert(self.m_rightNonparticipants, enemy)
        end
    else
        if (idx) then
            table.remove(self.m_rightNonparticipants, idx)
        end
    end

    local group_key = enemy:getPhysGroup()
    self.m_mUnitGroup[group_key]:removeSurvivor(enemy)

    enemy:setActive(false)
end

-------------------------------------
-- function removeAllHero
-- @brief
-------------------------------------
function GameWorld:removeAllHero()
    for i,v in pairs(self.m_leftParticipants) do
        v.m_resurrect = false

        if (not v:isDead()) then
            v:changeState('dying')

            local effect = self:addInstantEffect('res/effect/tamer_magic_1/tamer_magic_1.vrp', 'bomb', v.pos['x'], v.pos['y'])
            if (effect) then
                effect:setScale(0.8)
            end
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
    for i, v in pairs(self.m_rightParticipants) do
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

-------------------------------------
-- function getEnemyList
-------------------------------------
function GameWorld:getEnemyList(char)
    if (char) then
        -- char는 Character클래스가 아닐 수 있다
        local group_key = char['phys_key']

        return self.m_mUnitGroup[group_key]:getSurvivorList()
    else
        return self.m_rightParticipants
    end
end

-------------------------------------
-- function getEnemyCount
-- 소환체를 제외한 적 숫자
-------------------------------------
function GameWorld:getEnemyCount()
   local count = 0

   if (not self.m_rightParticipants) then return count end

   for _, v in ipairs(self.m_rightParticipants) do
        if (v and v.m_charTable and v.m_charTable['attacked_type']) then
            -- DO NOTHING
        else
            count = count + 1
        end
   end

   return count
end

-------------------------------------
-- function getDragonList
-- @brief char가 소속된 그룹의 살아있는 아군 리스트를 반환
-------------------------------------
function GameWorld:getDragonList(char)
    if (char) then
        -- char는 Character클래스가 아닐 수 있다
        local group_key = char['phys_key']
        return self.m_mUnitGroup[group_key]:getSurvivorList()
    else
        return self.m_leftParticipants
    end
end

-------------------------------------
-- function getDeadList
-- @brief char가 소속된 그룹의 죽은 아군 리스트를 반환
-------------------------------------
function GameWorld:getDeadList(char)
    if (char) then
        local group_key = char['phys_key']
        if (self.m_mUnitGroup[group_key]) then
            return self.m_mUnitGroup[group_key]:getDeadList()
        end
    end

    return nil
end

-------------------------------------
-- function getUnitGroupConsideredTamer
-- @brief unit에 대응하는 GameUnitGroup을 리턴(테이머의 경우는 조작중인 덱을 가져옴)
-------------------------------------
function GameWorld:getUnitGroupConsideredTamer(unit)
    local group_key = unit:getPhysGroup()
    local unit_group = self.m_mUnitGroup[group_key]

    if (not unit_group) then
        if (unit.m_bLeftFormation) then
            group_key = self:getPCGroup()
        else
            group_key = self:getOpponentPCGroup()
        end

        unit_group = self.m_mUnitGroup[group_key]
    end

    return unit_group
end

-------------------------------------
-- function initActiveSkillCool
-- @brief 전투 시작 시 드래곤별 액티스 스킬 쿨타임 설정
-- @param dragon_list(list[Dragon]) Dragon클래스의 리스트
-------------------------------------
function GameWorld:initActiveSkillCool(dragon_list)

    -- 고대의 탑 모드일 경우 (고대의 탑, 시험의 탑) 모든 드래곤의 시작 쿨타임을 동일하게 설정
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        for i, dragon in ipairs(dragon_list) do
            dragon:initActiveSkillCool(5)
        end
        return
    end

    local temp = { 3, 3, 7, 7, 7 }
    temp = randomShuffle(temp)

    for i, v in ipairs(dragon_list) do
        v:initActiveSkillCool(temp[i])
    end
end