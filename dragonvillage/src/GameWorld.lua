-------------------------------------
-- class GameWorld
-------------------------------------
GameWorld = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable(), {
        m_gameMode = 'number',
        m_stageID = 'number',
        m_inGameUI = 'UI_Game',

        m_worldLayer = 'cc.Node',
        m_gameNode1 = 'cc.Node',
        m_gameNode2 = 'cc.Node',
        m_gameNode3 = 'cc.Node',
        m_feverNode = 'cc.Node',

        m_gridNode = 'cc.Node',
        m_bgNode = 'cc.Node',
        m_groundNode = 'cc.Node',
        m_worldNode = 'cc.Node',
        m_missiledNode = 'cc.Node',
		m_unitInfoNode = 'cc.Node',

        m_lUnitList = 'list',
		m_lSkillList = 'table',
		m_lMissileList = 'table',
		m_lSpecailMissileList = 'table',
        
        -- unit
        m_participants = 'HeroList',    -- 전투에 참여중인 아군
		m_tEnemyList = 'EnemyList',     -- 적군 리스트(드래곤이라도 적 진형이라면 여기에 추가됨)
        m_mHeroList = 'HeroListMap',    -- 아군 리스트(맵 형식 리스트)
        
        m_deckFormation = 'string',

        m_physWorld = 'PhysWorld',


        m_missileFactory = '',

        -- 웨이브 매니져
        m_waveMgr = '',

        m_gameState = '',

        m_gameAutoHero = '',        -- 아군 자동시 AI
        m_gameAutoEnemy = '',       -- 적군(드래곤) AI
        
        m_gameDragonSkill = '',
        m_gameFever = '',
        m_gameCamera = '',
        m_gameTimeScale = '',
        m_gameHighlight = '',

        m_worldSize = '',
        m_worldScale = '',

        m_bDebugGrid = '',

        m_missileRange = 'table',

        m_bDevelopMode = 'boolean',

        -- callback
        m_lWorldScaleChangeCB = 'list',

        -- # GameWorld_Formation
        m_leftFormationMgr = '',
        m_rightFormationMgr = '',

        -- 드래그 스킬 관련
        m_dragSkillTimer = 'number',

        m_skillIndicatorMgr = 'SkillIndicatorMgr',
        m_enemyMovementMgr = 'EnemyMovementMgr',

		-- 테이머 스킬 관련
        m_tamerSkillCut = 'TamerSkillCut',
        m_gameTamer = 'GameTamer',
        
        -- 테이머 대사 및 표정
        m_tamerSpeechSystem = 'TamerSpeechSystem',

        -- 조작 막음 여부
        m_bPreventControl = 'boolean',

        m_formationDebugNode = '',

        -- 드롭된 골드의 리스트
        m_dropGoldList = 'list[ObjectGold]',
        m_dropGoldIdx = 'number', -- 골드마다 고유한 idx를 가짐

        m_touchMotionStreak = 'cc.MotionStreak',
        m_touchPrevPos = '{x, y}',
        m_tCollisionTime = 'table',

        m_snGold = 'SecurityNumber',

        m_mapManager = 'MapManager',
		m_shakeMgr = 'ShakeManager',
		m_missionMgr = 'StageMissionMgr',
		m_logRecorder = 'GameLogRecorder',

        m_mPassiveEffect = 'list',  -- 게임시작시 발동하는 패시브들의 연출을 위한 테이블

        -- 친구 영웅 관련
        m_bUsedFriend = 'boolean',

        m_friendHero = 'Dragon',

    })

