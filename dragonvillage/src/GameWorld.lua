-------------------------------------
-- class GameWorld
-------------------------------------
GameWorld = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable(), {
        m_gameMode = 'number', -- ConstantGameMode.lua에 정의되어 있는 GAME_MODE_로 시작하는 식별값. GAME_MODE_ADVENTURE, GAME_MODE_NEST_DUNGEON ...
        m_stageID = 'number',
        m_inGameUI = 'UI_Game',
        m_bDevelopMode = 'boolean',
        m_bPauseMode = 'boolean',
        m_mPauseTag = 'table',      -- 기능별 일시정지 여부를 저장하기 위한 맵(현재는 액티브 스킬 연출이나 인디케이터 조작시 저장)

        m_worldLayer = 'cc.Node',
        m_gameNode1 = 'cc.Node',
        m_gameNode2 = 'cc.Node',
        m_gameNode3 = 'cc.Node',
        
        m_gridNode = 'cc.Node',
        m_bgNode = 'cc.Node',
        m_darkLayer = 'cc.LayerColor',
        m_dragonSkillBgNode = 'cc.Node',
        m_groundNode = 'cc.Node',
        m_bottomNode = 'cc.Node',       -- 미사일 또는 이펙트에서 사용
        m_worldNode = 'cc.Node',
        m_missiledNode = 'cc.Node',

        m_unitStatusNode = 'cc.Node',
        m_lockOnNode = 'cc.Node',
		m_unitInfoNode = 'cc.Node',
        m_enemySpeechNode = 'cc.Node',

        m_dragonInfoNode = 'cc.Node',

        -- 드래곤의 잔상을 찍기 위한 배치노드
        m_mDragonRenderTextureBatchNode = 'map',

        m_lUnitList = 'list',
		m_lSkillList = 'table',
		m_lMissileList = 'table',
		m_lSpecailMissileList = 'table',
        
        -- unit
        m_leftParticipants = 'table',     -- 전투에 참여중인 아군
        m_rightParticipants = 'table',    -- 전투에 참여중인 적군(드래곤이라도 적 진형이라면 여기에 추가됨)
        m_leftNonparticipants = 'table',  -- 참여중인 아군 중 죽은 아군(부활 가능한 대상만)
        m_rightNonparticipants = 'table', -- 참여중인 적군 중 죽은 적군(부활 가능한 대상만)
        m_mUnitGroup = 'table',           -- 유닛 그룹별 GameUnitGroup 맵
		
        m_deckFormation = 'string',
        m_deckFormationLv = 'number',

        m_physWorld = 'PhysWorld',


        m_missileFactory = '',

        -- 웨이브 매니져
        m_waveMgr = '',

        m_gameState = '',
        m_gameCoolTime = '',
        m_gameActiveSkillMgr = '',
        m_gameDragonSkill = '',
        m_gameCamera = '',
        m_gameTimeScale = '',
        m_gameHighlight = '',
        m_dropItemMgr = '',
        m_gameWorldGold = 'GameWorld_Gold',

        m_worldSize = '',
        m_worldScale = '',

        m_missileRange = 'table',

        -- callback
        m_lWorldScaleChangeCB = 'list',
 
        m_skillIndicatorMgr = 'SkillIndicatorMgr',
        m_enemyMovementMgr = 'EnemyMovementMgr',

		-- 테이머 관련
        m_tamer = 'Tamer',
                        
        m_formationDebugNode = '',

        m_touchMotionStreak = 'cc.MotionStreak',
        m_touchPrevPos = '{x, y}',
        m_tCollisionTime = 'table',

        m_mapManager = 'MapManager',
		m_shakeMgr = 'ShakeManager',
		m_missionMgr = 'StageMissionMgr',
		m_logRecorder = 'LogRecorderWorld',

        m_mPassiveEffect = 'list',  -- 버프 텍스트를 표시하기 위한 테이블
        m_mSkillSpeech = 'list',    -- 스킬 이름을 표시하기 위한 테이블

        -- 친구 영웅 관련
        m_bUsedFriend = 'boolean',
        m_friendDragon = 'Dragon',

        -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
        m_myDragons = 'Dragons',

        m_bGameFinish = 'bool',

        -- 테스트를 위한 임시 변수
        m_test = 'number',
    })


local counter = Counter()

DEPTH_GUARD_EFFECT = counter:get()
DEPTH_ITEM_GOLD = counter:get()
DEPTH_INSTANT_EFFECT = counter:get()
DEPTH_DAMAGE_EFFECT = counter:get()

DEPTH_DAMAGE_FONT = counter:get()
DEPTH_HEAL_FONT = counter:get()
DEPTH_MISS_FONT = counter:get()
DEPTH_BLOCK_FONT = counter:get()
DEPTH_IMMUNE_FONT = counter:get()
DEPTH_DRAGON_SPEECH = counter:get()
DEPTH_DRAGON_SPEECH_TEXT = counter:get()
DEPTH_PASSIVE_FONT = counter:get()

