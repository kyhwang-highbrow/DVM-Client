local PARENT = GameWorld

-------------------------------------
-- class GameWorld
-------------------------------------
GameWorldColosseum = class(PARENT, {
        m_diedHeroTotalMaxHp = 'number',    -- 죽은 아군들의 총 maxHp(죽었을때 상태로 저장)
        m_diedEnemyTotalMaxHp = 'number',    -- 죽은 적군들의 총 maxHp(죽었을때 상태로 저장)

        m_enemyTamer = '',
		m_lEnemyDragons = '',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldColosseum:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode)
    self.m_diedHeroTotalMaxHp = 0
    self.m_diedEnemyTotalMaxHp = 0
	self.m_lEnemyDragons = {}
    
    -- 타임 스케일 설정
    local baseTimeScale = COLOSSEUM__TIME_SCALE
    if (g_autoPlaySetting:get('quick_mode')) then
        baseTimeScale = baseTimeScale * g_constant:get('INGAME', 'QUICK_MODE_TIME_SCALE')
    end
    self.m_gameTimeScale:setBase(baseTimeScale)

    -- 적군 AI
    self.m_gameAutoEnemy = GameAuto_Enemy(self, false)

    self.m_gameState = GameState_Colosseum(self)
    self.m_inGameUI:init_timeUI(false, self.m_gameState.m_limitTime)
end


-------------------------------------
-- function initGame
-------------------------------------
function GameWorldColosseum:initGame(stage_name)
    -- 웨이브 매니져 생성
    self.m_waveMgr = WaveMgr_Colosseum(self, stage_name, self.m_bDevelopMode)
        
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

    -- 적군 덱에 세팅된 드래곤 생성
    self:makeEnemyDeck()

    -- 진형 시스템 초기화
    self:setBattleZone(self.m_deckFormation, true)

    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self)
    end

    do -- 카메라 초기 위치 설정이 있다면 적용
        local t_camera = self.m_waveMgr:getBaseCameraScriptData()
        if t_camera then
            t_camera['time'] = 0
            self:changeCameraOption(t_camera)
        end
    end

    -- UI
    self.m_inGameUI:doActionReset()
end

-------------------------------------
-- function initBG
-------------------------------------
function GameWorldColosseum:initBG(waveMgr)
    local t_script_data = waveMgr.m_scriptData
    if not t_script_data then return end

    local bg_res = t_script_data['bg']
    local bg_type = t_script_data['bg_type'] or 'default'
	local bg_directing = t_script_data['bg_directing'] or 'floating_1'
    
    if (bg_type == 'animation') then
        self.m_mapManager = AnimationMap(self.m_bgNode, bg_res)

    elseif (bg_type == 'default') then
        self.m_mapManager = ScrollMap(self.m_bgNode)
        self.m_mapManager:setBg(bg_res)
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
function GameWorldColosseum:initTamer()
    local HERO_TAMER_POS_X = 320 - 50
    local ENEMY_TAMER_POS_X = 960 + 50
    local TAMER_POS_Y = -600

    -- 아군 테이머 생성
    do
        local t_tamer = g_tamerData:getCurrTamerTable()
        self.m_tamer = self:makeTamerNew(t_tamer)
        self.m_tamer:setPosition(HERO_TAMER_POS_X, TAMER_POS_Y)
        self.m_tamer:setAnimatorScale(1)
        self.m_tamer:changeState('appear_colosseum')
        self.m_tamer.m_animator.m_node:pause()

        self.m_tamer.m_barrier:setVisible(false)
    end
    
    -- 적군 테이머 생성
    do
        local user_info = g_colosseumData:getVsUserInfo()
        local tid = user_info:getTamer()
        local t_tamer = TableTamer():get(tid)

        -- 설정이 제대로 안된 경우라면 고니로 강제 설정
        if (not t_tamer) then
			local tid = g_constant:get('INGAME', 'TAMER_ID')
            t_tamer = TableTamer():get(tid)
        end
    
        self.m_enemyTamer = self:makeTamerNew(t_tamer, true)
        self.m_enemyTamer:setPosition(ENEMY_TAMER_POS_X, TAMER_POS_Y)
        self.m_enemyTamer:setAnimatorScale(1)
        self.m_enemyTamer:changeState('appear_colosseum')
        self.m_enemyTamer.m_animator.m_node:pause()

        self.m_enemyTamer.m_barrier:setVisible(false)
    end
end

-------------------------------------
-- function addHero
-------------------------------------
function GameWorldColosseum:addHero(hero, idx)
    self.m_mHeroList[idx] = hero

    hero:addListener('dragon_active_skill', self.m_gameDragonSkill)
    hero:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    hero:addListener('set_global_cool_time_active', self.m_gameCoolTime)
    hero:addListener('hero_active_skill', self.m_gameAutoHero)

    -- HP 변경시 콜백 등록
    hero:addListener('character_set_hp', self)
end

-------------------------------------
-- function addEnemy
-- @param enemy
-------------------------------------
function GameWorldColosseum:addEnemy(enemy)
    table.insert(self.m_tEnemyList, enemy)
    
    enemy:addListener('dragon_active_skill', self.m_gameDragonSkill)
    enemy:addListener('set_global_cool_time_passive', self.m_gameCoolTime)
    enemy:addListener('set_global_cool_time_active', self.m_gameCoolTime)
    enemy:addListener('enemy_active_skill', self.m_gameAutoHero)

    -- HP 변경시 콜백 등록
    enemy:addListener('character_set_hp', self)
end


