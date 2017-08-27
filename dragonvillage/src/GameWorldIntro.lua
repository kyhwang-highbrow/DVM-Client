local PARENT = GameWorld

-------------------------------------
-- class GameWorld
-------------------------------------
GameWorldIntro = class(PARENT, {
        m_enemyTamer = '',
        m_boss = '',
		m_lEnemyDragons = '',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldIntro:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode)
    self.m_lEnemyDragons = {}

    -- 적군 AI
    self.m_gameAutoEnemy = GameAuto_Enemy(self, false)

    self.m_gameState = GameState_Intro(self)

    self.m_heroMana:setEnable(false)
    self.m_enemyMana:setEnable(false)

    self.m_inGameUI:init_timeUI(true, self.m_gameState.m_limitTime)
    self.m_inGameUI:initIntroFight()
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldIntro:initGame(stage_name)
    self.m_waveMgr = WaveMgr(self, stage_name, self.m_stageID, self.m_bDevelopMode)

    -- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)
        
    -- 위치 표시 이펙트 생성
    self:init_formation()

	-- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)
		
	-- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 친구 드래곤 생성
    self:makeFriendHero()
    
    do -- 진형 시스템 초기화
        self:setBattleZone(self.m_deckFormation, true)
    end

    -- 스킬 조작계 초기화
    do
        self.m_skillIndicatorMgr = SkillIndicatorMgr_Intro(self)
    end
    
    -- 드랍 아이템 매니져 생성
    do
        self.m_dropItemMgr = DropItemMgr_Intro(self)
    end

    do -- 카메라 초기 위치 설정이 있다면 적용
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if (t_camera) then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
            self:changeHeroHomePosByCamera()
        end
    end

    -- 적 이동 처리를 위한 매니져 생성
    do
        local t_movement = self.m_waveMgr:getMovementScriptData()
        if (t_movement) then
            self.m_enemyMovementMgr = EnemyMovementMgr(self, t_movement)
        end
    end
    
    -- UI
    self.m_inGameUI:doActionReset()
end

-------------------------------------
-- function initTamer
-------------------------------------
function GameWorldIntro:initTamer()
    local t_tamer = g_tamerData:getCurrTamerTable()

    -- 테이머 생성
    self.m_tamer = self:makeTamerNew(t_tamer)

    -- 테이머 UI 생성
	--self.m_inGameUI:initTamerUI(self.m_tamer)

    self:addListener('dragon_summon', self)
end

-------------------------------------
-- function tryPatternMonster
-- @brief 패턴을 가진 적군
-- ex) 'pattern_' + rarity + type
--     'pattern_boss_queenssnake'
-------------------------------------
function GameWorldIntro:tryPatternMonster(t_monster, body)
    local rarity = t_monster['rarity']
    local type = t_monster['type']
    local script_name = 'pattern_boss_tutorial'
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

    self.m_boss = monster

    return monster
end


-------------------------------------
-- function makeMonsterNew
-------------------------------------
function GameWorldIntro:makeMonsterNew(monster_id, level)
    local monster = PARENT.makeMonsterNew(self, monster_id, level)

    local t_monster = TableMonster():get(monster_id)
    if (t_monster['type'] == 'darknix') then
        monster.m_statusCalc:addBuffMulti('hit_rate', 999)
        monster.m_statusCalc:appendHpRatio(100)
        monster:setStatusCalc(monster.m_statusCalc)
    end
    
	return monster
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldIntro:makeHeroDeck()

    -- 인트로 전투에 쓰이는 덱은 고정 - 테이블화?
    local l_deck = {120011, 120102, 120431, 120223, 120294}
    local formation = 'attack'
    local formation_lv = 1
    local leader = 2

    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}
    
    for i, did in ipairs(l_deck) do
        local t_dragon_data = StructDragonObject()
       
        if (t_dragon_data) then

            t_dragon_data['did'] = did
            t_dragon_data['grade'] = 6
            t_dragon_data['lv'] =  60
            t_dragon_data['evolution'] = 3
            t_dragon_data['skill_0'] = 1

            local is_right = false
            local hero = self:makeDragonNew(t_dragon_data, is_right)
            hero:setInvincibility(true) -- 무적모드
            if (hero) then
                self.m_myDragons[i] = hero
                hero:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(hero.m_rootNode, WORLD_Z_ORDER.HERO)
                self.m_physWorld:addObject(PHYS.HERO, hero)
                self:addHero(hero)

                self.m_leftFormationMgr:setChangePosCallback(hero)

                -- 진형 버프 적용
                hero.m_statusCalc:applyFormationBonus(formation, 1, i)

				-- 리더 등록
				if (i == leader) then
					self.m_leaderDragon = hero
				end
            end
        end
    end
end