-------------------------------------
-- function init
-------------------------------------
function GameWorld:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, fever_node, ui, develop_mode)
    self.m_gameMode = game_mode
    self.m_stageID = stage_id
    self.m_inGameUI = ui
    
    self.m_worldLayer = world_node
    self.m_worldLayer:setPosition(-640, 0)
    self:makeDebugLayer()

    self.m_gameNode1 = game_node1
    self.m_gameNode2 = game_node2
    self.m_gameNode3 = game_node3
    self.m_feverNode = fever_node
    
    self.m_bDevelopMode = develop_mode or false

    self.m_bPreventControl = false

    self.m_bgNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_bgNode)

    self.m_groundNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_groundNode)

	-- 그리드 노드
    self.m_gridNode = cc.Node:create()
    self.m_gridNode:setVisible(false)
    self.m_gameNode1:addChild(self.m_gridNode)

    self.m_worldNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_worldNode)

    self.m_missiledNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_missiledNode)
	
	self.m_unitInfoNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_unitInfoNode)

    self.m_lUnitList = {}
	self.m_lSkillList = {}
	self.m_lMissileList = {}
	self.m_lSpecailMissileList = {}
    
    self.m_physWorld = PhysWorld(self.m_gameNode1, false)
    self.m_physWorld:initGroup()

    self.m_participants = {}
    self.m_tEnemyList = {}
    self.m_mHeroList = {}
    
    self.m_missileFactory = MissileFactory(self)

    self.m_worldSize = nil
    self.m_worldScale = nil

    self.m_dropGoldList = {}
    self.m_dropGoldIdx = 0
    
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self)
    
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_gameFever = GameFever(self)

    -- 아군 자동시 AI
    self.m_gameAutoHero = GameAuto_Hero(self)
    self.m_gameAutoHero:bindGameFever(self.m_gameFever)
    self:addListener('auto_start', self.m_gameAutoHero)
    self:addListener('auto_end', self.m_gameAutoHero)

    -- 적군(드래곤) AI
    self.m_gameAutoEnemy = GameAuto_Enemy(self, false)

    -- shake manager 생성
	self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

	-- ## 모드별 분기 처리
	-- 1. 모험 모드
    if (self.m_gameMode == GAME_MODE_ADVENTURE) then
        self.m_gameState = GameState(self)
		local display_wave = true
		self.m_inGameUI:init_timeUI(display_wave, nil)

	-- 2. 네스트 던전
    elseif (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
        local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
        local dungeonMode = t_dungeon['dungeon_mode']

        if (dungeonMode == NEST_DUNGEON_DRAGON) then
            self.m_gameState = GameState_NestDungeon_Dragon(self)

		elseif (dungeonMode == NEST_DUNGEON_NIGHTMARE) then
		    self.m_gameState = GameState_NestDungeon_Nightmare(self)

        elseif (dungeonMode == NEST_DUNGEON_TREE) then
            self.m_gameCamera:setRange({minX = -640, maxX = 640})
            
            self.m_gameState = GameState_NestDungeon_Tree(self)

		else
			error('네스트 던전 아이디가 잘못되어있습니다. 확인해주세요. ' .. self.m_stageID)
        end

        self.m_inGameUI:init_timeUI(display_wave, nil)

	-- 3. 비밀 던전
    elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then
        local t_dungeon = g_secretDungeonData:parseSecretDungeonID(self.m_stageID)
        local dungeonMode = t_dungeon['dungeon_mode']

        if (dungeonMode == SECRET_DUNGEON_GOLD) then
            self.m_gameState = GameState_SecretDungeon_Gold(self)
            self.m_inGameUI:init_goldUI()
			local display_wave = false
            self.m_inGameUI:init_timeUI(display_wave, self.m_gameState.m_limitTime)

        elseif (dungeonMode == SECRET_DUNGEON_RELATION) then
            self.m_gameState = GameState_SecretDungeon_Relation(self)

            self.m_inGameUI:init_timeUI(display_wave, nil)
        end
    end

    self.m_missileRange = {}
    self:setMissileRange()

    -- callback
    self.m_lWorldScaleChangeCB = {}

    g_currScene:addKeyKeyListener(self)

    -- 모션 스트릭 터치 영역 
    --self.makeTouchLayer_GameWorld(self, world_node)
    --self.init_motionStreak(self)

    self.m_touchPrevPos = nil
    self.m_tCollisionTime = {}

    self.m_mPassiveEffect = {}

    self.m_bUsedFriend = false
    self.m_friendHero = nil

    self:initGold()
end


-------------------------------------
-- function initGame
-------------------------------------
function GameWorld:initGame(stage_name)
    local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
    local dungeonMode = t_dungeon['dungeon_mode']

    -- 웨이브 매니져 생성
    if (self.m_gameMode == GAME_MODE_SECRET_DUNGEON and dungeonMode == SECRET_DUNGEON_RELATION) then
        self.m_waveMgr = WaveMgr_SecretRelation(self, stage_name, self.m_bDevelopMode)
    else
        self.m_waveMgr = WaveMgr(self, stage_name, self.m_bDevelopMode)
    end

	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)
        
    -- 위치 표시 이펙트 생성
    self:init_formation()

    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 친구 드래곤 생성
    self:makeFriendHero()

	-- Game Log Recorder 생성
	self.m_logRecorder = GameLogRecorder(self)
		
	-- mission manager 생성
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		self.m_missionMgr = StageMissionMgr(self.m_logRecorder, self.m_stageID)
	end

    do -- 진형 시스템 초기화
        self:setBattleZone(self.m_deckFormation, true)
    end

    do -- 드래그 스킬
        self.m_dragSkillTimer = 0
    end

    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
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
-- function initBG
-------------------------------------
function GameWorld:initBG(waveMgr)
    local t_script_data = waveMgr.m_scriptData
    if not t_script_data then return end

    local bg_res = t_script_data['bg']
    local bg_type = t_script_data['bg_type'] or 'default'
	local bg_directing = t_script_data['bg_directing'] or 'floating_1'
    local attr = TableDrop():getValue(self.m_stageID, 'attr')

    if (bg_type == 'animation') then
        self.m_mapManager = AnimationMap(self.m_bgNode, bg_res)

    elseif (bg_type == 'default') then
        self.m_mapManager = ScrollMap(self.m_bgNode)
        self.m_mapManager:setBg(bg_res, attr)
        self.m_mapManager:setSpeed(-100)
        self.m_mapManager:bindCameraNode(g_gameScene.m_cameraLayer)
        self.m_mapManager:bindEventDispatcher(self)
    else
        error('bg_type : ' .. bg_type)
    end
end

-------------------------------------
-- function initTamer
-------------------------------------
function GameWorld:initTamer()
    local t_tamer = g_userData:getTamerInfo()

    -- 테이머 생성
    self.m_gameTamer = GameTamer(self, t_tamer)
    self:addListener('tamer_skill', self.m_gameState)

    -- 스킬 컷씬
    self.m_tamerSkillCut = TamerSkillCut(self, g_gameScene.m_colorLayerTamerSkill, t_tamer)
    --self:addListener('tamer_skill', self.m_tamerSkillCut)
    --self:addListener('tamer_special_skill', self.m_tamerSkillCut)
                
    -- 테이머 대사
    self.m_tamerSpeechSystem = TamerSpeechSystem(self, t_tamer)
    
    self:addListener('dragon_summon', self.m_tamerSpeechSystem)
    self:addListener('game_start', self.m_tamerSpeechSystem)
    self:addListener('wave_start', self.m_tamerSpeechSystem)
    self:addListener('boss_wave', self.m_tamerSpeechSystem)
    self:addListener('stage_clear', self.m_tamerSpeechSystem)
    self:addListener('friend_dragon_appear', self.m_tamerSpeechSystem)
    self:addListener('tamer_skill', self.m_tamerSpeechSystem)
end


local counter = Counter()

DEPTH_MISSILE = counter:get()

DEPTH_ITEM_HP = counter:get()
DEPTH_ITEM_GOLD = counter:get()
DEPTH_ITEM_CHARGE_UNDER = counter:get()
DEPTH_ITEM_CHARGE = counter:get()

DEPTH_DAMAGE_EFFECT = counter:get()
DEPTH_INSTANT_EFFECT = counter:get()

DEPTH_CHANCE_FONT = counter:get()
DEPTH_DAMAGE_FONT = counter:get()
DEPTH_CRITICAL_FONT = counter:get()
DEPTH_HEAL_FONT = counter:get()
DEPTH_MISS_FONT = counter:get()
DEPTH_BLOCK_FONT = counter:get()

DEPTH_PASSIVE_FONT = counter:get()

DEPTH_LUCKY_WING_MOTION_STREAK = counter:get()
DEPTH_LUCKY_WING = counter:get()

-------------------------------------
-- function addChildWorld
-------------------------------------
function GameWorld:addChildWorld(node, depth)
    self.m_worldNode:addChild(node, depth or 0)
end

-------------------------------------
-- function addChild2
-------------------------------------
function GameWorld:addChild2(node, depth)
    self.m_gameNode2:addChild(node, depth or 0)
end

-------------------------------------
-- function addChild3
-------------------------------------
function GameWorld:addChild3(node, depth)
    self.m_gameNode3:addChild(node, depth or 0)
end

