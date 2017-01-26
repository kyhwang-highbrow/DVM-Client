local PARENT = GameWorld

-------------------------------------
-- class GameWorld
-------------------------------------
GameWorldColosseum = class(PARENT, {
        m_gameAutoEnemy = '',   -- 적군 자동 AI

        m_diedHeroTotalMaxHp = 'number',    -- 죽은 아군들의 총 maxHp(죽었을때 상태로 저장)
        m_diedEnemyTotalMaxHp = 'number',    -- 죽은 적군들의 총 maxHp(죽었을때 상태로 저장)
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldColosseum:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, fever_node, ui, develop_mode)
    self.m_diedHeroTotalMaxHp = 0
    self.m_diedEnemyTotalMaxHp = 0

    -- 타임 스케일 설정
    local baseTimeScale = COLOSSEUM__TIME_SCALE
    if (g_autoPlaySetting:get('quick_mode')) then
        baseTimeScale = baseTimeScale * QUICK_MODE_TIME_SCALE
    end
    self.m_gameTimeScale:setBase(COLOSSEUM__TIME_SCALE)

    -- 적군 AI
    self.m_gameAutoEnemy = GameAuto_Colosseum(self, false)

    self.m_gameState = GameState_Colosseum(self)
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

    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 적군 덱에 세팅된 드래곤 생성
    self:makeEnemyDeck()

    -- 진형 시스템 초기화
    self:setBattleZone(self.m_deckFormation, true)
        
    do -- 스킬 조작계 초기화
        self.m_skillIndicatorMgr = SkillIndicatorMgr(self, g_currScene.m_colorLayerForSkill)
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
-- function initTamer
-------------------------------------
function GameWorldColosseum:initTamer()
    -- 테이머 대사
    self.m_tamerSpeechSystem = TamerSpeechSystemColosseum(self)
    self.m_gameFever:replaceRootNode(self.m_tamerSpeechSystem.m_speechNode)

    self:addListener('dragon_summon', self.m_tamerSpeechSystem)
    self:addListener('game_start', self.m_tamerSpeechSystem)
    self:addListener('wave_start', self.m_tamerSpeechSystem)
    self:addListener('boss_wave', self.m_tamerSpeechSystem)
    self:addListener('stage_clear', self.m_tamerSpeechSystem)
end

-------------------------------------
-- function addEnemy
-- @param enemy
-------------------------------------
function GameWorldColosseum:addEnemy(enemy)
    
    table.insert(self.m_tEnemyList, enemy)
    
    -- 죽음 콜백 등록
    enemy:addListener('character_dead', self)

    -- 등장 완료 콜백 등록
    enemy:addListener('enemy_appear_done', self.m_gameState)

    -- 스킬 캐스팅
    enemy:addListener('enemy_casting_start', self.m_gameAuto)
    
    -- 스킬 캐스팅 중 취소시 콜백 등록
    enemy:addListener('character_casting_cancel', self.m_tamerSpeechSystem)
    enemy:addListener('character_casting_cancel', self.m_gameFever)

    if (enemy.m_charType == 'dragon') then
        enemy:addListener('enemy_active_skill', self.m_gameState)
        enemy:addListener('enemy_active_skill', self.m_gameAuto)
    end

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
-- function addHero
-------------------------------------
function GameWorldColosseum:addHero(hero, idx)
    self.m_mHeroList[idx] = hero

    hero:addListener('character_dead', self)
    hero:addListener('character_dead', self.m_tamerSpeechSystem)

    hero:addListener('dragon_skill', self)
    
    hero:addListener('hero_active_skill', self.m_gameState)
    hero:addListener('hero_active_skill', self.m_gameAuto)
        
    hero:addListener('hero_casting_start', self.m_gameAuto)
       
    hero:addListener('character_weak', self.m_tamerSpeechSystem)
    hero:addListener('character_damaged_skill', self.m_tamerSpeechSystem)

    -- HP 변경시 콜백 등록
    hero:addListener('character_set_hp', self)
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
-- function isPossibleControl
-------------------------------------
function GameWorldColosseum:isPossibleControl()
    -- 강제적 조작 막음
    if (self.m_bPreventControl) then
        return false
    end

    -- 전투 중일 때에만
    if (not self.m_gameState:isFight()) then
        return false
    end

    return true
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
function GameWorldColosseum:changeEnemyHomePosByCamera(offsetX, offsetY, move_time)
    local scale = self.m_gameCamera:getScale()
    local cameraHomePosX, cameraHomePosY = self.m_gameCamera:getHomePos()
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    local move_time = move_time or getInGameConstant(WAVE_INTERMISSION_TIME)

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