-------------------------------------
-- function init
-------------------------------------
function GameWorld:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode)
    self.m_gameMode = game_mode
    self.m_stageID = stage_id
    self.m_inGameUI = ui
    
    if isExistValue(self.m_gameMode, GAME_MODE_DIMENSION_GATE) then
        self.m_inGameUI:lockAutoButton()
    end

    self.m_worldLayer = world_node
    self.m_worldLayer:setPosition(-640, 0)
    self:makeDebugLayer()

    self.m_gameNode1 = game_node1
    self.m_gameNode2 = game_node2
    self.m_gameNode3 = game_node3
        
    self.m_bDevelopMode = develop_mode or false
    self.m_bPauseMode = false
    self.m_mPauseTag = {}

    self.m_bgNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_bgNode, INGAME_LAYER_Z_ORDER.BG_LAYER)

    self.m_darkLayer = cc.LayerColor:create()
	self.m_darkLayer:setColor(cc.c3b(0, 0, 0))
	self.m_darkLayer:setOpacity(100)
	self.m_darkLayer:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_darkLayer:setDockPoint(cc.p(0, 0.5))
	self.m_darkLayer:setNormalSize(4000, 2000)
	self.m_darkLayer:setVisible(false)
	self.m_gameNode1:addChild(self.m_darkLayer, INGAME_LAYER_Z_ORDER.DARK_LAYER)

    self.m_dragonSkillBgNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_dragonSkillBgNode, INGAME_LAYER_Z_ORDER.DRAGON_SKILL_BG_LAYER)
    
    self.m_groundNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_groundNode, INGAME_LAYER_Z_ORDER.GROUND_LAYER)

	-- 그리드 노드
    self.m_gridNode = cc.Node:create()
    self.m_gridNode:setVisible(false)
    self.m_gameNode1:addChild(self.m_gridNode, INGAME_LAYER_Z_ORDER.GRID_LAYER)

    self.m_bottomNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_bottomNode, INGAME_LAYER_Z_ORDER.BOTTOM_LAYER)

    self.m_worldNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_worldNode, INGAME_LAYER_Z_ORDER.WORLD_LAYER)

    self.m_missiledNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_missiledNode, INGAME_LAYER_Z_ORDER.MISSILE_LAYER)
	
    do -- 유닛 공통 레이어 (적군)
        self.m_unitStatusNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_unitStatusNode, INGAME_LAYER_Z_ORDER.UNIT_STATUS_LAYER)

	    self.m_unitInfoNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_unitInfoNode, INGAME_LAYER_Z_ORDER.UNIT_INFO_LAYER)

        self.m_enemySpeechNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_enemySpeechNode, INGAME_LAYER_Z_ORDER.ENEMY_SPEECH_LAYER)

        self.m_lockOnNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_lockOnNode, INGAME_LAYER_Z_ORDER.LOCK_ON_LAYER)
    end

    do -- 드래곤 공통 레이어
        self.m_dragonInfoNode = cc.Node:create()
        self.m_gameNode1:addChild(self.m_dragonInfoNode, INGAME_LAYER_Z_ORDER.DRAGON_INFO_LAYER)
    end
    
    self.m_mDragonRenderTextureBatchNode = {}

    self.m_lUnitList = {}
	self.m_lSkillList = {}
	self.m_lMissileList = {}
	self.m_lSpecailMissileList = {}
    
    self.m_physWorld = PhysWorld(self.m_gameNode1, false)
    self.m_physWorld:initGroup()

    self.m_mUnitGroup = {}
    self.m_leftParticipants = {}
    self.m_rightParticipants = {}
    self.m_leftNonparticipants = {}
    self.m_rightNonparticipants = {}

    self.m_missileFactory = MissileFactory(self)

    self.m_worldSize = nil
    self.m_worldScale = nil

    self.m_missileRange = {}

    -- callback
    self.m_lWorldScaleChangeCB = {}

    g_currScene:addKeyKeyListener(self)

    self.m_touchPrevPos = nil
    self.m_tCollisionTime = {}

    self.m_mPassiveEffect = {}
    self.m_mSkillSpeech = {}

    self.m_bUsedFriend = false
    self.m_friendDragon = nil

    self.m_bGameFinish = false
end

