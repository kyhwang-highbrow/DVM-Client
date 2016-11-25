-------------------------------------
-- class GameWorld
-------------------------------------
GameWorld = class(IEventDispatcher:getCloneClass(), IEventListener:getCloneTable(), {
        m_stageName = '',
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

        m_lUnitList = 'list',
		m_lSkillList = 'table',
		m_lMissileList = 'table',
        
        -- 출전중인 hero 
        m_participants = '',
		m_tEnemyList = 'EnemyList',
        m_lDragonList = 'DragonList',

        m_physWorld = 'PhysWorld',


        m_missileFactory = '',

        -- 웨이브 매니져
        m_waveMgr = '',

        m_gameState = '',
        m_gameFever = '',
        m_gameCamera = '',
        m_gameTimeScale = '',

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

        m_skillIndicatorMgr = 'SkillIndicatorMgr',

		-- 테이머 스킬 관련
        m_tamerSkillSystem = 'TamerSkillSystem',
        m_tamerSkillCut = 'TamerSkillCut',
        m_tamerSkillMgr = 'Tamer',
        
        -- 테이머 대사 및 표정
        m_tamerSpeechSystem = 'TamerSpeechSystem',

        m_currFocusingDragon = '',

        -- 조작 막음 여부
        m_bPreventControl = 'boolean',

        m_formationDebugNode = '',

        -- 드롭된 골드의 리스트
        m_dropGoldList = 'list[ObjectGold]',
        m_dropGoldIdx = 'number', -- 골드마다 고유한 idx를 가짐

        m_touchMotionStreak = 'cc.MotionStreak',
        m_touchPrevPos = '{x, y}',
        m_tCollisionTime = 'table',

        m_goldUnit = 'number',
        m_gold = 'number',

        m_mapManager = 'MapManager',

        m_lPassiveEffect = 'list',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorld:init(stage_id, stage_name, world_node, game_node1, game_node2, game_node3, fever_node, ui, develop_mode)
    self.m_stageName = stage_name
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

	-- 모션 스트릭 터치 영역 
    --self.makeTouchLayer_GameWorld(self, world_node)

    -- 그리드 노드
    self.m_gridNode = cc.Node:create()
    self.m_gridNode:setVisible(false)
    self.m_gameNode1:addChild(self.m_gridNode)

    self.m_worldNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_worldNode)

    self.m_missiledNode = cc.Node:create()
    self.m_gameNode1:addChild(self.m_missiledNode)

    self.m_lUnitList = {}
	self.m_lSkillList = {}
	self.m_lMissileList = {}
    self.m_tEnemyList = {}

    self.m_physWorld = PhysWorld(self.m_gameNode1, false)
    self.m_physWorld:initGroup()

    self.m_lDragonList = {}
    self.m_participants = {}

    self.m_missileFactory = MissileFactory(self)

    self.m_worldSize = nil
    self.m_worldScale = nil
    
    self.m_gameCamera = GameCamera(self, g_gameScene.m_cameraLayer)
    self.m_gameState = GameState(self)
    self.m_gameFever = GameFever(self)
    self.m_gameTimeScale = GameTimeScale(self)

    self.m_missileRange = {}
    self:setMissileRange()

    -- callback
    self.m_lWorldScaleChangeCB = {}

    g_currScene:addKeyKeyListener(self)

    self:init_dropGold()

    self.init_motionStreak(self)

    self.m_touchPrevPos = nil
    self.m_tCollisionTime = {}

    self:initGoldUnit(stage_id)

    self.m_lPassiveEffect = {}
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
-- function initWaveMgr
-------------------------------------
function GameWorld:initWaveMgr(stage_name, develop_mode)
    self.m_waveMgr = WaveMgr(self, stage_name, develop_mode)
    self.m_waveMgr:addListener('change_wave', self)
end

-------------------------------------
-- function initGoldUnit
-------------------------------------
function GameWorld:initGoldUnit(stage_id)
    local table_drop = TABLE:get('drop')
    local t_drop = table_drop[stage_id]

    self.m_goldUnit = t_drop['gold_unit']
    self.m_gold = 0
end

-------------------------------------
-- function obtainGold
-------------------------------------
function GameWorld:obtainGold(cnt)
    local cnt = (cnt or 1)
    local add_gold = (cnt * self.m_goldUnit)
    self.m_gold = (self.m_gold + add_gold)
    g_gameScene.m_inGameUI:setGold(self.m_gold)
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
        if (v:update(dt) == true) then
            table.insert(t_remove, 1, i)
            v:release()
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

    for char,l_str in pairs(self.m_lPassiveEffect) do
        self:makePassiveStartEffect(char, l_str)
    end
    self.m_lPassiveEffect = {}
end

-------------------------------------
-- function makePassiveStartEffect
-- @brief
-------------------------------------
function GameWorld:makePassiveStartEffect(char, l_str)
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
    for i,str in ipairs(l_str) do
        local label = cc.Label:createWithTTF(Str(str), 'res/font/common_font_01.ttf', 26, 3, cc.size(200, 50), 1, 1)
        node:addChild(label)
        label:setScale(0.2)
        label:runAction( cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2), cc.ScaleTo:create(0.3, 1), cc.DelayTime:create(1.6), cc.FadeOut:create(0.3), cc.RemoveSelf:create()))
        label:setPositionY((i-1) * 30)
    end

    -- 2초 후 삭제
    root_node:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.RemoveSelf:create()))

    -- 실시간 위치 동기화
    root_node:scheduleUpdateWithPriorityLua(function(dt) 
        root_node:setPosition(char.pos.x, char.pos.y)
    end, 0)