-------------------------------------
-- function initGold
-------------------------------------
function GameWorld:initGold()
    self.m_snGold = SecurityNumber(0)
end

-------------------------------------
-- function obtainGold
-------------------------------------
function GameWorld:obtainGold(add_gold)
    local prev_gold = self.m_snGold:get()

    self.m_snGold:add(add_gold)

    g_gameScene.m_inGameUI:setGold(self.m_snGold:get(), prev_gold)
end

-------------------------------------
-- function getGold
-------------------------------------
function GameWorld:getGold()
    return self.m_snGold:get()
end

-------------------------------------
-- function clearGold
-------------------------------------
function GameWorld:clearGold()
    for i,v in pairs(self.m_dropGoldList) do
        v.m_animator.m_node:stopAllActions()
        v:action2()
    end
end

-------------------------------------
-- function updateUnit
-- @param dt
-------------------------------------
function GameWorld:updateUnit(dt)
    local t_remove = {}
    for i,v in ipairs(self.m_lUnitList) do

        -- 일시 정지 상태가 아닌 경우에만 업데이트
        if (not v.m_temporaryPause) then

            -- update 리턴값이 true이면 객체 삭제
            if (v:update(dt) == true) then
                table.insert(t_remove, 1, i)
                v:release()
            end
        end
    end

    for i,v in ipairs(t_remove) do
        table.remove(self.m_lUnitList, v)
    end
end

-------------------------------------
-- function cleanupUnit
-------------------------------------
function GameWorld:cleanupUnit()
    for i,v in ipairs(self.m_lUnitList) do
        v:release()
    end

    self.m_lUnitList = {}
end

-------------------------------------
-- function addToUnitList
-- @param Unit
-------------------------------------
function GameWorld:addToUnitList(unit)
    table.insert(self.m_lUnitList, unit)
    unit:initWorld(self)
end

-------------------------------------
-- function addUnit
-- @param Unit
-------------------------------------
function GameWorld:addUnit(unit)
    self:addToUnitList(unit)
    self.m_worldNode:addChild(unit.m_node)
end

-------------------------------------
-- function cleanupSkill
-------------------------------------
function GameWorld:cleanupSkill()
    local count = 0

    -- 스킬 다 날려 버리자
	for _, v in pairs(self.m_lSkillList) do
        v:changeState('dying')
        count = count + 1
    end

    return count
end

-------------------------------------
-- function addToSkillList
-- @param Skill
-- @brief skill list는 관리용으로 사용하고 실질적인 동작은 unit list를 통함
-------------------------------------
function GameWorld:addToSkillList(skill)
    self.m_lSkillList[skill] = skill
	self:addToUnitList(skill)
end

-------------------------------------
-- function addToMissileList
-- @param Missile, CommonMissile
-- @brief skill list와 동일
-------------------------------------
function GameWorld:addToMissileList(missile)
    self.m_lMissileList[missile] = missile
	self:addToUnitList(missile)
end

-------------------------------------
-- function addToSpecailMissileList
-- @param Missile, CommonMissile
-- @brief 특수 미사일 관리
-------------------------------------
function GameWorld:addToSpecailMissileList(missile)
    self.m_lSpecailMissileList[missile] = missile
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function GameWorld:update(dt)
    if self.m_physWorld then
        self.m_physWorld:update(dt)
    end

    self:updateUnit(dt)

    if self.m_mapManager then
        self.m_mapManager:update(dt)
    end

    if self.m_gameState then
        self.m_gameState:update(dt)
    end

    if self.m_gameCamera then
        self.m_gameCamera:update(dt)
    end

    if self.m_gameTimeScale then
        self.m_gameTimeScale:update(dt)
    end

    if self.m_gameDragonSkill then
        self.m_gameDragonSkill:update(dt)
    end

    for char, v in pairs(self.m_mPassiveEffect) do
        self:makePassiveStartEffect(char, v)
    end
    self.m_mPassiveEffect = {}
end

-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorld:makePassiveStartEffect(char, str_map)
    local root_node = cc.Node:create()
    self:addChild2(root_node, DEPTH_PASSIVE_FONT)
    root_node:setPosition(char.pos.x, char.pos.y)

    do-- 이펙트 생성
        local effect = MakeAnimator('res/effect/effect_passive_common/effect_passive_common.vrp')
        if effect.m_node then
            root_node:addChild(effect.m_node)
            effect:changeAni('idle', false)
        end
    end

    -- label 컨테이너 node 생성
    local node = cc.Node:create()
    root_node:addChild(node)
    node:setPositionY(80)
    node:runAction(cc.MoveTo:create(3, cc.p(0, 160)))

    -- 패시브명 label 생성
    local i = 1
    for str, _ in  pairs(str_map) do
        local label = cc.Label:createWithTTF(Str(str), 'res/font/common_font_01.ttf', 26, 3, cc.size(200, 50), 1, 1)
        node:addChild(label)
        label:setScale(0.2)
        label:runAction( cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.3, 1), cc.DelayTime:create(1.6), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        label:setPositionY((i-1) * 30)
        i = i + 1
    end

    -- 2초 후 삭제
    root_node:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.RemoveSelf:create()))

    -- 실시간 위치 동기화
    root_node:scheduleUpdateWithPriorityLua(function(dt) 
        root_node:setPosition(char.pos.x, char.pos.y)
    end, 0)
end

-------------------------------------
-- function 
-------------------------------------
function GameWorld:addDestructibleMissile(missile)
	self:addToSpecailMissileList(missile)
end

-------------------------------------
-- function addMissile
-- @param res_depth : 어느 노드에 addchild 할지 결정한다. ;를 사용하여 z-order를 명시할수도 있다. ex) 'res_depth':'bottom;1'
-------------------------------------
function GameWorld:addMissile(missile, object_key, res_depth, highlight)
    self:addToMissileList(missile)
    self.m_physWorld:addObject(object_key, missile)
    
	local t_res_depth = stringSplit(res_depth, ';') or {}

	local depth_type = t_res_depth[1]
	local z_order = t_res_depth[2] or WORLD_Z_ORDER.MISSILE

	local target_node = self:getMissileNode(depth_type)
    target_node:addChild(missile.m_rootNode, z_order)

    if (highlight) then
        self.m_gameHighlight:addMissile(missile)
    end
end

-------------------------------------
-- function getMissileNode
-- @brief
-------------------------------------
function GameWorld:getMissileNode(depth_type)
    local missile_node

    if (depth_type == 'bottom') then
		missile_node = self.m_worldNode
	else
		missile_node = self.m_missiledNode
	end	
    
    return missile_node