-------------------------------------
-- function createComponents
-- @brief 구성 요소들을 생성
-------------------------------------
function GameWorld:createComponents()
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameTimeScale = GameTimeScale(self)
    self.m_gameHighlight = GameHighlightMgr(self, self.m_darkLayer)
    self.m_gameActiveSkillMgr = GameActiveSkillMgr(self)
    self.m_gameDragonSkill = GameDragonSkill(self)
    self.m_shakeMgr = ShakeManager(self, g_gameScene.m_shakeLayer)

    -- 글로벌 쿨타임
    self.m_gameCoolTime = GameCoolTime(self)
    self:addListener('set_global_cool_time_active', self.m_gameCoolTime)

    -- 유닛 그룹별 관리자 생성
    self.m_mUnitGroup[PHYS.HERO] = GameUnitGroup(self, PHYS.HERO)
    self.m_mUnitGroup[PHYS.HERO]:createMana(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:createAuto(self.m_inGameUI)
    self.m_mUnitGroup[PHYS.HERO]:setAttackbleGroupKeys({PHYS.ENEMY})

    self.m_mUnitGroup[PHYS.ENEMY] = GameUnitGroup(self, PHYS.ENEMY)
    self.m_mUnitGroup[PHYS.ENEMY]:createMana()
    self.m_mUnitGroup[PHYS.ENEMY]:createAuto()
    self.m_mUnitGroup[PHYS.ENEMY]:setAttackbleGroupKeys({PHYS.HERO})

    -- 상태 관리자
    do
        -- ## 모드별 분기 처리
        local display_wave = true
        local display_time = nil

	    -- 1. 모험 모드
        if (self.m_gameMode == GAME_MODE_ADVENTURE) then
            self.m_gameState = GameState(self)

	    -- 2. 네스트 던전
        elseif (self.m_gameMode == GAME_MODE_NEST_DUNGEON) then
            local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
            local dungeonMode = t_dungeon['dungeon_mode']
            local detail_mode = t_dungeon['detail_mode']

            -- "진화 재료 던전"
            if (dungeonMode == NEST_DUNGEON_EVO_STONE) then
                -- "보석 던전"
                if (detail_mode == NEST_DUNGEON_SUB_MODE_JEWEL) then
                    self.m_gameState = GameState_NestDungeon_Jewel(self)
                -- "거대용 던전"
                else
                    self.m_gameState = GameState_NestDungeon_Dragon(self)
                end

		    elseif (dungeonMode == NEST_DUNGEON_NIGHTMARE) then
		        self.m_gameState = GameState_NestDungeon_Nightmare(self)

            elseif (dungeonMode == NEST_DUNGEON_TREE) then
                self.m_gameCamera:setRange({minX = -640, maxX = 640})
            
                self.m_gameState = GameState_NestDungeon_Tree(self)

            elseif (dungeonMode == NEST_DUNGEON_GOLD) then
                self.m_gameState = GameState_NestDungeon_Gold(self)

		    else
			    error('네스트 던전 아이디가 잘못되어있습니다. 확인해주세요. ' .. self.m_stageID)
            end


	    -- 3. 비밀 던전
        elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON) then
            local t_dungeon = g_secretDungeonData:parseSecretDungeonID(self.m_stageID)
            local dungeonMode = t_dungeon['dungeon_mode']

            if (dungeonMode == SECRET_DUNGEON_GOLD) then
                self.m_gameState = GameState_NestDungeon_Gold(self)
                -- display_wave = false
			    -- display_time = self.m_gameState.m_limitTime

            elseif (dungeonMode == SECRET_DUNGEON_RELATION) then
                self.m_gameState = GameState_SecretDungeon_Relation(self)
            end

        -- 4. 고대의 탑
        elseif (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
            self.m_gameState = GameState_AncientTower(self)

        -- 5. 이벤트 금화 던전
        elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
            self.m_gameState = GameState_EventGold(self)

        -- 6. 룬 수호자 던전
        elseif (self.m_gameMode == GAME_MODE_RUNE_GUARDIAN) then
            self.m_gameState = GameState_RuneGuardianDungeon(self)

            -- 마나가 동작 하지 않음
            self.m_mUnitGroup[PHYS.HERO]:getMana():setManaZero()

        -- 7. 차원문 던전
        elseif (self.m_gameMode == GAME_MODE_DIMENSION_GATE) then
            self.m_gameState = GameState_Dmgate(self)

        -- 7. 레이드 던전
        elseif (self.m_gameMode == GAME_MODE_LEAGUE_RAID) then
            self.m_gameState = GameState_LeagueRaid(self)
            self.m_inGameUI:offAutoStart()

        -- 8. 드래곤 스토리 던전
        elseif (self.m_gameMode == GAME_MODE_STORY_DUNGEON) then
            self.m_gameState = GameState_StoryDungeonEvent(self)

        
        end
        
        -- 7. 깜짝 출현 던전
        if (isAdventStageID(self.m_stageID)) then
            self.m_inGameUI:setSnowParticle()
        end
        
        self.m_inGameUI:init_timeUI(display_wave, 0)
        self.m_inGameUI:init_speedUI()
    end

    self:initGold()
    self:setMissileRange()
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorld:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()

    local t_dungeon = g_nestDungeonData:parseNestDungeonID(self.m_stageID)
    local dungeonMode = t_dungeon['dungeon_mode']

    -- 웨이브 매니져 생성
    if (self.m_gameMode == GAME_MODE_ANCIENT_TOWER) then
        self.m_waveMgr = WaveMgr_AncientTower(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    elseif (self.m_gameMode == GAME_MODE_SECRET_DUNGEON and dungeonMode == SECRET_DUNGEON_RELATION) then
        self.m_waveMgr = WaveMgr_SecretRelation(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    else
        self.m_waveMgr = WaveMgr(self, stage_name, self.m_stageID, self.m_bDevelopMode)
    end

	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)
    
    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 친구 드래곤 생성
    self:makeFriendHero()

    -- 초기 쿨타임 설정
    self:initActiveSkillCool(self:getDragonList())
    
    -- 초기 마나 설정
    self.m_mUnitGroup[PHYS.HERO]:getMana():addMana(START_MANA)

    do -- 진형 시스템 초기화
        self:setBattleZone(self.m_deckFormation, true)
    end

    -- 스킬 조작계 초기화
    do
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
    end
    
    
    local game_mode = g_stageData:getGameMode(self.m_stageID) -- @jhakim 190604 환상던전이 황금던전 모드를 사용하는 중, 진짜 황금던전인지 확인
    -- 드랍 아이템 매니져 생성
    if (game_mode == GAME_MODE_EVENT_ILLUSION_DUNSEON) then
        -- 환상던전의 경우 드롭 매니저 생성하지 않고 지나감
    elseif (self.m_gameMode == GAME_MODE_ADVENTURE) then
        self.m_dropItemMgr = DropItemMgr(self)

        -- 일일 드랍 획득량 버튼 생성
        self.m_inGameUI:showAutoItemPickUI()
    elseif (self.m_gameMode == GAME_MODE_EVENT_GOLD) then
        self.m_dropItemMgr = DropItemMgr_EventGold(self)
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

    -- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)

	-- mission manager 생성
	if (self.m_gameMode == GAME_MODE_ADVENTURE) then
		if (not self.m_bDevelopMode) then
			self.m_missionMgr = StageMissionMgr(self.m_logRecorder, self.m_stageID)
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
    local attr = TableStageData():getValue(self.m_stageID, 'attr')

    if (bg_type == 'animation') then
        self.m_mapManager = AnimationMap(self.m_bgNode, bg_res)

    elseif (bg_type == 'default') then
        -- 고대 유적 던전의 경우 저사양모드일 경우 map 데이터 변환
        if (isLowEndMode() and self.m_gameMode == GAME_MODE_ANCIENT_RUIN) then
            bg_res = string.gsub(bg_res, 'map_', 'map_low_')
        end

        -- 고대의 탑, 시험의 탑 map 데이터 변환
        if (g_ancientTowerData:isAncientTowerStage(self.m_stageID)) then
            bg_res = g_attrTowerData:changeBgRes(bg_res)
        end

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
    local tamer_id = g_tamerData:getCurrTamerID()
    local t_tamer_data = clone(g_tamerData:getTamerServerInfo(tamer_id))
    local t_costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)
    
    -- 테이머 생성
    self.m_tamer = self:makeTamerNew(t_tamer_data, t_costume_data)

    -- 테이머 UI 생성
	self.m_inGameUI:initTamerUI(self.m_tamer)

    self:addListener('dragon_summon', self)
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
    self.m_gameWorldGold = GameWorld_Gold(self)
