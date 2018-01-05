-------------------------------------
-- function makeTamerNew
-------------------------------------
function GameWorldClanRaid:makeTamerNew(t_tamer_data, t_costume_data, bRightFormation)
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
function GameWorldClanRaid:makeDragonNew(t_dragon_data, bRightFormation, status_calc)
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
function GameWorldClanRaid:makeMonsterNew(monster_id, level)

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

    -- 전투 시간 버프 적용
    self.m_gameState:applyAccumBuffByFightTime(monster)

    -- 스테이지별 hp_ratio 적용.
    --[[
    local hp_ratio = TableStageData():getValue(self.m_stageID, 'hp_ratio') or 1
    monster.m_statusCalc:appendHpRatio(hp_ratio)
    ]]--
    
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
function GameWorldClanRaid:tryPatternMonster(t_monster, body)
    local rarity = t_monster['rarity']
    local type = t_monster['type']
    local script_name = 'pattern_' .. rarity .. '_' .. type    
    local is_boss = (rarity == 'boss')

    -- 테이블이 없을 경우 return
    local script = TABLE:loadPatternScript(script_name)
	local is_pattern_ignore = (t_monster['pattern'] == 'ignore')
	local monster = Monster_ClanRaidBoss(t_monster['res'], body)
	return monster
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldClanRaid:makeHeroDeck()
    -- 조작할 그룹을 설정
    local sel_deck = g_clanRaidData:getMainDeck()
    local str_main_deck_name
    local str_sub_deck_name

    if (sel_deck == 'up') then
        main_deck_name = g_clanRaidData:getDeckName('up')
        sub_deck_name = g_clanRaidData:getDeckName('down')

    elseif (sel_deck == 'down') then
        main_deck_name = g_clanRaidData:getDeckName('down')
        sub_deck_name = g_clanRaidData:getDeckName('up')

    else
        error('invalid sel_deck : ' .. sel_deck)
    end

    -- 조작할 수 있는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(main_deck_name)
        local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
        self.m_deckFormation = formation
        self.m_deckFormationLv = formation_lv

        -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
        self.m_myDragons = {}

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

    -- 조작할 수 없는 덱을 가져옴
    do
        local l_deck, formation, deck_name, leader = g_deckData:getDeck(sub_deck_name)
        local formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    
        self.m_subDeckFormation = formation
        self.m_subDeckFormationLv = formation_lv

        for i, doid in pairs(l_deck) do
            local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
            if (t_dragon_data) then
                local status_calc = MakeOwnDragonStatusCalculator(doid)
                local hero = self:makeDragonNew(t_dragon_data, false, status_calc)
                if (hero) then
                    hero:setPosIdx(tonumber(i))

                    self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                    self.m_physWorld:addObject(self:getNPCGroup(), hero)
                    self:bindHero(hero)
                    self:addHero(hero)

                    self.m_subLeftFormationMgr:setChangePosCallback(hero)

                    -- 진형 버프 적용
                    hero.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                    -- 스테이지 버프 적용
                    hero.m_statusCalc:applyStageBonus(self.m_stageID)
                    hero:setStatusCalc(hero.m_statusCalc)

				    -- 리더 등록
				    if (i == leader) then
					    self.m_subLeaderDragon = hero
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
function GameWorldClanRaid:passiveActivate_Left()
    -- 테이머 버프
    if (self.m_tamer) then
        self.m_tamer:doSkill_passive()
    end

    -- 아군 버프
    for _, dragon in ipairs(self:getDragonList()) do
		dragon:doSkill_passive()
    end
    
	-- 아군 리더 버프
	if (self.m_leaderDragon) then
		self.m_leaderDragon:doSkill_leader()
	end
    if (self.m_subLeaderDragon) then
		self.m_subLeaderDragon:doSkill_leader()
	end
end

-------------------------------------
-- function passiveActivate_Right
-- @brief 패시브 발동
-------------------------------------
function GameWorldClanRaid:passiveActivate_Right()
    -- 적 버프
    for _, monster in ipairs(self:getEnemyList()) do
		monster:doSkill_passive()
    end
end