end

-------------------------------------
-- function findTarget
-------------------------------------
function GameWorld:findTarget(type, x, y, l_remove)
    local target
    local unitList
    local distance = nil

    if (type == PHYS.ENEMY) then
        unitList = self:getEnemyList()
    else
        unitList = self:getDragonList()
    end

    for i,v in pairs(unitList) do
        if v.m_bDead then
        elseif l_remove and table.find(l_remove, v.phys_idx) then
        else
            local dist = getDistance(x, y, v.pos.x + v.body.x, v.pos.y + v.body.y)
            if (not distance) or (dist < distance) then
                distance = dist
                target = v
            end
        end
    end

    return target
end

-------------------------------------
-- function getCharList
-- @param  team 'ally' or 'enemy'
-- @return table
-------------------------------------
function GameWorld:getCharList(team)
    if (team == 'ally') then
        return self:getDragonList()
    elseif (team == 'enemy') then
        return self:getEnemyList()
    end
end

-------------------------------------
-- function addEnemy
-- @param enemy
-------------------------------------
function GameWorld:addEnemy(enemy)
    
    table.insert(self.m_tEnemyList, enemy)
    --cclog('GameWorld:addEnemy(enemy) cnt : ' .. #self.m_tEnemyList)

    -- 죽음 콜백 등록
    enemy:addListener('character_dead', self)

    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_gameState)

    -- 스킬 캐스팅
    enemy:addListener('enemy_casting_start', self.m_gameAutoHero)
    
    -- 스킬 캐스팅 중 취소시 콜백 등록
    enemy:addListener('character_casting_cancel', self.m_tamerSpeechSystem)
    enemy:addListener('character_casting_cancel', self.m_gameFever)

    if (enemy.m_charType == 'dragon') then
        enemy:addListener('dragon_skill', self.m_gameDragonSkill)
        enemy:addListener('enemy_active_skill', self.m_gameState)
        enemy:addListener('enemy_active_skill', self.m_gameAutoHero)
    end
end