end

-------------------------------------
-- function getGold
-------------------------------------
function GameWorld:getGold()
    local gold = 0

    if (self.m_gameWorldGold) then
        gold = math_floor(self.m_gameWorldGold:getObtainGold())
    end

    return gold
end

-------------------------------------
-- function updateUnit
-- @param dt
-------------------------------------
function GameWorld:updateUnit(dt)
    local t_remove = {}
    for i,v in ipairs(self.m_lUnitList) do
        -- 상태 효과의 경우는 일시 정지 상태에서도 업데이트
        if (isInstanceOf(v, StatusEffect)) then
            local modified_dt = dt

            if (v.m_temporaryPause) then
                modified_dt = 0
            end

            -- update 리턴값이 true이면 객체 삭제
            if (v:update(modified_dt)) then
                table.insert(t_remove, 1, i)
                v:release()
            end

        -- 일시 정지 상태가 아닌 경우에만 업데이트
        elseif (not v.m_temporaryPause) then

            -- update 리턴값이 true이면 객체 삭제
            if (v:update(dt)) then
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
-- function cleanupSkill
-------------------------------------
function GameWorld:cleanupSkill()
    local count = 0
    
    -- 스킬 다 날려 버리자
	for _, v in pairs(self.m_lSkillList) do
        -- 웨이브 지속 스킬인 경우는 삭제하지 않음
        if v:isWaveRetainSkill() ~= true or self.m_waveMgr:isFinalWave() == true then
            v:changeState('dying', true)
            count = count + 1
        end
    end

    return count
end

-------------------------------------
-- function cleanupItem
-------------------------------------
function GameWorld:cleanupItem()
    if (self.m_dropItemMgr) then
        self.m_dropItemMgr:cleanupItem()
    end
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
-- function updateBefore
-- @param dt
-------------------------------------
function GameWorld:updateBefore(dt)
    -- 물리 이동 및 충돌 처리
    if (self.m_physWorld) then
        self.m_physWorld:update(dt)
    end

    -- 인디케이터
    if (self.m_skillIndicatorMgr) then
        self.m_skillIndicatorMgr:update(dt)
    end
end

-------------------------------------
-- function update
-- @param dt
-------------------------------------
function GameWorld:update(dt)
    self:updateUnit(dt)

    if (self.m_mapManager) then
        self.m_mapManager:update(dt)
    end

    if (self.m_gameState) then
        self.m_gameState:update(dt)
    end

    if (self.m_gameCoolTime) then
        self.m_gameCoolTime:update(dt)
    end

    if (self.m_gameCamera) then
        self.m_gameCamera:update(dt)
    end

    if (self.m_gameTimeScale) then
        self.m_gameTimeScale:update(dt)
    end

    if (self.m_dropItemMgr) then
        self.m_dropItemMgr:update(dt)
    end
end

-------------------------------------
-- function updateAfter
-- @param dt
-------------------------------------
function GameWorld:updateAfter(dt)
    -- 드래곤 액티브 스킬 연출
    if (self.m_gameDragonSkill) then
        self.m_gameDragonSkill:update(dt)
    end

    -- 하이라이트 연출
    if (self.m_gameHighlight) then
        self.m_gameHighlight:update(dt)
    end

    -- 버프 텍스트
    do
        for char, v in pairs(self.m_mPassiveEffect) do
            if (not char:isDead()) then
                self:makePassiveStartEffect(char, v)
            end
        end
        self.m_mPassiveEffect = {}
    end

    -- 스킬 이름
    do
        for char, v in pairs(self.m_mSkillSpeech) do
            if (not char:isDead(true)) then
                SkillHelper:makePassiveSkillSpeech(char, v)
            end
        end
        self.m_mSkillSpeech = {}
    end

    -- 사용 등록된 액티브 스킬 처리
    if (self.m_gameActiveSkillMgr) then
        self.m_gameActiveSkillMgr:update(dt)
    end
end

-------------------------------------
-- function addPassiveStartEffect
-- @brief
-------------------------------------
function GameWorld:addPassiveStartEffect(char, str, category)
    local category = category or 'good'

    if (not self.m_mPassiveEffect[char]) then
		self.m_mPassiveEffect[char] = {}
	end
	self.m_mPassiveEffect[char][str] = category
end

-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorld:makePassiveStartEffect(char, str_map)
    local root_node = cc.Node:create()
    root_node:setPosition(char.pos.x, char.pos.y)
    self:addChild3(root_node, DEPTH_PASSIVE_FONT)
    
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
    --node:runAction(cc.MoveTo:create(3, cc.p(0, 160)))
    node:runAction(cc.MoveTo:create(3, cc.p(0, 220)))

    -- 패시브명 label 생성
    local i = 1
    local font_scale_x, font_scale_y = Translate:getFontScaleRate()
    for str, category in  pairs(str_map) do
        local label = cc.Label:createWithTTF(Str(str), Translate:getFontPath(), 26, 3, cc.size(200, 50), 1, 1)
        node:addChild(label)
        label:setScale(0.2 * font_scale_x, 0.2 * font_scale_y)
        label:runAction( cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2 * font_scale_x, 1.2 * font_scale_y), cc.ScaleTo:create(0.3, font_scale_x, font_scale_y), cc.DelayTime:create(1.6), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        label:setPositionY((i-1) * 30)

        if (category == 'good') then
            label:setTextColor(cc.c4b(120, 209, 255, 255))
        elseif (category == 'bad') then
            label:setTextColor(cc.c4b(255, 138, 138, 255))
        end

        i = i + 1
    end

    -- 2초 후 삭제
    root_node:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.RemoveSelf:create()))

    -- 실시간 위치 동기화
    root_node:scheduleUpdateWithPriorityLua(function(dt) 
        root_node:setPosition(char.pos.x, char.pos.y)
    end, 0)

    return root_node