end

-------------------------------------
-- function init_test
-------------------------------------
function GameWorld:init_test(deck_type)
    if (deck_type == 'deck_5') then
        self:changeWorldSize(1)
    end

    -- 위치 표시 이펙트 생성
    self:init_formation()

    -- 배경 이미지 초기화
    self:initBG()

    -- 덱에 셋팅된 드래곤 생성
    self:makeDragonDeck()

    self.m_inGameUI:doActionReset()

    do -- 진형 시스템 초기화
        self:getBattleZone('basic', true)
    end

    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self, g_currScene.m_colorLayerForSkill)
    end

    -- 테이머 생성
    self:makeTamerSkillManager(TAMER_ID)
    local t_tamer = self.m_tamerSkillMgr.m_charTable

    do
        self.m_tamerSkillCut = TamerSkillCut(self, g_currScene.m_colorLayerTamerSkill, t_tamer)
    end

    do
        self.m_tamerSkillSystem = TamerSkillSystem(self)
        self.m_tamerSkillSystem:addListener('tamer_skill', self.m_tamerSkillCut)
        self.m_tamerSkillSystem:addListener('tamer_special_skill', self.m_tamerSkillCut)
        
        self:addListener('game_start', self.m_tamerSkillSystem)
        
        for _,char in pairs(self.m_lDragonList) do
            if (char.m_bLeftFormation) then
                char:addListener('dragon_skill', self.m_tamerSkillSystem)
                char:addListener('character_dead', self.m_tamerSkillSystem)
            end
        end
    end

    do
        self.m_tamerSpeechSystem = TamerSpeechSystem(self, t_tamer)
        self:addListener('dragon_summon', self.m_tamerSpeechSystem)
        self:addListener('game_start', self.m_tamerSpeechSystem)
        self:addListener('wave_start', self.m_tamerSpeechSystem)
        self:addListener('boss_wave', self.m_tamerSpeechSystem)
        self:addListener('stage_clear', self.m_tamerSpeechSystem)

        for _,char in pairs(self.m_lDragonList) do
            if (char.m_bLeftFormation) then
                char:addListener('character_dead', self.m_tamerSpeechSystem)
                char:addListener('character_weak', self.m_tamerSpeechSystem)
                char:addListener('character_damaged_skill', self.m_tamerSpeechSystem)
            end
        end
    end
end

-------------------------------------
-- function initBG
-------------------------------------
function GameWorld:initBG()
    local t_script_data = self.m_waveMgr.m_scriptData

    local bg = t_script_data['bg']
    local bg_type = t_script_data['bg_type'] or 'default'

    if (bg_type == 'animation') then
        self.m_mapManager = AnimationMap(self.m_bgNode, bg)

    elseif (bg_type == 'default') then
        self.m_mapManager = ScrollMap(self.m_bgNode)
        self.m_mapManager:setBg(bg)
        self.m_mapManager:setSpeed(-100)

    else
        error('bg_type : ' .. bg_type)

    end