-------------------------------------
-- function removeEnemy
-- @param enemy
-------------------------------------
function GameWorld:removeEnemy(enemy)
    local idx = table.find(self.m_tEnemyList, enemy)
    table.remove(self.m_tEnemyList, idx)
    --cclog('GameWorld:removeEnemy(enemy) cnt : ' .. #self.m_tEnemyList)
end

-------------------------------------
-- function killAllEnemy
-- @brief
-------------------------------------
function GameWorld:killAllEnemy()
    for i,v in pairs(self:getEnemyList()) do
		cclog('KILL ALL ' .. v:getName())
        if (not v.m_bDead) then
            v:setDead()
            v:setEnableBody(false)
            v:changeState('dying')
        end
    end
	
    self.m_waveMgr:clearDynamicWave()
end

-------------------------------------
-- function killAllHero
-- @brief
-------------------------------------
function GameWorld:killAllHero()
    for i,v in pairs(self.m_mHeroList) do
        if (not v.m_bDead) then
            v:setDead()
            v:setEnableBody(false)
            v:changeState('dying')

            local effect = self:addInstantEffect('res/effect/tamer_magic_1/tamer_magic_1.vrp', 'bomb', v.pos['x'], v.pos['y'])
            effect:setScale(0.8)
        end
    end
end


-------------------------------------
-- function addHero
-------------------------------------
function GameWorld:addHero(hero, idx)
    self.m_mHeroList[idx] = hero

    hero:addListener('character_dead', self)
    hero:addListener('character_dead', self.m_tamerSpeechSystem)

    hero:addListener('dragon_skill', self.m_gameDragonSkill)
    
    hero:addListener('hero_basic_skill', self)
    hero:addListener('hero_basic_skill', self.m_gameFever)
    hero:addListener('hero_active_skill', self.m_gameFever)
    hero:addListener('hero_active_skill', self.m_gameState)
    hero:addListener('hero_active_skill', self.m_gameAutoHero)
    hero:addListener('hero_touch_skill', self)
    hero:addListener('hero_touch_skill', self.m_tamerSpeechSystem)
    hero:addListener('hero_passive_skill', self)

    hero:addListener('hero_casting_start', self.m_gameAutoHero)

    hero:addListener('hit_active', self.m_gameFever)
    hero:addListener('hit_active_buff', self.m_gameFever)
       
    hero:addListener('character_weak', self.m_tamerSpeechSystem)
    hero:addListener('character_damaged_skill', self.m_tamerSpeechSystem)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorld:removeHero(hero)
    for i,v in pairs(self.m_mHeroList) do
        if (v == hero) then
            self.m_mHeroList[i] = nil
            break
        end
    end

    self:standbyHero(hero)

    -- 친구 드래곤을 추가 시킴
    if (not self.m_bUsedFriend and self.m_friendHero) then
        self:joinFriendHero(hero:getPosIdx())

        self.m_friendHero:setOrgHomePos(hero.m_orgHomePosX, hero.m_orgHomePosY)
        self.m_friendHero:setHomePos(hero.m_homePosX, hero.m_homePosY)
        self.m_friendHero:setPosition(hero.m_homePosX, hero.m_homePosY)

        -- 패시브 즉시 적용
        self.m_friendHero:doSkill_passive()

        -- 등장시킴
        self.m_friendHero:doAppear()

        self.m_friendHero.m_bFirstAttack = true
        self.m_friendHero:changeState('attackDelay')

        self:dispatch('friend_dragon_appear', {}, self.m_friendHero)
        
        self.m_bUsedFriend = true
    end

    -- 게임 종료 체크(모든 영웅이 죽었을 경우)
    local hero_count = table.count(self.m_mHeroList)
    if (hero_count <= 0) then
        if (self.m_bDevelopMode) then 
			-- 개발 스테이지에서는 드래곤이 전부 죽을 시 드래곤을 되살리고 스테이지 초기화 한다 
			self.m_mHeroList = {}
			self.m_participants = {}
			
			self:makeHeroDeck()
						
			self:killAllEnemy()
		else
			self.m_gameState:changeState(GAME_STATE_FAILURE)
		end
    end
end

-------------------------------------
-- function participationHero
-------------------------------------
function GameWorld:participationHero(hero)
    table.insert(self.m_participants, hero)

    hero:setActive(true)
end

-------------------------------------
-- function standbyHero
-- @brief 전투에서 제외
-------------------------------------
function GameWorld:standbyHero(hero)

    hero:setActive(false)

    for i,v in ipairs(self.m_participants) do
        if (v == hero) then
            table.remove(self.m_participants, i)
            break
        end
    end
end

-------------------------------------
-- function changeWorldSize
-------------------------------------
function GameWorld:changeWorldSize(size)
    if (self.m_worldSize == size) then
        return
    end

    self.m_worldSize = size

    if (size == 1) then
        self:changeWorldScale(1)
    elseif (size == 2) then
        self:changeWorldScale(0.8)
    elseif (size == 3) then
        self:changeWorldScale(0.6)
    else
        cclog('@ 지정되지 않은 size : ' .. tostring(size))
        self:changeWorldScale(1)
    end
end

-------------------------------------
-- function changeWorldScale
-- @brief 월드 사이즈 변경
-------------------------------------
function GameWorld:changeWorldScale(scale, time)
    if (self.m_worldScale == scale) then
        return
    end
    
    local time = time or 1
    self.m_worldScale = scale
    --self.m_worldLayer:setScale(scale)

    local zoom_action = cc.ScaleTo:create(time, scale)
    local ease_action = cc.EaseIn:create(zoom_action, 2)

    self.m_worldLayer:stopAllActions()
    self.m_worldLayer:runAction(ease_action)

    for i,v in pairs(self.m_lWorldScaleChangeCB) do
        v(self.m_worldScale)
    end
end

-------------------------------------
-- function addWorldScaleChangeCB
-------------------------------------
function GameWorld:addWorldScaleChangeCB(owner, cb)
    self.m_lWorldScaleChangeCB[owner] = cb
    if cb then
        cb(self.m_worldScale)
    end
end

-------------------------------------
-- function setMissileRange
-------------------------------------
function GameWorld:setMissileRange()
    local scale = self.m_worldLayer:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local cameraScale = self.m_gameCamera:getHomeScale()

    scale = scale * cameraScale

    self.m_missileRange['min_x'] = (-CRITERIA_RESOLUTION_X / 2 - 200) / scale 
    self.m_missileRange['max_x'] = (CRITERIA_RESOLUTION_X / 2 + 200) / scale
    self.m_missileRange['min_y'] = (-GAME_RESOLUTION_X / 2 - 200) / scale
    self.m_missileRange['max_y'] = (GAME_RESOLUTION_X / 2 + 200) / scale

    self.m_missileRange['min_x'] = self.m_missileRange['min_x'] + cameraHomePosX + (CRITERIA_RESOLUTION_X / 2)
    self.m_missileRange['max_x'] = self.m_missileRange['max_x'] + cameraHomePosX + (CRITERIA_RESOLUTION_X / 2)
    self.m_missileRange['min_y'] = self.m_missileRange['min_y'] + cameraHomePosY
    self.m_missileRange['max_y'] = self.m_missileRange['max_y'] + cameraHomePosY
end

-------------------------------------
-- function checkMissileRange
-------------------------------------
function GameWorld:checkMissileRange(x, y)
    if (x < self.m_missileRange['min_x']) then
        return true
    elseif (self.m_missileRange['max_x'] < x) then
        return true
    elseif (y < self.m_missileRange['min_y']) then
        return true
    elseif (self.m_missileRange['max_y'] < y) then
        return true
    end

    return false
end

-------------------------------------
-- function onKeyReleased
-------------------------------------
function GameWorld:onKeyReleased(keyCode, event)

    -- 현재 웨이브를 클리어
    if (keyCode == KEY_R) then
        self:killAllEnemy()
        self.m_waveMgr:clearDynamicWave()

	-- 스킬 충전
    elseif (keyCode == KEY_C) then
        -- 드래곤 터치 스킬
        for _,dragon in pairs(self:getDragonList()) do
            dragon:updateTouchSkillCoolTime(100)
        end

        -- 드래곤 드래그 스킬
        self:addDragSkillCoolTime(100)

        -- 테이머 스킬
        if (self.m_gameTamer) then
            self.m_gameTamer:resetActiveSkillCoolTime()
        end

	-- 미션 성공
    elseif (keyCode == KEY_V) then
        self.m_gameState:changeState(GAME_STATE_SUCCESS)

	-- 미션 실패
    elseif (keyCode == KEY_B) then
        self.m_gameState:changeState(GAME_STATE_FAILURE)

	-- 진영 가늠자 출력 
    elseif (keyCode == KEY_0) then
        self.m_formationDebugNode:runAction(cc.ToggleVisibility:create())

	-- 배경 초기화
    elseif (keyCode == KEY_M) then
        self:initBG(self.m_waveMgr)

	-- 강제로 wait 상태로 걸어버림
    elseif (keyCode == KEY_O) then
        for i,v in ipairs(self:getEnemyList()) do
            v:setWaitState(true)
        end

        for i,v in ipairs(self:getDragonList()) do
            v:setWaitState(true)
        end

	-- wait 상태 해제
    elseif (keyCode == KEY_P) then
        for i,v in ipairs(self:getEnemyList()) do
            v:setWaitState(false)
        end

        for i,v in ipairs(self:getDragonList()) do
            v:setWaitState(false)
        end

	elseif (keyCode == KEY_Z) then
		cclog('#### 아군 드래곤의 상태, 버프, 디버프 및 패시브 적용 확인 ')
        for _,v in ipairs(self:getDragonList()) do
			cclog('---------------')
			cclog(' DRAGON : ' .. v.m_charTable['t_name'])
            cclog('state = ' .. v.m_state)
            cclog('------status list')
            for type, se in pairs(v:getStatusEffectList()) do
				cclog(type, se.m_overlabCnt)
			end
			cclog('------overlab list')
			for type, se in pairs(v.m_tOverlabStatusEffect) do
				cclog(type)
			end
			cclog('=============================')

        end

    elseif (keyCode == KEY_X) then
		cclog('#### 적군의 상태, 버프, 디버프 및 패시브 적용 확인 ')
        for _,v in ipairs(self:getEnemyList()) do
			cclog('---------------')
			cclog(' ENEMY : ' .. v.m_charTable['t_name'])
            cclog('state = ' .. v.m_state)
            cclog('------status list')
            for type, se in pairs(v:getStatusEffectList()) do
				cclog(type, se.m_overlabCnt)
			end
			cclog('------overlab list')
			for type, se in pairs(v.m_tOverlabStatusEffect) do
				cclog(type)
			end
			cclog('=============================')

        end

    elseif (keyCode == KEY_S) then
        g_gameScene.m_inGameUI.root:runAction(cc.ToggleVisibility:create())

    -- 상태 효과 이펙트 확인
    elseif (keyCode == KEY_T) then    
        for i,v in ipairs(self:getEnemyList()) do
			if (i < 5) then 
				local test_res = g_constant:get('ART', 'STATUS_EFFECT_RES')
				StatusEffectHelper:invokeStatusEffectForDev(v, test_res)
				cclog('TEST 상태효과 RES 적용 !! ' .. test_res)
			end
        end

	-- 아군한테 상태효과 걸기
    elseif (keyCode == KEY_Y) then    
        for i,v in ipairs(self:getDragonList()) do
			local test_res = g_constant:get('ART', 'STATUS_EFFECT_RES')
			StatusEffectHelper:invokeStatusEffectForDev(v, test_res)
			cclog('TEST 상태효과 RES 적용 !! ' .. test_res)
        end

    -- 피버 모드 발동
    elseif (keyCode == KEY_F) then    
        if not self.m_gameFever:isActive() then
            self.m_gameFever:addFeverPoint(100)
        end
        
	-- 스킬 다 죽이기
	elseif (keyCode == KEY_K) then    
		local count = self:cleanupSkill()
        
		cclog('KILL SKILL ALL - Count : ' .. count)
	-- 미사일 없애기
	elseif (keyCode == KEY_L) then    
		local count = 1
		for _, missile in pairs(self.m_lMissileList) do
			missile:changeState('dying')
			count = count + 1
		end
		cclog('KILL MISSILE ALL - Count : ' .. count)

    -- 아군 모두 죽이기
    elseif (keyCode == KEY_J) then
        for i, v in ipairs(self:getDragonList()) do
            if not v.m_bDead then
                v:setDead()
                v:setEnableBody(false)
                v:changeState('dying')
            end
        end

    -- 보스 모두 죽이기
    elseif (keyCode == KEY_D) then
        for i, v in ipairs(self:getEnemyList()) do
            if not v.m_bDead then
                if v:isBoss() then
                    v:setDead()
                    v:setEnableBody(false)
                    v:changeState('dying')
                end
            end
        end

    -- pause
    elseif (keyCode == KEY_A) then
        if (self.m_gameAutoHero:isActive()) then
            self.m_gameAutoHero:onEnd()
        else
            self.m_gameAutoHero:onStart()
        end

	-- formation list 확인
    elseif (keyCode == KEY_H) then
        self.m_leftFormationMgr:printCharList()
        self.m_rightFormationMgr:printCharList()

    -- 보스 패턴 확인
    elseif (keyCode == KEY_E) then
        for i, v in ipairs(self:getEnemyList()) do
            if not v.m_bDead then
                if (isInstanceOf(v, MonsterLua_Boss)) then
                    v:printCurBossPatternList()
                end
                
            end
        end

    -- 테이머 스킬
    elseif (keyCode == KEY_1) then
        self.m_gameTamer:doSkillActive()
        
    elseif (keyCode == KEY_2) then
        self.m_gameTamer:doSkillPassive()

	-- 미사일 범위 확인
    elseif (keyCode == KEY_W) then
		ccdump(self.m_missileRange)

    -- 카메라 이동
    elseif (keyCode == KEY_LEFT_ARROW) then
        local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
        
        self:changeCameraOption({
            pos_x = curCameraPosX - 300,
            pos_y = curCameraPosY
        }, true)

    elseif (keyCode == KEY_RIGHT_ARROW) then
        local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
        
        self:changeCameraOption({
            pos_x = curCameraPosX + 300,
            pos_y = curCameraPosY
        }, true)

    elseif (keyCode == KEY_UP_ARROW) then
        local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
                
        self:changeCameraOption({
            pos_x = curCameraPosX,
            pos_y = curCameraPosY + 300
        }, true)
        
        self:changeHeroHomePosByCamera()

    elseif (keyCode == KEY_DOWN_ARROW) then
        local curCameraPosX, curCameraPosY = self.m_gameCamera:getPosition()
                
        self:changeCameraOption({
            pos_x = curCameraPosX,
            pos_y = curCameraPosY - 300
        }, true)
        
        self:changeHeroHomePosByCamera()
    end
end

-------------------------------------
-- function setWaitAllCharacter
-------------------------------------
function GameWorld:setWaitAllCharacter(wait)
    for i,v in ipairs(self:getEnemyList()) do
        v:setWaitState(wait)
    end

    for i,v in ipairs(self:getDragonList()) do
        v:setWaitState(wait)
    end
end

-------------------------------------
-- function dropItem
-------------------------------------
function GameWorld:dropItem(x, y)
    local rand = math_random(2, 4)
    for i=1, rand do
		self:obtainGold(1)
        self:addDropGold(x, y)
    end
end

-------------------------------------
-- function makeInstantEffect
-- @brief 단발성 이펙트 생성
-------------------------------------
function GameWorld:makeInstantEffect(res, ani_name, x, y)
    local effect = MakeAnimator(res)
    effect:setPosition(x, y)
    effect:changeAni(ani_name, false)
    local duration = effect.m_node:getDuration()
    effect.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    return effect
end

-------------------------------------
-- function addInstantEffect
-- @brief 단발성 이펙트 생성
-------------------------------------
function GameWorld:addInstantEffect(res, ani_name, x, y)
    local effect = self:makeInstantEffect(res, ani_name, x, y)
    self:addChild2(effect.m_node, DEPTH_INSTANT_EFFECT)
    return effect
end

-------------------------------------
-- function addInstantEffectWorld
-- @brief 단발성 이펙트 생성
-------------------------------------
function GameWorld:addInstantEffectWorld(res, ani_name, x, y)
    local effect = self:makeInstantEffect(res, ani_name, x, y)
    self:addChildWorld(effect.m_node, 0)
    return effect
end

-------------------------------------
-- function effectSyncPos
-- @brief
-------------------------------------
function GameWorld:effectSyncPos(owner, effect, offset_x, offset_y)
    local function update(dt)
        effect:setPosition(owner.pos.x + offset_x, owner.pos.y + offset_y)
    end

    effect.m_node:scheduleUpdateWithPriorityLua(update, 0)
end

-------------------------------------
-- function setBattleZone
-- @brief 전투영역 설정
-------------------------------------
function GameWorld:setBattleZone(formation, immediately, is_right)

    local rage = (70 * 5)

    -- 실제 사각형 영역
    local min_x = 0
    local max_x = rage
    local min_y = -(rage / 2)
    local max_y = (rage / 2)

    -- 드래곤의 포지션 영역 padding처리
    local padding_x = 20
    local padding_y = 56
    min_x = (min_x + padding_x)
    max_x = (max_x - padding_x)
    min_y = (min_y + padding_y)
    max_y = (max_y - padding_y)

    -- offset 지정(카메라 역할)
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local offset_x
    local offset_y
    local lUnitList

    if (is_right) then
        offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) + 150
        offset_y = cameraHomePosY + 30
        lUnitList = self.m_tEnemyList
    else
        offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - 150 - rage
        offset_y = cameraHomePosY + 30
        lUnitList = self.m_participants
    end
    
    min_x = (min_x + offset_x)
    max_x = (max_x + offset_x)
    min_y = (min_y + offset_y)
    max_y = (max_y + offset_y)

    local l_pos_list = TableFormation:getFormationPositionList(formation, min_x, max_x, min_y, max_y, is_right)

    for _, unit in pairs(lUnitList) do
        local pos_idx = unit:getPosIdx()
        local pos_x = l_pos_list[pos_idx]['x']
        local pos_y = l_pos_list[pos_idx]['y']

        unit:setOrgHomePos(pos_x, pos_y)

        if immediately then
            unit:setHomePos(pos_x, pos_y)
            unit:setPosition(pos_x, pos_y)
        else
            unit:changeHomePos(pos_x, pos_y)
        end
    end