-------------------------------------
-- function bindHero
-------------------------------------
function GameWorldClanRaid:bindHero(hero)
    local group_key = hero:getPhysGroup()
    local game_mana
    local game_auto

    if (group_key == self:getNPCGroup()) then
        game_mana = self.m_subHeroMana
        game_auto = self.m_subHeroAuto
    else
        game_mana = self.m_heroMana
        game_auto = self.m_heroAuto
    end

    hero:addListener('dragon_active_skill', self.m_gameDragonSkill)
    hero:addListener('dragon_active_skill', game_mana)
    hero:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    hero:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- 자동 AI를 위한 이벤트
    hero:addListener('hero_active_skill', game_auto)
        
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
function GameWorldClanRaid:addHero(hero)
    local group_key = hero:getPhysGroup()
    local participants = {}
    local nonparticipants = {}

    if (group_key == self:getPCGroup()) then
        participants = self.m_leftParticipants
        nonparticipants = self.m_leftNonparticipants

    elseif (group_key == self:getNPCGroup()) then
        participants = self.m_subLeftParticipants
        nonparticipants = self.m_subLeftNonparticipants

    end

    local idx = table.find(self.m_leftAllParticipants, hero)
    if (not idx) then
        table.insert(self.m_leftAllParticipants, hero)
    end
        
    idx = table.find(participants, hero)
    if (not idx) then
        table.insert(participants, hero)
    end

    idx = table.find(nonparticipants, hero)
    if (idx) then
        table.remove(nonparticipants, idx)
    end

    hero:setActive(true)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorldClanRaid:removeHero(hero)
    local group_key = hero:getPhysGroup()
    local participants = {}
    local nonparticipants = {}

    if (group_key == self:getPCGroup()) then
        participants = self.m_leftParticipants
        nonparticipants = self.m_leftNonparticipants

    elseif (group_key == self:getNPCGroup()) then
        participants = self.m_subLeftParticipants
        nonparticipants = self.m_subLeftNonparticipants

    end

    local idx = table.find(self.m_leftAllParticipants, hero)
    if (idx) then
        table.remove(self.m_leftAllParticipants, idx)
    end

    idx = table.find(participants, hero)
    if (idx) then
        table.remove(participants, idx)
    end

    idx = table.find(nonparticipants, hero)
    if (not idx) then
        table.insert(nonparticipants, hero)
    end

    hero:setActive(false)

    -- 팀 전멸 시 남은 팀이 공격 받을 수 있도록 변경(임시)
    if (#participants == 0) then
        if (#self.m_leftParticipants > 0) then
            self.m_subLeftFormationMgr = self.m_leftFormationMgr
        elseif (#self.m_subLeftFormationMgr > 0) then
            self.m_leftFormationMgr = self.m_subLeftFormationMgr
        end

        self.m_physWorld:modifyGroup(PHYS.HERO_TOP, { PHYS.MISSILE.ENEMY_TOP, PHYS.MISSILE.ENEMY_BOTTOM })
        self.m_physWorld:modifyGroup(PHYS.HERO_BOTTOM, { PHYS.MISSILE.ENEMY_TOP, PHYS.MISSILE.ENEMY_BOTTOM })
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
function GameWorldClanRaid:bindEnemy(enemy)
    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_gameState)

    -- 월드에서 중계되는 이벤트
    enemy:addListener('character_recovery', self)
    enemy:addListener('character_dead', self)
    enemy:addListener('character_set_hp', self)
    enemy:addListener('get_status_effect', self)
end

-------------------------------------
-- function addEnemy
-------------------------------------
function GameWorldClanRaid:addEnemy(enemy)
    local group_key = enemy:getPhysGroup()
    local participants = {}
    local nonparticipants = {}

    if (group_key == PHYS.ENEMY_TOP) then
        participants = self.m_rightParticipants
        nonparticipants = self.m_rightNonparticipants

    elseif (group_key == PHYS.ENEMY_BOTTOM) then
        participants = self.m_subRightParticipants
        nonparticipants = self.m_subRightNonparticipants

    end

    local idx = table.find(self.m_rightAllParticipants, enemy)
    if (not idx) then
        table.insert(self.m_rightAllParticipants, enemy)
    end
    
    idx = table.find(participants, enemy)
    if (not idx) then
        table.insert(participants, enemy)
    end

    idx = table.find(nonparticipants, enemy)
    if (idx) then
        table.remove(nonparticipants, idx)
    end

    enemy:setActive(true)
end

-------------------------------------
-- function removeEnemy
-------------------------------------
function GameWorldClanRaid:removeEnemy(enemy)
    local group_key = enemy:getPhysGroup()
    local participants = {}
    local nonparticipants = {}

    if (group_key == PHYS.ENEMY_TOP) then
        participants = self.m_rightParticipants
        nonparticipants = self.m_rightNonparticipants

    elseif (group_key == PHYS.ENEMY_BOTTOM) then
        participants = self.m_subRightParticipants
        nonparticipants = self.m_subRightNonparticipants

    end

    local idx = table.find(self.m_rightAllParticipants, enemy)
    if (idx) then
        table.remove(self.m_rightAllParticipants, idx)
    end

    idx = table.find(participants, enemy)
    if (idx) then
        table.remove(participants, idx)
    end

    idx = table.find(nonparticipants, enemy)
    if (not idx) then
        table.insert(nonparticipants, enemy)
    end

    enemy:setActive(false)
end

-------------------------------------
-- function removeAllHero
-- @brief
-------------------------------------
function GameWorldClanRaid:removeAllHero()
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
function GameWorldClanRaid:removeAllEnemy()
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

-------------------------------------
-- function getEnemyList
-------------------------------------
function GameWorldClanRaid:getEnemyList(char)
    if (char) then
        -- char는 Character클래스가 아닐 수 있다
        local group_key = char['phys_key']

        if (group_key == self:getOpponentNPCGroup()) then
            return self.m_subRightParticipants
        else
            return self.m_rightParticipants
        end
    else
        return self.m_rightAllParticipants
    end
end

-------------------------------------
-- function getDragonList
-- @brief 활성화된 드래곤 리스트 반환, 기획상 기준이 바뀔 가능성이 높기 때문에 함수로 관리
-------------------------------------
function GameWorldClanRaid:getDragonList(char)
    if (char) then
        -- char는 Character클래스가 아닐 수 있다
        local group_key = char['phys_key']

        if (group_key == self:getNPCGroup()) then
            return self.m_subLeftParticipants
        else
            return self.m_leftParticipants
        end
    else
        return self.m_leftAllParticipants
    end
end
