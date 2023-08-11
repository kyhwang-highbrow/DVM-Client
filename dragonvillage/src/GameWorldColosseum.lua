local PARENT = GameWorld

-------------------------------------
-- class GameWorld
-------------------------------------
GameWorldColosseum = class(PARENT, {
        m_enemyTamer = '',

		m_lEnemyDragons = '',
        m_bFriendMatch = 'boolean',
        m_enemyDeckFormation = 'string',
        m_enemyDeckFormationLv = 'number',
    })

-------------------------------------
-- function init
-------------------------------------
function GameWorldColosseum:init(game_mode, stage_id, world_node, game_node1, game_node2, game_node3, ui, develop_mode, friend_match)
    self.m_lEnemyDragons = {}
    self.m_bFriendMatch = friend_match or false
end

-------------------------------------
-- function createComponents
-------------------------------------
function GameWorldColosseum:createComponents()
    PARENT.createComponents(self)

    self.m_gameState = GameState_Colosseum(self)
    self.m_inGameUI:init_timeUI(false, self.m_gameState.m_limitTime)
    -- 속도 배율 비주얼 처리
    self.m_inGameUI:init_speedUI()
    -- 적 마나 및 쿨타임 표시 상태인 경우 처리
    if (g_constant:get('DEBUG', 'DISPLAY_ENEMY_MANA_COOLDOWN')) then
        self.m_mUnitGroup[PHYS.HERO]:getMana():bindUI(nil)
        self.m_mUnitGroup[PHYS.ENEMY]:getMana():bindUI(self.m_inGameUI)
    end
end

-------------------------------------
-- function initGame
-------------------------------------
function GameWorldColosseum:initGame(stage_name)
    -- 구성 요소들을 생성
    self:createComponents()

    -- 웨이브 매니져 생성
    self.m_waveMgr = WaveMgr_Colosseum(self, stage_name, self.m_stageID, self.m_bDevelopMode)
        
	-- 배경 생성
    self:initBG(self.m_waveMgr)

    -- 월드 크기 설정
    self:changeWorldSize(1)

	-- Game Log Recorder 생성
	self.m_logRecorder = LogRecorderWorld(self)

    -- 테이머 생성
    self:initTamer()

    -- 덱에 셋팅된 드래곤 생성
    self:makeHeroDeck()

    -- 적군 덱에 세팅된 드래곤 생성
    self:makeEnemyDeck()

    -- 초기 쿨타임 설정
    self:initActiveSkillCool(self:getDragonList())
    self:initActiveSkillCool(self:getEnemyList())

    -- 초기 마나 설정
    self.m_mUnitGroup[PHYS.HERO]:getMana():addMana(START_MANA_COLOSSEUM)
    self.m_mUnitGroup[PHYS.ENEMY]:getMana():addMana(START_MANA_COLOSSEUM)

    -- 진형 시스템 초기화
    self:setBattleZone(self.m_deckFormation, true)
    self:setBattleZone(self.m_enemyDeckFormation, true, true)
    
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
    --local TAMER_POS_Y = -600
    local TAMER_POS_Y = -580
    local is_friendMatch = g_gameScene.m_bFriendMatch

    -- 아군 테이머 생성
    do
        local user_info = (is_friendMatch) and g_friendMatchData.m_playerUserInfo or g_colosseumData.m_playerUserInfo
        local tamer_id = user_info:getAtkDeckTamerID()
        local t_tamer_data = clone(g_tamerData:getTamerServerInfo(tamer_id))
        local t_costume_data = g_tamerCostumeData:getCostumeDataWithTamerID(tamer_id)

        self.m_tamer = self:makeTamerNew(t_tamer_data, t_costume_data)
        self.m_tamer:setPosition(HERO_TAMER_POS_X, TAMER_POS_Y)
        --self.m_tamer:setAnimatorScale(1)
        self.m_tamer:setAnimatorScale(0.9)
        self.m_tamer:changeState('appear_colosseum')
        self.m_tamer.m_animator.m_node:pause()
    end
    
    -- 적군 테이머 생성
    do
        local user_info
                
        if (self.m_bDevelopMode) then
            user_info = (is_friendMatch) and g_friendMatchData.m_playerUserInfo or g_colosseumData.m_playerUserInfo
        else
            user_info = (is_friendMatch) and g_friendMatchData.m_matchInfo or g_colosseumData:getMatchUserInfo()
        end

        local t_tamer_data = clone(user_info:getDefDeckTamerInfo())

        local costume_id = user_info:getDefDeckCostumeID()
        local t_costume = TableTamerCostume():get(costume_id)
        local t_costume_data = StructTamerCostume(t_costume)
                
        self.m_enemyTamer = self:makeTamerNew(t_tamer_data, t_costume_data, true)
        self.m_enemyTamer:setPosition(ENEMY_TAMER_POS_X, TAMER_POS_Y)
        self.m_enemyTamer:setAnimatorScale(1)
        self.m_enemyTamer:changeState('appear_colosseum')
        self.m_enemyTamer.m_animator.m_node:pause()

        self.m_enemyTamer:addListener('enemy_tamer_skill_gauge', self)
    end

    -- 테이머 UI 생성
    self.m_inGameUI:initTamerUI(self.m_tamer, self.m_enemyTamer)