-------------------------------------
-- function removeEnemy
-- @param enemy
-------------------------------------
function GameWorldColosseum:removeEnemy(enemy)
    self.m_diedEnemyTotalMaxHp = self.m_diedEnemyTotalMaxHp + enemy.m_maxHp

    local idx = table.find(self.m_tEnemyList, enemy)
    table.remove(self.m_tEnemyList, idx)
end

-------------------------------------
-- function removeHero
-------------------------------------
function GameWorldColosseum:removeHero(hero)
    self.m_diedHeroTotalMaxHp = self.m_diedHeroTotalMaxHp + hero.m_maxHp

    for i,v in pairs(self.m_mHeroList) do
        if (v == hero) then
            self.m_mHeroList[i] = nil
            break
        end
    end

    self:standbyHero(hero)

    local hero_count = table.count(self.m_mHeroList)
    if (hero_count <= 0) then
        self.m_gameState:changeState(GAME_STATE_FAILURE)
    end
end

-------------------------------------
-- function setBattleZone
-- @brief 전투영역 설정
-------------------------------------
function GameWorldColosseum:setBattleZone(formation, immediately)
    GameWorld.setBattleZone(self, formation, immediately)
    GameWorld.setBattleZone(self, formation, immediately, true)
end

-------------------------------------
-- function changeCameraOption
-------------------------------------
function GameWorldColosseum:changeCameraOption(tParam, bKeepHomePos)
    local tParam = tParam or {}
    
    self.m_gameCamera:setAction(tParam)

    if not bKeepHomePos then
        self.m_gameCamera:setHomeInfo(tParam)
    end
end

-------------------------------------
-- function changeEnemyHomePosByCamera
-------------------------------------
function GameWorldColosseum:changeEnemyHomePosByCamera(offsetX, offsetY, move_time, no_tamer)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local gap_x, gap_y = self.m_gameCamera:getIntermissionOffset()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant("WAVE_INTERMISSION_TIME")

    -- 아군 홈 위치를 카메라의 홈위치 기준으로 변경
    for i, v in ipairs(self:getEnemyList()) do
        if (v.m_bDead == false) then
            -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
            local homePosX = v.m_orgHomePosX + cameraHomePosX + offsetX
            local homePosY = v.m_orgHomePosY + cameraHomePosY + offsetY

            -- 카메라가 줌아웃된 상태라면 적군 위치 조정(차후 정리)
            if (scale == 0.6) then
                homePosX = homePosX + 200
            end

            v:changeHomePosByTime(homePosX, homePosY, move_time)
        end
    end

    if (not no_tamer and self.m_enemyTamer) then
        -- 변경된 카메라 위치에 맞게 홈 위치 변경 및 이동
        local homePosX = self.m_enemyTamer.pos.x + gap_x + offsetX
        local homePosY = self.m_enemyTamer.pos.y + gap_y + offsetY

        -- 카메라가 줌아웃된 상태라면 아군 위치 조정(차후 정리)
        if (scale == 0.6) then
            homePosX = homePosX - 200
        end

        self.m_enemyTamer:changeHomePosByTime(homePosX, homePosY, move_time)
    end

end

-------------------------------------
-- function onEvent
-------------------------------------
function GameWorldColosseum:onEvent(event_name, t_event, ...)
    GameWorld.onEvent(self, event_name, t_event, ...)

    if (event_name == 'character_set_hp') then
        local arg = {...}
        local char = arg[1]
        local unitList
        local totalHp = 0
        local totalMaxHp = 0

        if (char.m_bLeftFormation) then
            unitList = self:getDragonList()
            totalMaxHp = self.m_diedHeroTotalMaxHp
        else
            unitList = self:getEnemyList()
            totalMaxHp = self.m_diedEnemyTotalMaxHp
        end

        -- 진형에 따라 HP게이지 갱신
        for i, v in ipairs(unitList) do
            totalHp = totalHp + v.m_hp
            totalMaxHp = totalMaxHp + v.m_maxHp
        end

        local percentage = (totalHp / totalMaxHp) * 100

        if (char.m_bLeftFormation) then
            self.m_inGameUI:setHeroHpGauge(percentage)
        else
            self.m_inGameUI:setEnemyHpGauge(percentage)
        end
    end
end

-------------------------------------
-- function makeEnemyDeck
-- @TODO 상대편 덱 정보를 받아서 생성해야함
-------------------------------------
function GameWorldColosseum:makeEnemyDeck()
    local user_info = g_colosseumData:getVsUserInfo()

    -- 상대방의 덱 정보를 얻어옴
    local l_deck, formation = user_info:getDeck()

    -- 덱에 배치된 드래곤들 생성
    for i, doid in pairs(l_deck) do
        local t_dragon_data = user_info:getDragon(doid)
        if (t_dragon_data) then
            local status_calc = user_info:makeDragonStatusCalculator(doid)
            local is_right = true
            local enemy = self:makeDragonNew(t_dragon_data, is_right, status_calc)
            if (enemy) then
				self.m_lEnemyDragons[i] = enemy
                enemy:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
                self.m_physWorld:addObject(PHYS.ENEMY, enemy)
                self:addEnemy(enemy, tonumber(i))

                self.m_rightFormationMgr:setChangePosCallback(enemy)

                -- 진형 버프 적용
                enemy.m_statusCalc:applyFormationBonus(formation, i)
            end
        end
    end

    -- 상대편 드래곤들은 게이지를 조정
    do
        local t_percentage = clone(COLOSSEUM__ENEMY_START_GAUGE_LIST)
        t_percentage = randomShuffle(t_percentage)

        for i, dragon in ipairs(self:getEnemyList()) do
            dragon:initActiveSkillCool(t_percentage[i])
        end
    end
end