end

-------------------------------------
-- function initEnemyClass
-------------------------------------
function GameWorld:initEnemyClass(enemy)
    self.m_rightFormationMgr:setChangePosCallback(enemy)
end

-------------------------------------
-- function addMissile
-------------------------------------
function GameWorld:addMissile(missile, object_key)
    self.m_missiledNode:addChild(missile.m_rootNode)
    self:addToMissileList(missile)
    self.m_physWorld:addObject(object_key, missile)
end

-------------------------------------
-- function findTarget
-------------------------------------
function GameWorld:findTarget(type, x, y, l_remove)
    if (type == 'enemy') then
        local enemy = nil
        local distance = nil

        for i,v in pairs(self:getEnemyList()) do
            if v.m_bDead then
            elseif l_remove and table.find(l_remove, v.phys_idx) then
            else
                local dist = getDistance(x, y, v.pos.x + v.body.x, v.pos.y + v.body.y)
                if (not distance) or (dist < distance) then
                    distance = dist
                    enemy = v
                end
            end
        end

        return enemy
    elseif (type == 'hero') then
        local hero = nil
        local distance = nil

        for i,v in pairs(self:getDragonList()) do
            if v.m_bDead then
            elseif l_remove and table.find(l_remove, v.phys_idx) then
            else
                local dist = getDistance(x, y, v.pos.x + v.body.x, v.pos.y + v.body.y)
                if (not distance) or (dist < distance) then
                    distance = dist
                    hero = v
                end
            end
        end

        return hero
    end
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
-- function getOpponentsCharList
-- @brief 상대편팀 캐릭터 리스트 리턴
-- @param  team 'ally' or 'enemy'
-- @return table
-------------------------------------
function GameWorld:getOpponentsCharList(team)
    if (team == 'ally') then
        return self:getCharList('enemy')

    elseif (team == 'enemy') then
        return self:getCharList('ally')
    end
end