end

-------------------------------------
-- function passiveActivate_Right
-- @brief 패시브 발동
-------------------------------------
function GameWorldColosseum:passiveActivate_Right()
    PARENT.passiveActivate_Right(self)

    -- 테이머 버프
    if (self.m_enemyTamer) then
        self.m_enemyTamer:doSkill_passive()
    end

    -- 적 리더 버프
    self.m_mUnitGroup[PHYS.ENEMY]:doSkill_leader()
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
        if (not v:isDead()) then
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
    PARENT.onEvent(self, event_name, t_event, ...)

    if (event_name == 'character_set_hp') then
        local arg = {...}
        local char = arg[1]
        local unitList
        local totalHp = 0
        local totalMaxHp = 0

        if (char.m_bLeftFormation) then
            unitList = self.m_myDragons
        else
            unitList = self.m_lEnemyDragons
        end

        -- 진형에 따라 HP게이지 갱신
        for _, v in pairs(unitList) do
            totalHp = totalHp + v.m_hp
            totalMaxHp = totalMaxHp + v.m_maxHp
        end

        local percentage = (totalHp / totalMaxHp) * 100

        if (char.m_bLeftFormation) then
            self.m_inGameUI:setHeroHpGauge(percentage)
        else
            self.m_inGameUI:setEnemyHpGauge(percentage)
        end

    elseif (event_name == 'enemy_tamer_skill_gauge') then
        local cur = t_event['cur']
        local max = t_event['max']

        local percentage = (cur / max) * 100
                
        self.m_inGameUI:setEnemyTamerGauge(percentage)
        
    end
end

-------------------------------------
-- function prepareAuto
-------------------------------------
function GameWorldColosseum:prepareAuto()
    self.m_mUnitGroup[PHYS.HERO]:prepareAuto()
    self.m_mUnitGroup[PHYS.ENEMY]:prepareAuto()
end