end

--------------------------------------
-- function makeDebugLayer
--------------------------------------
function GameWorld:makeDebugLayer()
    -- draw 함수 구현
    local function primitivesDraw(transform, transformUpdated)
        self:primitivesDraw(transform, transformUpdated)
    end

    -- glNode 생성
    local glNode = cc.GLNode:create()
    glNode:registerScriptDrawHandler(primitivesDraw)
    glNode:setVisible(false)
    self.m_formationDebugNode = glNode

    local container = cc.Sprite:create(EMPTY_PNG)
    self.m_worldLayer:addChild(container, 100)
    container:addChild(glNode)
end

-------------------------------------
-- function primitivesDraw
-------------------------------------
function GameWorld:primitivesDraw(transform, transformUpdated)

    kmGLPushMatrix()
    kmGLLoadMatrix(transform)

    gl.lineWidth(1)

    cc.DrawPrimitives.drawColor4B(255, 255, 255, 255)

    local interval = 100
    local offset = 20

    if true then
        local height = (720 / 2) - offset
        local width = interval * 6

        local top = 320
        local bottom = -320
        local left = offset
        local right = left + (interval * 2)

        local vertices =   
        {
            cc.p(left, top),
            cc.p(left, bottom),
            cc.p(right, bottom),
            cc.p(right, top),
        }  
        cc.DrawPrimitives.drawPoly(vertices, 4, true)

        local top = 320
        local bottom = -320
        local left = offset + (interval * 2)
        local right = left + (interval * 2)

        local vertices =   
        {
            cc.p(left, top),
            cc.p(left, bottom),
            cc.p(right, bottom),
            cc.p(right, top),
        }  
        cc.DrawPrimitives.drawPoly(vertices, 4, true)

        local top = 320
        local bottom = -320
        local left = offset + (interval * 4)
        local right = left + (interval * 2)

        local vertices =   
        {
            cc.p(left, top),
            cc.p(left, bottom),
            cc.p(right, bottom),
            cc.p(right, top),
        }  
        cc.DrawPrimitives.drawPoly(vertices, 4, true)

        cc.DrawPrimitives.drawLine(cc.p(offset, 0), cc.p(offset + (interval * 6), 0))
    end

    kmGLPopMatrix()