-------------------------------------
-- function addEnemy
-- @param enemy
-------------------------------------
function GameWorld:addEnemy(enemy)
    table.insert(self.m_tEnemyList, enemy)
    --cclog('GameWorld:addEnemy(enemy) cnt : ' .. #self.m_tEnemyList)
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
        if (not v.m_bDead) then
            v:setDead()
            v:setEnableBody(false)
            v:changeState('dying')
        end
    end
end

-------------------------------------
-- function killAllDragon
-- @brief
-------------------------------------
function GameWorld:killAllDragon()
    for i,v in pairs(self.m_lDragonList) do
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
-- function addDragon
-------------------------------------
function GameWorld:addDragon(dragon, idx)
    self.m_lDragonList[idx] = dragon

    dragon:addListener('character_dead', self)
    dragon:addListener('dragon_skill', self)
    dragon:addListener('active_skill', self.m_gameState)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorld:removeHero(hero)
    for i,v in pairs(self.m_lDragonList) do
        if (v == hero) then
            self.m_lDragonList[i] = nil
            break
        end
    end

    self:standbyHero(hero)

    -- 게임 종료 체크(모든 영웅이 죽었을 경우)
    local hero_count = table.count(self.m_lDragonList)
    if (hero_count <= 0) then
		if (self.m_waveMgr.m_bDevelopMode) then 
			-- 개발 스테이지에서는 드래곤이 전부 죽을 시 드래곤을 되살리고 스테이지 초기화 한다 
			self.m_lDragonList = {}
			self.m_participants = {}
			
			self:makeDragonDeck()
			self:getBattleZone('basic', true)
			
			self:killAllEnemy()
		else
			self.m_gameState:changeState(GAME_STATE_FAILURE)
		end
	-- 대기 및 친구 드래곤 구현시 살림 @ms 16.11.25
	--[[
    else
		local l_dragon = self:getDragonList()
        if #l_dragon <= 0 then
            for i= 1, 10 do
                local hero = l_dragon[i]
                if hero then
                    cclog('hero.m_bDead ' .. tostring(hero.m_bDead))
                    cclog('hero.m_bActive ' .. tostring(hero.m_bActive))
                end
                if hero and (hero.m_bDead == false) and (hero.m_bActive == false) then
                    hero:changeState('attack')
                    self:participationHero(hero)
                    break
                end
            end
        end
		]]--
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
-- function makeDragonDeck
-------------------------------------
function GameWorld:makeDragonDeck()
    -- 서버에 저장된 드래곤 덱 사용
    local l_deck = g_deckData:getDeck('1')
    for i,v in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(v)
        if t_dragon_data then
            self:makeDragonNew(t_dragon_data, i)
        end
    end
end

-------------------------------------
-- function makeDragonNew
-------------------------------------
function GameWorld:makeDragonNew(t_dragon_data, idx)

    -- 유저가 보유하고있는 드래곤의 정보
    local t_dragon_data = t_dragon_data
    local dragon_id = t_dragon_data['did']

    -- 테이블의 드래곤 정보
    local table_dragon = TABLE:get('dragon')
    local t_dragon = table_dragon[dragon_id]

    local doid = t_dragon_data['id']
    local lv = t_dragon_data['lv']
    local grade = t_dragon_data['grade']
    local evolution = t_dragon_data['evolution']
	local attr = t_dragon['attr']

    local hero = Hero(nil, {0, 0, 20})
    hero:setDragonSkillLevelList(t_dragon_data['skill_0'], t_dragon_data['skill_1'], t_dragon_data['skill_2'], t_dragon_data['skill_3'])
    hero:initDragonSkillManager('dragon', dragon_id, t_dragon_data['evolution'])
    hero:initActiveSkillCoolTime() -- 액티브 스킬 쿨타임 지정
    hero.m_tDragonInfo = t_dragon_data
    hero:initAnimatorHero(t_dragon['res'], evolution, attr)
    hero.m_animator:setScale(0.5 * t_dragon['scale'])
    hero:initState()
    hero:initStatus(t_dragon, lv, grade, evolution, doid)

    --
    self.m_leftFormationMgr:setChangePosCallback(hero)

    -- 기본 정보 저장
    hero.m_dragonID = dragon_id
    hero.m_charTable = t_dragon

    --hero:changeState('attackDelay')
    hero:changeState('idle')

    self.m_worldNode:addChild(hero.m_rootNode, 2)
    self:addToUnitList(hero)
    self.m_physWorld:addObject('hero', hero)
    self:addDragon(hero, tonumber(idx))

    -- 피격 처리
    hero:addDefCallback(function(attacker, defender, i_x, i_y)
        hero:undergoAttack(attacker, defender, i_x, i_y)
    end)

    hero:makeHPGauge({0, -80})

    self:participationHero(hero)
end

-------------------------------------
-- function makeTamer
-------------------------------------
function GameWorld:makeTamerSkillManager(tamer_id)
    self.m_tamerSkillMgr = TamerSkillManager(tamer_id, self)
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

    self.m_missileRange['min_x'] = 0 - 200
    self.m_missileRange['max_x'] = (CRITERIA_RESOLUTION_X / scale) + 200
    self.m_missileRange['min_y'] = (-GAME_RESOLUTION_X / 2 / scale) - 200
    self.m_missileRange['max_y'] = (GAME_RESOLUTION_X / 2 / scale) + 200

    self.m_missileRange['min_x'] = self.m_missileRange['min_x'] + cameraHomePosX
    self.m_missileRange['max_x'] = self.m_missileRange['max_x'] + cameraHomePosX
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
        for _,dragon in pairs(self:getDragonList()) do
            dragon:updateActiveSkillCoolTime(100)
        end
        self.m_tamerSkillSystem.m_isUseSpecialSkill = false
		self.m_tamerSkillSystem:resetCoolTime()

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
        self:initBG()

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
		cclog('#### 아군 드래곤의 버프, 디버프 및 패시브 적용 확인 ')
        for _,v in ipairs(self:getDragonList()) do
			cclog('---------------')
			cclog(' DRAGON : ' .. v.m_charTable['t_name'])
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
				StatusEffectHelper:invokeStatusEffectForDev(v, STATUS_EFFECT_RES)
				cclog(STATUS_EFFECT_RES)
			end
        end

    -- 피버 모드 발동
    elseif (keyCode == KEY_F) then    
        if not self.m_gameFever:isActive() then
            self.m_gameFever:addFeverPoint(100)
        end
        
	-- 스킬 다 죽이기
	elseif (keyCode == KEY_K) then    
		local count = 1
        for _, skill in pairs(self.m_lSkillList) do
			skill:changeState('dying')
			count = count + 1
		end
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
                if isExistValue(v.m_charTable['rarity'], 'elite', 'subboss', 'boss') then
                    v:setDead()
                    v:setEnableBody(false)
                    v:changeState('dying')
                end
            end
        end
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
		--@TODO 골드 안떨어지도록 임시 처리
		self:obtainGold(1)
        --self:addDropGold(x, y)
    end
end

-------------------------------------
-- function buffActivateAtStartup
-- @brief 시작 시 버프 발동
-------------------------------------
function GameWorld:buffActivateAtStartup()
    local l_tar_skill_type = {'basic', 'normal'}

    for _,dragon in pairs(self:getDragonList()) do
        for _,skill_type in pairs(l_tar_skill_type) do
            local skill_id = dragon:getSkillID(skill_type)
            local table_skill = TABLE:get('dragon_skill')
            local t_skill = table_skill[skill_id]
            if t_skill and (t_skill['chance_type'] == 'passive') then
                dragon:doSkill(skill_id, nil, 0, 0)
            end
        end
    end

    for _,dragon in pairs(self:getDragonList()) do
        local l_passive = dragon.m_lSkillIndivisualInfo['passive']
        for i,skill_info in pairs(l_passive) do
            local skill_id = skill_info.m_skillID
            dragon:doSkill(skill_id, nil, 0, 0)
        end
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
-- function getBattleZone
-- @brief 전투영역 리턴
-------------------------------------
function GameWorld:getBattleZone(formation, immediately)
    --cclog('GameWorld:getBattleZone formation = ' .. formation)
    local script = TABLE:loadJsonTable('formation')
    
    local start_x = 40
    local end_x = 40 + (80 * 6)

    local start_y = -360 + 40
    local end_y = 360 - 40

    local t_formation = script[formation]

    for i,v in pairs(self.m_lDragonList) do
        local t_data = t_formation[tostring(i)]
        local x_rate = t_data[1]
        local y_rate = t_data[2]

        local pos_x = start_x + ((end_x - start_x) * (x_rate/100))
        local pos_y = start_y + ((end_y - start_y) * (y_rate/100))

        --cclog('# pos_x, pos_y : ' .. pos_x .. ', ' .. pos_y)

        v:setOrgHomePos(pos_x, pos_y)

        if immediately then
            v:setOrgHomePos(pos_x, pos_y)
            v:setHomePos(pos_x, pos_y)
            v:setPosition(pos_x, pos_y)
        else
            v:changeHomePos(pos_x, pos_y)
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
    if (self.m_tamerSkillCut:isPlaying()) then
        return false
    end

    -- 글로벌 쿨타임 중일 경우
    if (self.m_tamerSkillSystem:isWaitingGlobalCoolTime()) then
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
-- function init_dropGold
-------------------------------------
function GameWorld:init_dropGold()
    self.m_dropGoldList = {}	-- 'list[ObjectGold]'
    self.m_dropGoldIdx = 0		-- 'number', -- 골드마다 고유한 idx를 가짐
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
    
    -- 팀 타입에 따른 델리게이트
    local for_mgr_delegate = nil
    if (team_type == 'self') then
        return {char}

    elseif (team_type == 'ally') then
        if char.m_bLeftFormation then
            for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr)
        end

    elseif (team_type == 'enemy') then
        if char.m_bLeftFormation then
            for_mgr_delegate = FormationMgrDelegate(self.m_rightFormationMgr)
        else
            for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr)
        end

    elseif (team_type == 'all') then
        for_mgr_delegate = FormationMgrDelegate(self.m_leftFormationMgr, self.m_rightFormationMgr)
    end

    return for_mgr_delegate:getTargetList(char, x, y, team_type, formation_type, rule_type, t_data)