-------------------------------------
-- function makeHeroDeck
-------------------------------------
function GameWorldColosseum:makeHeroDeck()
    -- 서버에 저장된 드래곤 덱 사용
    local is_friendMatch = g_gameScene.m_bFriendMatch
    local user_info = (is_friendMatch) and g_friendMatchData.m_playerUserInfo or g_colosseumData.m_playerUserInfo

    local t_pvp_deck = user_info:getPvpAtkDeck()
    local l_deck = user_info:getAtkDeck_dragonList(true)
    local formation = t_pvp_deck['formation']
    local formation_lv = t_pvp_deck['formationlv']
    local leader = t_pvp_deck['leader']

    self.m_deckFormation = formation
    self.m_deckFormationLv = formation_lv

    -- 팀보너스를 가져옴
    local l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_deck)

    -- 출전 중인 드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_myDragons = {}

    for i, doid in pairs(l_deck) do
        local t_dragon_data = g_dragonsData:getDragonDataFromUid(doid)
        if (t_dragon_data) then
            local status_calc = MakeOwnDragonStatusCalculator(doid, nil, 'pvp')
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

                -- 라테아 버프 적용(삼뉴체크)
                hero.m_statusCalc:applyLateaBuffs({})


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
-- function makeEnemyDeck
-------------------------------------
function GameWorldColosseum:makeEnemyDeck()
    local t_pvp_deck
    local l_deck
    local getDragonObject
    local is_friendMatch = g_gameScene.m_bFriendMatch

    if (self.m_bDevelopMode) then
        local user_info = (is_friendMatch) and g_friendMatchData.m_playerUserInfo or g_colosseumData.m_playerUserInfo
        -- 개발모드에선 자신의 방어덱을 상대로 설정
        t_pvp_deck = user_info:getPvpDefDeck()
        l_deck = user_info:getDefDeck_dragonList(true)
        getDragonObject = function(doid) return g_dragonsData:getDragonDataFromUid(doid) end
    else
        -- 상대방의 덱 정보를 얻어옴
        local user_info =(is_friendMatch) and g_friendMatchData.m_matchInfo or g_colosseumData:getMatchUserInfo()
        t_pvp_deck = user_info:getPvpDefDeck()
        l_deck = user_info:getDefDeck_dragonList(true)
        getDragonObject = function(doid) return user_info:getDragonObject(doid) end
    end

    local formation = t_pvp_deck['formation']
    local formation_lv = t_pvp_deck['formationlv']
    local leader = t_pvp_deck['leader']

    self.m_enemyDeckFormation = formation
    self.m_enemyDeckFormationLv = formation_lv

    -- 팀보너스를 가져옴
    local l_teambonus_data

    do
        local l_dragon_data = {}
        for i, doid in pairs(l_deck) do
            local t_dragon_data = getDragonObject(doid)
            table.insert(l_dragon_data, t_dragon_data)
        end

        l_teambonus_data = TeamBonusHelper:getTeamBonusDataFromDeck(l_dragon_data)
    end

    -- 출전 중인 적드래곤 객체를 저장하는 용도 key : 출전 idx, value :Dragon
    self.m_lEnemyDragons = {}

    -- 덱에 배치된 드래곤들 생성
    for i, doid in pairs(l_deck) do
        local t_dragon_data = getDragonObject(doid)
        if (t_dragon_data) then
            local status_calc = MakeDragonStatusCalculator_fromDragonDataTable(t_dragon_data, 'pvp')
            local is_right = true
            local enemy = self:makeDragonNew(t_dragon_data, is_right, status_calc)
            if (enemy) then
				self.m_lEnemyDragons[i] = enemy
                enemy:setPosIdx(tonumber(i))

                self.m_worldNode:addChild(enemy.m_rootNode, WORLD_Z_ORDER.ENEMY)
                self.m_physWorld:addObject(PHYS.ENEMY, enemy)
                self:bindEnemy(enemy)
                self:addEnemy(enemy, tonumber(i))

                -- 진형 버프 적용
                enemy.m_statusCalc:applyFormationBonus(formation, formation_lv, i)

                -- 스테이지 버프 적용
                enemy.m_statusCalc:applyStageBonus(self.m_stageID)

                -- 라테아 버프 적용(삼뉴체크)
                enemy.m_statusCalc:applyLateaBuffs({})

                enemy:setStatusCalc(enemy.m_statusCalc)

                -- 팀보너스 적용
                for i, teambonus_data in ipairs(l_teambonus_data) do
                    TeamBonusHelper:applyTeamBonusToDragonInGame(teambonus_data, enemy)
                end

                -- 리더 등록
				if (i == leader) then
                    self.m_mUnitGroup[PHYS.ENEMY]:setLeader(enemy)
				end
            end
        end
    end
end

-------------------------------------
-- function print_tamer_skill
-- @brief 테이머 스킬 보기
-------------------------------------
function GameWorldColosseum:print_tamer_skill()
    if (self.m_tamer) then
        self.m_tamer:printSkillManager()
    end

    if (self.m_enemyTamer) then
        self.m_enemyTamer:printSkillManager()
    end
end