end

-------------------------------------
-- function isPossibleControl
-------------------------------------
function GameWorld:isPossibleControl()
    -- 강제적 조작 막음
    if (self.m_bPreventControl) then
        return false
    end

    -- 전투 중일 때에만
    if (not self.m_gameState:isFight()) then
        return false
    end

    -- 연출 중일 경우 입력 막음
    if (self.m_tamerSkillCut and self.m_tamerSkillCut:isPlaying()) then
        return false
    end

    -- 글로벌 쿨타임 중일 경우
    if (self.m_gameState:isWaitingGlobalCoolTime()) then
        return false
    end

    -- 드래곤 스킬 연출 중일 경우
    if (self.m_gameDragonSkill:isPlaying()) then
        return false
    end

    return true
end

-------------------------------------
-- function isOnFight
-------------------------------------
function GameWorld:isOnFight()
    return self.m_gameState:isFight()
end

-------------------------------------
-- function isParticipantMaxCount
-------------------------------------
function GameWorld:isParticipantMaxCount()
    return (#self.m_participants >= g_constant:get('INGAME', 'PARTICIPATE_DRAGON_CNT'))
end

-------------------------------------
-- function hasFriendHero
-------------------------------------
function GameWorld:hasFriendHero()
    return (not self.m_bUsedFriend and self.m_friendHero)
end

-------------------------------------
-- function addDropGold
-------------------------------------
function GameWorld:addDropGold(x, y)

    local gold_obj = ObjectGold(self, x, y)
    self:addChild2(gold_obj.m_animator.m_node, DEPTH_ITEM_GOLD)

    self.m_dropGoldIdx = (self.m_dropGoldIdx + 1)
    gold_obj.m_goldIdx = self.m_dropGoldIdx
    self.m_dropGoldList[self.m_dropGoldIdx] = gold_obj

    if (self.m_dropGoldIdx >= 1.79e+308) then
        self.m_dropGoldIdx = 0
    end
end

-------------------------------------
-- function removeDropGold
-------------------------------------
function GameWorld:removeDropGold(gold_obj)
    self.m_dropGoldList[gold_obj.m_goldIdx] = nil
end

-------------------------------------
-- function getTargetList
-------------------------------------
function GameWorld:getTargetList(char, x, y, team_type, formation_type, rule_type, t_data)
    local bLeftFormation = true

    if (char) then
        bLeftFormation = char.m_bLeftFormation
    end
    
    -- 팀 타입에 따른 델리게이트
    local for_mgr_delegate = nil
    if (team_type == 'self') then
        return {char}

    elseif (team_type == 'ally') then
        if (bLeftFormation) then
            for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr)
        end

    elseif (team_type == 'enemy') then
        if (bLeftFormation) then
            for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr)
        end

    elseif (team_type == 'all') then
        for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr, self.m_rightFormationMgr)
    end

    return for_mgr_delegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)