end

-------------------------------------
-- function addSkillSpeech
-- @brief
-------------------------------------
function GameWorld:addSkillSpeech(char, str)
    if (not self.m_mSkillSpeech[char]) then
		self.m_mSkillSpeech[char] = {}
	end
	self.m_mSkillSpeech[char] = str
end

-------------------------------------
-- function addDestructibleMissile
-------------------------------------
function GameWorld:addDestructibleMissile(missile)
	self:addToSpecailMissileList(missile)
end

-------------------------------------
-- function addMissile
-- @param res_depth : 어느 노드에 addchild 할지 결정한다. ;를 사용하여 z-order를 명시할수도 있다. ex) 'res_depth':'bottom;1'
-------------------------------------
function GameWorld:addMissile(missile, object_key, layer_depth, res_depth)
    self:addToMissileList(missile)
    self.m_physWorld:addObject(object_key, missile)
    
	local t_res_depth = plSplit(res_depth, ';') or {}

	local depth_type = t_res_depth[1]
	local z_order = t_res_depth[2] or WORLD_Z_ORDER.MISSILE

	-- 미사일 리소스명으로 layer_depth를 나눔. 퍼포먼스 개선을 위해
	-- 동일한 리소스는 동일한 레이어에 찍는 것이 목적 sgkim 2017-08-21
    z_order = (layer_depth * 100) + z_order

	local target_node = self:getMissileNode(depth_type)
    target_node:addChild(missile.m_rootNode, z_order)
end

-------------------------------------
-- function getMissileNode
-- @brief
-------------------------------------
function GameWorld:getMissileNode(depth_type)
    local missile_node

    if (depth_type == 'bottom') then
		--missile_node = self.m_worldNode
        missile_node = self.m_bottomNode
	else
		missile_node = self.m_missiledNode
	end	
    
    return missile_node
end

-------------------------------------
-- function findTarget
-------------------------------------
function GameWorld:findTarget(char, x, y, l_remove)
    local unitList = self:getTargetList(char, x, y, 'enemy', nil, 'distance_line')
    local distance = nil
    local target

    for i,v in pairs(unitList) do
        if (v:isDead()) then
        elseif (l_remove and table.find(l_remove, v.phys_idx)) then
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
-- function setWaitAllCharacter
-------------------------------------
function GameWorld:setWaitAllCharacter(wait)
    for i,v in ipairs(self:getEnemyList()) do
        v:setWaitState(wait)
    end

    for i,v in ipairs(self:getDragonList()) do
        v:setWaitState(wait)
    end

    if (self.m_tamer) then
        self.m_tamer:setWaitState(wait)
    end
end

-------------------------------------
-- function makeInstantEffect
-- @brief 단발성 이펙트 생성
-------------------------------------
function GameWorld:makeInstantEffect(res, ani_name, x, y)
    local effect = MakeAnimator(res)
    if (not effect.m_node) then return end

    effect:setPosition(x, y)
    effect:changeAni(ani_name, false)
    local duration = effect:getDuration()
    effect.m_node:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    return effect
end

-------------------------------------
-- function addInstantEffect
-- @brief 단발성 이펙트 생성
-------------------------------------
function GameWorld:addInstantEffect(res, ani_name, x, y)
    local effect = self:makeInstantEffect(res, ani_name, x, y)
    if (effect) then
        self:addChild2(effect.m_node, DEPTH_INSTANT_EFFECT)
    end
    return effect
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

    local x_start_offset = 150 + 85
    if (is_right) then
        offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) + x_start_offset
        offset_y = cameraHomePosY + 30
        lUnitList = self.m_rightParticipants
    else
        offset_x = cameraHomePosX + (CRITERIA_RESOLUTION_X / 2) - x_start_offset - rage
        offset_y = cameraHomePosY + 30
        lUnitList = self.m_leftParticipants
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
    -- 전투 중일 때에만
    if (not self.m_gameState:isFight()) then
        return false
    end

    -- 글로벌 쿨타임 중일 경우
    if (self.m_gameCoolTime:isWaiting(GLOBAL_COOL_TIME.ACTIVE_SKILL)) then
        return false
    end

    -- 액티브 스킬 연출 중일 경우
    if (self.m_gameDragonSkill:isPlaying()) then
        return false
    end

    return true
end

-------------------------------------
-- function generateFinalTargetList
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- 얽힌게 많아서 여기서만 깔짝대기로 결정
-- 타깃리스트와 스킬정보를 받아서 최종 리스트를 반환
-------------------------------------
function GameWorld:generateFinalTargetList(l_target, is_active_skill)
    local l_result = {}

    if (not l_target) then return l_result end

    local l_status_effect_filtered = self:resetListByStatusEffect(l_target, is_active_skill)

    for _, character in pairs(l_status_effect_filtered) do
        -- attacked_type 지정되어 있고
        -- attacked_type 에 따라 공격 가능한 리스트 리턴
        -- 본인이 알아서 죽을 때까지 내버려 둬야함으로
        -- 리스트에서 제외
        if (character.m_charTable and character.m_charTable['attacked_type']) then
            local isSkillOnly = character.m_charTable['attacked_type'] == 'active_only'
            local isInvincible = character.m_charTable['attacked_type'] == 'invincible'
            local isBoth = character.m_charTable['attacked_type'] == 'both'

            if (self.m_skillIndicatorMgr:isControlling() and isSkillOnly) then
                -- 스킬인데 스킬만 먹는 타입이라면?
                table.insert(l_result, character)
            elseif (isBoth) then
                table.insert(l_result, character)

            end
        else
            table.insert(l_result, character)
        end
    end

    return l_result
end