end

-------------------------------------
-- function changeCameraOption
-------------------------------------
function GameWorld:changeCameraOption(tParam)
    local tParam = tParam or {}
    self.m_gameCamera:setAction(tParam)
    self.m_gameCamera:setHomeInfo(tParam)

    -- 미사일 제한 범위 재설정
    self:setMissileRange()
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorld:onEvent(event_name, ...)
    if (event_name == 'character_dead') then    self:onEvent_character_dead(event_name, ...)
    elseif (event_name == 'change_wave') then   self:onEvent_change_wave(event_name, ...)
    elseif (event_name == 'dragon_skill') then  self:onEvent_dragon_skill(event_name, ...)
    end
end

-------------------------------------
-- function onEvent_character_dead
-- @brief 캐릭터 사망
-------------------------------------
function GameWorld:onEvent_character_dead(event_name, ...)
    local arg = {...}
    local char = arg[1]
    local char_type = char.m_charType

    -- 드래곤 사망
    if (char_type == 'dragon') then

    -- 몬스터 사망
    elseif (char_type == 'enemy') then
        self:dropItem(char.pos['x'], char.pos['y'])
        self:dispatch('enemy_dead', char)

    -- 정의되지 않은 캐릭터 타입
    else
        error('char.m_charType : ' .. char.m_charType)
    end