end

-------------------------------------
-- function changeCameraOption
-------------------------------------
function GameWorld:changeCameraOption(tParam, bKeepHomePos)
    local tParam = tParam or {}
    
    self.m_gameCamera:setAction(tParam)

    if not bKeepHomePos then
        self.m_gameCamera:setHomeInfo(tParam)
    end
end

-------------------------------------
-- function changeHeroHomePosByCamera
-------------------------------------
function GameWorld:changeHeroHomePosByCamera(offsetX, offsetY, move_time)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant(WAVE_INTERMISSION_TIME)

    -- 아군 홈 위치를 카메라의 홈위치 기준으로 변경
    for i, v in ipairs(self:getDragonList()) do
        if (v.m_bDead == false) then
            -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
            local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
            local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

            -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
            if (scale == 0.6) then
                homePosX = homePosX - 200
            end

            local distance = getDistance(v.pos.x, v.pos.y, homePosX, homePosY)
            if (distance > 0) then
                local speed
                if (move_time <= 0) then
                    speed = 9999
                else
                    speed = distance / move_time
                end

                v:changeHomePos(homePosX, homePosY, speed)
            end
        end
    end

    -- 미사일 제한 범위 재설정
    self:setMissileRange()
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorld:onEvent(event_name, t_event, ...)
    if (event_name == 'change_wave') then   self:onEvent_change_wave(event_name, t_event, ...)
    elseif (event_name == 'fever_start') then   self.m_gameState:changeState(GAME_STATE_FIGHT_FEVER)
    elseif (event_name == 'fever_end') then     self.m_gameState:changeState(GAME_STATE_FIGHT)
    elseif (event_name == 'hero_basic_skill') then
        -- 드래그 스킬 게이지
        local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_DRAG_POINT_INCREMENT_VALUE')
        self:addDragSkillCoolTime(t_temp['basic_skill'])

    elseif (event_name == 'hero_touch_skill') then
        -- 드래그 스킬 게이지
        local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_DRAG_POINT_INCREMENT_VALUE')
        self:addDragSkillCoolTime(t_temp['touch_skill'])

    elseif (event_name == 'hero_passive_skill') then
        -- 드래그 스킬 게이지
        local t_temp = g_constant:get('INGAME', 'DRAGON_SKILL_DRAG_POINT_INCREMENT_VALUE')
        self:addDragSkillCoolTime(t_temp['passive_skill'])
        
    end
end

-------------------------------------
-- function onEvent_change_wave
-- @brief 웨이브 변경
-------------------------------------
function GameWorld:onEvent_change_wave(event_name, t_event, ...)
    local arg = {...}
    local wave = arg[1]

    -- 모든 아군 최대체력의 10%를 회복
    if(1 < wave) then
        local percent = (10 / 100)
        local b_make_effect = true
        for _, char in pairs(self:getDragonList()) do
            char:healPercent(percent, b_make_effect)
        end
    end
end

-------------------------------------
-- function getEnemyList
-------------------------------------
function GameWorld:getEnemyList()
	return self.m_tEnemyList
end

-------------------------------------
-- function getDragonList
-- @brief 활성화된 드래곤 리스트 반환, 기획상 기준이 바뀔 가능성이 높기 때문에 함수로 관리
-------------------------------------
function GameWorld:getDragonList()
	return self.m_participants
end

-------------------------------------
-- function removeMissileAndSkill
-------------------------------------
function GameWorld:removeMissileAndSkill()
    self:cleanupSkill()

	for _, missile in pairs(self.m_lMissileList) do
		missile:changeState('dying')
	end
end

-------------------------------------
-- function setTemporaryPause
-- @brief 스킬 사용 도중 시전 드래곤을 제외하고 일시 정지
-------------------------------------
function GameWorld:setTemporaryPause(pause, excluded_dragon)
    -- 일시 정지
    if (pause) then
        self.m_gameState:pause()
        
        -- 맵 일시 정지
        self.m_mapManager:pause()

        -- unit들 일시 정지
        for i,v in pairs(self.m_lUnitList) do
            v:setTemporaryPause(true)
        end

        -- 미사일들 액션 정지
        local action_mgr = cc.Director:getInstance():getActionManager()
        for i,v in pairs(self.m_lMissileList) do
            action_mgr:pauseTarget(v.m_rootNode)
        end

        -- 스킬 사용 중인 드래곤은 일시 정지에서 제외 및 무적 상태
        if excluded_dragon then
            excluded_dragon:setTemporaryPause(false)
            excluded_dragon.enable_body = false
        end
    -- 전투 재개
    else
        self.m_gameState:resume()

        -- 맵 일시 정지 해제
        self.m_mapManager:resume()

        -- unit들 일시 정지 해제
        for i,v in pairs(self.m_lUnitList) do
            v:setTemporaryPause(false)
        end

        -- 미사일들 액션 재개
        local action_mgr = cc.Director:getInstance():getActionManager()
        for i,v in pairs(self.m_lMissileList) do
            action_mgr:resumeTarget(v.m_rootNode)
        end

        -- 스킬 사용 중인 드래곤 무적 해제
        if excluded_dragon then
            excluded_dragon.enable_body = true
        end
    end
end

-------------------------------------
-- function addDragSkillCoolTime
-------------------------------------
function GameWorld:addDragSkillCoolTime(point)
    self.m_dragSkillTimer = self.m_dragSkillTimer + point

    self.m_dragSkillTimer = math_min(self.m_dragSkillTimer, 100)

    self.m_inGameUI:setActiveSkillTime(self.m_dragSkillTimer, 100)
end

-------------------------------------
-- function resetDragSkillCoolTime
-------------------------------------
function GameWorld:resetDragSkillCoolTime()
    self.m_dragSkillTimer = 0

    self.m_inGameUI:setActiveSkillTime(self.m_dragSkillTimer, 100)

    for i, dragon in ipairs(self:getDragonList()) do
        dragon:updateDragSkill(0)
    end
end

-------------------------------------
-- function isEndDragSkillCoolTime
-------------------------------------
function GameWorld:isEndDragSkillCoolTime()
    return (self.m_dragSkillTimer >= 100)
end