-------------------------------------
-- function resetListByStatusEffect
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- 얽힌게 많아서 여기서만 깔짝대기로 결정
-- 타깃리스트와 스킬정보를 받아서 최종 리스트를 반환
-------------------------------------
function GameWorld:resetListByStatusEffect(l_target, is_active_skill)
    local l_result = {}
    if (not l_target) then return l_result end

    for _, character in pairs(l_target) do
        local isAttackable = character:isAttackable(is_active_skill)

        if (isAttackable == true) then
            table.insert(l_result, character)
        end
    end

    return l_result
end



-------------------------------------
-- function getTargetList
-------------------------------------
function GameWorld:getTargetList(char, x, y, team_type, formation_type, rule_type, t_data, is_active_skill)
    local formation_type = formation_type or ''
    local group_key = char:getPhysGroup()
    local unit_group = self:getUnitGroupConsideredTamer(char)

    local t_data = t_data or {}

    local l_result = {}


    t_data['self'] = char
    t_data['team_type'] = team_type
    t_data['game_mode'] = self.m_gameMode

    -- 팀 타입에 따른 델리게이트
    local for_mgr_delegate = FormationMgrDelegate()

    --if (team_type == 'self') then
    if (pl.stringx.startswith(team_type, 'self')) then
        local mgr = unit_group:getFormationMgr()

        for_mgr_delegate:addGlobalList(mgr.m_globalCharList)
        for_mgr_delegate:addDiedList(mgr.m_diedCharList)
    
    elseif (isExistValue(team_type, 'boss')) then
        for_mgr_delegate:addGlobalList(self.m_leftParticipants)
        for_mgr_delegate:addGlobalList(self.m_rightParticipants)
        for_mgr_delegate:addDiedList(self.m_leftNonparticipants)
        for_mgr_delegate:addDiedList(self.m_rightNonparticipants)
        l_result = for_mgr_delegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)
        
    elseif (isExistValue(team_type, 'teammate', 'ally')) then
        local l_attackable_group_key = {}

        if (rule_type == 'all') then
            if (char.m_bLeftFormation) then
                l_attackable_group_key = self:getHeroGroups()
            else
                l_attackable_group_key = self:getEnemyGroups()
            end
        else
            l_attackable_group_key = { unit_group:getGroupKey() }
        end

        for _, group_key in ipairs(l_attackable_group_key) do
            local unit_group = self.m_mUnitGroup[group_key]
            if (unit_group) then
                local mgr = unit_group:getFormationMgr()

                for_mgr_delegate:addGlobalList(mgr.m_globalCharList)
                for_mgr_delegate:addDiedList(mgr.m_diedCharList)
            end
        end

    elseif (team_type == 'enemy') then
        local l_attackable_group_key = {}

        if (rule_type == 'all' or t_data['all']) then
            if (char.m_bLeftFormation) then
                l_attackable_group_key = self:getEnemyGroups()
            else
                l_attackable_group_key = self:getHeroGroups()
            end

        elseif (string.find(formation_type, 'team1')) then
            if (char.m_bLeftFormation) then
                l_attackable_group_key = { PHYS.ENEMY_TOP }
            else
                l_attackable_group_key = { PHYS.HERO_TOP }
            end
            
        elseif (string.find(formation_type, 'team2')) then
            if (char.m_bLeftFormation) then
                l_attackable_group_key = { PHYS.ENEMY_BOTTOM }
            else
                l_attackable_group_key = { PHYS.HERO_BOTTOM }
            end
            
        else
            l_attackable_group_key = unit_group:getAttackbleGroupKeys()
        end

        for _, group_key in ipairs(l_attackable_group_key) do
            local unit_group = self.m_mUnitGroup[group_key]
            if (unit_group) then
                local mgr = unit_group:getFormationMgr()

                for_mgr_delegate:addGlobalList(mgr.m_globalCharList)
                for_mgr_delegate:addDiedList(mgr.m_diedCharList)
            end
        end

        -- 만약 해당 그룹에 적이 하나도 없을 경우 모든 적을 대상으로 변경
        if (for_mgr_delegate:isEmpty() and rule_type ~= 'all' and not t_data['all']) then
            t_data['all'] = true
            local origin_list = self:getTargetList(char, x, y, team_type, formation_type, rule_type, t_data)

            -- 액티브 스킬이 아닐 때 체크
            -- 액티브 스킬에만 반응하는 오브젝트를 위해서
            -- 해당값이 false면 리스트 가공 안함
            l_result = self:generateFinalTargetList(origin_list, is_active_skill)
        end

    elseif (team_type == 'all') then
        if (rule_type == '' or rule_type == 'all') then
            -- 팀에 상관없이 아군, 적군 모두 대상
            for_mgr_delegate:addGlobalList(self.m_leftParticipants)
            for_mgr_delegate:addGlobalList(self.m_rightParticipants)
            for_mgr_delegate:addDiedList(self.m_leftNonparticipants)
            for_mgr_delegate:addDiedList(self.m_rightNonparticipants)
        else
            -- 자신의 팀
            do
                local mgr = unit_group:getFormationMgr()

                for_mgr_delegate:addGlobalList(mgr.m_globalCharList)
                for_mgr_delegate:addDiedList(mgr.m_diedCharList)
            end
            
            -- 공격 가능한 팀이 대상
            do
                for _, group_key in ipairs(unit_group:getAttackbleGroupKeys()) do
                    local unit_group = self.m_mUnitGroup[group_key]
                    if (unit_group) then
                        local mgr = unit_group:getFormationMgr()

                        for_mgr_delegate:addGlobalList(mgr.m_globalCharList)
                        for_mgr_delegate:addDiedList(mgr.m_diedCharList)
                    end
                end
            end
        end

    else
		error('GameWorld:getTargetList 정의 되지 않은 team_type  : ' .. team_type)

    end


    -- 필드에 적이 아무도 없을 때 
    -- pvp 상대 테이머 그룹에서 살아있는 덱정보를 가져온다.
    if (not l_result or #l_result <= 0) then
        local default_origin_list = for_mgr_delegate:getTargetList(x, y, team_type, formation_type, rule_type, t_data)

        -- 나자신이나 아군에게 쓰는것이 아니면 타게팅 제한 버프 체크
        if (isExistValue(team_type, 'teammate', 'ally') or pl.stringx.startswith(team_type, 'self')) then
            l_result = default_origin_list

        else
            l_result = self:generateFinalTargetList(default_origin_list, is_active_skill)
        end
    end

    return l_result
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
function GameWorld:changeHeroHomePosByCamera(offsetX, offsetY, move_time, no_tamer)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local gap_x, gap_y = self.m_gameCamera:getIntermissionOffset()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant("WAVE_INTERMISSION_TIME")

    -- 아군 홈 위치를 카메라의 홈위치 기준으로 변경
    local l_temp = table.merge(self.m_leftParticipants, self.m_leftNonparticipants)

    for _, v in pairs(l_temp) do
        -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
        local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
        local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

        -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
        if (scale == 0.6) then
            homePosX = homePosX - 200
        end
            
        v:changeHomePosByTime(homePosX, homePosY, move_time)
    end

    if (not no_tamer and self.m_tamer) then
        -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
        local homePosX = self.m_tamer.pos.x + gap_x + offsetX
        local homePosY = self.m_tamer.pos.y + gap_y + offsetY

        -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
        if (scale == 0.6) then
            homePosX = homePosX - 200
        end

        self.m_tamer:changeHomePosByTime(homePosX, homePosY, move_time)
    end

    -- 미사일 제한 범위 재설정
    self:setMissileRange()
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorld:onEvent(event_name, t_event, ...)

    if (event_name == 'change_wave') then
        self:onEvent_change_wave(event_name, t_event, ...)
        for k, v in pairs(self.m_lUnitList) do
            if (isInstanceOf(v, Character)) then
                v:dispatch('change_wave')
            end
        end

    elseif (event_name == 'dragon_summon') then
        if (self.m_tamer) then
            self.m_tamer.m_animator:changeAni('i_summon', false)
            self.m_tamer.m_animator:addAniHandler(function()
                self.m_tamer.m_animator:changeAni('i_idle', true)
            end)
        end

    elseif (event_name == 'character_recovery') then
        local arg = {...}
        local unit = arg[1]

        unit:dispatch('self_recovery', t_event, unit)

        for _, fellow in pairs(unit:getFellowList()) do

            fellow:dispatch('ally_recovery', t_event, unit)
            if (unit ~= fellow) then
                fellow:dispatch('teammate_recovery', t_event, unit)
            end
        end

        for _, opponent in pairs(unit:getOpponentList()) do
            opponent:dispatch('enemy_recovery', t_event)
        end

    elseif (event_name == 'character_set_hp') then
        local arg = {...}
        local unit = arg[1]
        
        -- 롤백이 필요할 수도 있음
        if (SEQUENTIAL_PERFECT_BARRIER == true) then
            -- 무적 스킬류는 여기서 발동 시킴
            unit:doPerfectBarrierSkill(t_event)
        end

        unit:dispatch('under_self_hp', t_event, unit)

        -- 자기 자신도 포함
        for _, fellow in pairs(unit:getFellowList()) do
            
            fellow:dispatch('under_ally_hp', t_event, unit)
            if (unit ~= fellow) then
                fellow:dispatch('under_teammate_hp', t_event, unit)
            end
        end

        -- 자기 자신도 포함
        for _, fellow in pairs(unit:getOpponentList()) do
            fellow:dispatch('under_enemy_hp', t_event, unit)
        end

    
    elseif (event_name == 'character_dead') then
        local arg = {...}
        local unit = arg[1]

        for _, fellow in pairs(unit:getFellowList()) do

            fellow:dispatch('ally_dead', t_event, unit)
            if (unit == fellow) then
                fellow:dispatch('dead', t_event, unit)
            else
                fellow:dispatch('teammate_dead', t_event, unit)
            end
        end

        for _, opponent in pairs(unit:getOpponentList()) do
            opponent:dispatch('enemy_dead', t_event)
        end
    
    elseif (event_name == 'get_status_effect') then
        local arg = {...}
        local unit = arg[1]

        unit:dispatch('self_get_status_effect', t_event)

        for _, fellow in pairs(unit:getFellowList()) do
            fellow:dispatch('ally_get_status_effect', t_event, unit)
            if (unit ~= fellow) then
                fellow:dispatch('teammate_get_status_effect', t_event, unit)
            end
        end

        for _, opponent in pairs(unit:getOpponentList()) do
            opponent:dispatch('enemy_get_status_effect', t_event, unit)
        end

    elseif (event_name == 'dragon_active_skill') then
        local arg = {...}
        local unit = arg[1]

        unit:dispatch('self_active_skill', t_event)

        for _, fellow in pairs(unit:getFellowList()) do
            fellow:dispatch('ally_active_skill', t_event, unit)
            if (unit ~= fellow) then
                fellow:dispatch('teammate_active_skill', t_event, unit)
            end
        end

        for _, opponent in pairs(unit:getOpponentList()) do
            opponent:dispatch('enemy_active_skill', t_event, unit)
        end
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
            char:healPercent(nil, percent, b_make_effect)
        end
    end
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
function GameWorld:setTemporaryPause(pause, excluded_dragon, tag)
    if (not tag) then return end

    self.m_mPauseTag[tag] = pause

    if (pause) then
        -- 일시정지 제외될 드래곤이 없을 경우는 현상 유지
        if (self.m_bPauseMode and not excluded_dragon) then
            return
        end
    else
        -- 모든 태그별 일시정지가 해제된 경우가 아니면 일시정지를 유지시킴
        for tag, v in pairs(self.m_mPauseTag) do
            if (v) then
                if (excluded_dragon) then
                    excluded_dragon:setTemporaryPause(true)
                end

                return
            end
        end
    end

    -- 일시 정지
    if (pause) then
        -- UI 일시 정지
        self.m_inGameUI:setTemporaryPause(true)

        -- 게임 정지
        self.m_gameState:pause()
        
        -- 맵 일시 정지
        self.m_mapManager:pause()
        self.m_shakeMgr:stopShake()

        -- unit(missile, skill 포함)들 일시 정지
        for i,v in pairs(self.m_lUnitList) do
            v:setTemporaryPause(true)
        end
        
        -- 스킬 사용 중인 드래곤은 일시 정지에서 제외
        if (excluded_dragon) then
            excluded_dragon:setTemporaryPause(false)
        end
    else
        -- UI 일시 정지 해제
        self.m_inGameUI:setTemporaryPause(false)

        -- 게임 재개
        self.m_gameState:resume()

        -- 맵 일시 정지 해제
        self.m_mapManager:resume()

        -- unit(missile, skill 포함)들 일시 정지 해제
        for i,v in pairs(self.m_lUnitList) do
            v:setTemporaryPause(false)
        end
    end

    self.m_bPauseMode = pause
end

-------------------------------------
-- function getDragonBatchNodeSprite
-- @brief 드래곤의 잔상을 찍는 sprite를 리턴
-------------------------------------
function GameWorld:getDragonBatchNodeSprite(res, scale)

    -- map형태로 관리
    if (not self.m_mDragonRenderTextureBatchNode[res]) then
        -- spine리소스를 sprite화하여 배치노드를 생성
        local rtbn = RenderTextureBatchNode()
        rtbn:init_fromRes(res, scale)
        self.m_worldNode:addChild(rtbn.m_batchNode)
        self.m_mDragonRenderTextureBatchNode[res] = rtbn
    end

    -- 배치노드로부터 sprite를 얻어옴
    local sprite = self.m_mDragonRenderTextureBatchNode[res]:getSprite()
    return sprite
end

-------------------------------------
-- function prepareAuto
-------------------------------------
function GameWorld:prepareAuto()
    self.m_mUnitGroup[PHYS.HERO]:prepareAuto()
end

-------------------------------------
-- function prepareEnemyAuto
-------------------------------------
function GameWorld:prepareEnemyAuto()
    local group_key = self:getOpponentPCGroup()
    
    local auto = self.m_mUnitGroup[group_key]:getAuto()
    if (auto) then
        auto:prepare(self:getEnemyList())
    end
end

-------------------------------------
-- function updateUnitGroupMgr
-------------------------------------
function GameWorld:updateUnitGroupMgr(dt)
    for _, v in pairs(self.m_mUnitGroup) do
        v:update(dt)
    end
end

-------------------------------------
-- function getMana
-------------------------------------
function GameWorld:getMana(char)
    local group_key = char and char:getPhysGroup() or self:getPCGroup()

    return self.m_mUnitGroup[group_key]:getMana()
end

-------------------------------------
-- function startManaAccel
-------------------------------------
function GameWorld:startManaAccel(char, duration)
    local game_mana = self:getMana(char)

    game_mana:startManaAccel(duration)
end

-------------------------------------
-- function getManaAccelValue
-------------------------------------
function GameWorld:getManaAccelValue(char)
    local game_mana = self:getMana(char)

    return game_mana.m_accelValue
end

-------------------------------------
-- function resetMyMana
-------------------------------------
function GameWorld:resetMyMana()
    local mana = self.m_mUnitGroup[PHYS.HERO]:getMana()
    if (mana) then
        mana:resetMana()
    end
end

-------------------------------------
-- function resetEnemyMana
-------------------------------------
function GameWorld:resetEnemyMana()
    local mana = self.m_mUnitGroup[PHYS.ENEMY]:getMana()
    if (mana) then
        mana:resetMana()
    end
end

-------------------------------------
-- function getAuto
-------------------------------------
function GameWorld:getAuto(char)
    local group_key = char and char:getPhysGroup() or self:getPCGroup()

    return self.m_mUnitGroup[group_key]:getAuto()
end

-------------------------------------
-- function getGameKey
-------------------------------------
function GameWorld:getGameKey()
    local gamekey = g_gameScene.m_gameKey
    return gamekey
end

-------------------------------------
-- function setGameFinish
-------------------------------------
function GameWorld:setGameFinish()
    self.m_bGameFinish = true

    -- 절전모드 설정
    g_gameScene.m_sleepModeNode:removeAllChildren()
    SetSleepMode_After(g_gameScene.m_sleepModeNode, 60) -- parent, seconds
end

-------------------------------------
-- function isFinished
-------------------------------------
function GameWorld:isFinished()
    return self.m_bGameFinish
end

-------------------------------------
-- function isAutoPlay
-------------------------------------
function GameWorld:isAutoPlay()
    return self:getAuto():isActive()
end

-------------------------------------
-- function isDragonFarming
-------------------------------------
function GameWorld:isDragonFarming()
    return (g_autoPlaySetting:isFarmingOptionOn() and (self.m_gameMode == GAME_MODE_ADVENTURE))
end

-------------------------------------
-- function isPause
-------------------------------------
function GameWorld:isPause()
    return self.m_bPauseMode
end

-------------------------------------
-- function getPCGroup
-- @brief 조작할 수 있는 그룹(키값)을 리턴
-------------------------------------
function GameWorld:getPCGroup()
    return PHYS.HERO
end

-------------------------------------
-- function getOpponentPCGroup
-- @brief 조작할 수 있는 그룹의 상대편 그룹(키값)을 리턴
-------------------------------------
function GameWorld:getOpponentPCGroup()
    return PHYS.ENEMY
end

-------------------------------------
-- function getHeroGroups
-------------------------------------
function GameWorld:getHeroGroups()
    return { PHYS.HERO }
end

-------------------------------------
-- function getEnemyGroups
-------------------------------------
function GameWorld:getEnemyGroups()
    return { PHYS.ENEMY }
end