end

-------------------------------------
-- function onEvent_change_wave
-- @brief 웨이브 변경
-------------------------------------
function GameWorld:onEvent_change_wave(event_name, ...)
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
-- function onEvent_dragon_skill
-- @brief 드래곤 스킬 사용
-------------------------------------
function GameWorld:onEvent_dragon_skill(event_name, ...)
    local arg = {...}
    local dragon = arg[1]

    self.m_currFocusingDragon = dragon
    
    self.m_gameState:changeState(GAME_STATE_FIGHT_DRAGON_SKILL)
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
    for _, skill in pairs(self.m_lSkillList) do
		skill:changeState('dying')
	end
	for _, missile in pairs(self.m_lMissileList) do
		missile:changeState('dying')
	end
end

-------------------------------------
-- function releaseAll
-- @breif 메모리 체크 중에 게임 월드 해제가 제대로 안되는가 하여 만듬
-------------------------------------
function GameWorld:releaseAll()
	-- unit 리스트를 통해 한방에 삭제
	self:cleanupUnit()
    self.m_lUnitList = nil
	self.m_lSkillList = nil
	self.m_lMissileList = nil

    self.m_tEnemyList = nil
    self.m_lDragonList = nil
    self.m_participants = nil
    
	-- 저위험군
    self.m_stageName = nil
    self.m_stageID = nil
    self.m_worldSize = nil
    self.m_worldScale = nil
    
    self.m_bDebugGrid = nil
    self.m_missileRange = nil
    self.m_bDevelopMode = nil
    self.m_lWorldScaleChangeCB = nil
    self.m_currFocusingDragon = nil
    self.m_bPreventControl = nil
    self.m_formationDebugNode = nil
    self.m_dropGoldList = nil
    self.m_dropGoldIdx = nil
    self.m_touchMotionStreak = nil
    self.m_touchPrevPos = nil
    self.m_tCollisionTime = nil
    self.m_goldUnit = nil
    self.m_gold = nil
    self.m_lPassiveEffect = nil

	-- node들은 따로 remove 안해줘도 될듯
	self.m_worldLayer = nil
    self.m_gameNode1 = nil
    self.m_gameNode2 = nil
    self.m_gameNode3 = nil
    self.m_feverNode = nil
    self.m_gridNode = nil
    self.m_bgNode = nil
    self.m_groundNode = nil
    self.m_worldNode = nil
    self.m_missiledNode = nil	
    
	-- 의심만 가는 정도 
	self.m_waveMgr = nil
    self.m_gameState = nil
    self.m_gameFever = nil
    self.m_gameCamera = nil
    self.m_gameTimeScale = nil

    self.m_missileFactory = nil
    self.m_mapManager = nil
    self.m_physWorld = nil
	   
	-- 특별 관리
	self.m_inGameUI:close()
	self.m_inGameUI = nil

	self.m_leftFormationMgr = nil
    self.m_rightFormationMgr = nil
    self.m_skillIndicatorMgr = nil 
	
    self.m_tamerSkillSystem = nil
    self.m_tamerSkillCut = nil
    self.m_tamerSkillMgr = nil
    self.m_tamerSpeechSystem = nil
end